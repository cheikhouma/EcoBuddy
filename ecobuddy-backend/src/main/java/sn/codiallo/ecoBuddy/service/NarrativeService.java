package sn.codiallo.ecoBuddy.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.codiallo.ecoBuddy.dto.*;
import sn.codiallo.ecoBuddy.model.NarrativeSession;
import sn.codiallo.ecoBuddy.model.StoryHistory;
import sn.codiallo.ecoBuddy.model.User;
import sn.codiallo.ecoBuddy.repository.NarrativeSessionRepository;
import sn.codiallo.ecoBuddy.repository.StoryHistoryRepository;
import sn.codiallo.ecoBuddy.repository.UserRepository;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

@Service
@RequiredArgsConstructor
@Slf4j
public class NarrativeService {

    private final GeminiService geminiService;
    private final NarrativeSessionRepository narrativeSessionRepository;
    private final StoryHistoryRepository storyHistoryRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    @Value("${gemini.api.key}")
    private String geminiApiKey;


    @Transactional
    public NarrativeStartResponse startNarrative(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Désactiver toutes les sessions actives de l'utilisateur
        List<NarrativeSession> activeSessions = narrativeSessionRepository.findByUserAndIsActiveTrue(user);
        activeSessions.forEach(session -> session.setIsActive(false));
        narrativeSessionRepository.saveAll(activeSessions);

        // Créer une nouvelle session
        String sessionId = UUID.randomUUID().toString();
        NarrativeSession session = new NarrativeSession();
        session.setUser(user);
        session.setSessionId(sessionId);
        session.setStepCount(0);
        session.setIsActive(true);
        session.setConversationHistory("[]");

        try {
            // Utiliser GeminiService pour démarrer l'histoire
            String responseText = geminiService.generateStoryStart();
            String jsonResponse = geminiService.extractJsonFromResponse(responseText);
            
            StoryResponse storyResponse;
            if (jsonResponse != null) {
                // Parser la réponse JSON
                storyResponse = parseJsonStoryResponse(jsonResponse);
            } else {
                // Fallback vers l'ancien parsing si JSON échoue
                log.warn("JSON parsing failed, using fallback parsing");
                storyResponse = parseGeminiStoryResponse(responseText);
            }
            
            session.setCurrentStory(jsonResponse != null ? jsonResponse : responseText);
            session.setConversationHistory(updateConversationHistory("[]", "Start story", responseText));
            
            narrativeSessionRepository.save(session);

            // Générer un ID unique pour cette étape
            String storyId = UUID.randomUUID().toString();
            
            return new NarrativeStartResponse(
                    storyId,
                    sessionId,
                    storyResponse.getTitle(),
                    storyResponse.getContent(),
                    storyResponse.getChoices(),
                    storyResponse.getChoicePoints(), // Array des points pour chaque choix
                    session.getStepCount() + 1, // chapterNumber (commence à 1)
                    storyResponse.getPoints(), // points gagnés pour cette étape
                    user.getPoints(), // points totaux de l'utilisateur
                    storyResponse.getIsCompleted(),
                    "success" // statut
            );

        } catch (Exception e) {
            log.error("Error starting narrative: ", e);
            throw new RuntimeException("Failed to start narrative: " + e.getMessage());
        }
    }

    @Transactional
    public NarrativeChoiceResponse processChoice(String sessionId, String choice, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        NarrativeSession session = narrativeSessionRepository.findBySessionId(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));

        if (!session.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Session does not belong to user");
        }

        if (!session.getIsActive()) {
            throw new RuntimeException("Session is not active");
        }

        try {
            // Convertir l'index du choix en texte si nécessaire et récupérer les points du choix précédent
            String choiceText = extractChoiceText(session.getCurrentStory(), choice);
            Integer pointsEarned = extractPointsForChoice(session.getCurrentStory(), choice);

            // Utiliser GeminiService pour générer la suite de l'histoire
            String responseText = geminiService.generateNarrative(session.getCurrentStory(), List.of(choiceText));
            String jsonResponse = geminiService.extractJsonFromResponse(responseText);

            ChoiceResponse choiceResponse;
            if (jsonResponse != null) {
                // Parser la réponse JSON
                choiceResponse = parseJsonChoiceResponse(jsonResponse);
            } else {
                // Fallback vers l'ancien parsing si JSON échoue
                log.warn("JSON parsing failed for choice response, using fallback parsing");
                choiceResponse = parseGeminiChoiceResponse(responseText);
            }

            session.setCurrentStory(jsonResponse != null ? jsonResponse : responseText);
            session.setStepCount(session.getStepCount() + 1);
            session.setConversationHistory(updateConversationHistory(session.getConversationHistory(), choice, responseText));

            // Attribuer les points IMMÉDIATEMENT après le choix (utiliser les points du choix précédent)
            if (pointsEarned > 0) {
                user.setPoints(user.getPoints() + pointsEarned);
                userRepository.save(user);
                log.info("User {} earned {} points for choice: {}", username, pointsEarned, choice);
            }

            // Marquer l'histoire comme terminée si nécessaire
            if (choiceResponse.getIsCompleted()) {
                session.setIsActive(false);
                log.info("Story completed for user {}", username);

                // Sauvegarder automatiquement dans l'historique
                saveCompletedStoryToHistory(session, user, choiceResponse);
            }

            narrativeSessionRepository.save(session);

            // Générer un ID unique pour cette étape
            String storyId = UUID.randomUUID().toString();
            
            return new NarrativeChoiceResponse(
                    storyId,
                    sessionId,
                    choiceResponse.getTitle(),
                    choiceResponse.getContent(),
                    choiceResponse.getChoices(),
                    choiceResponse.getChoicePoints(), // Array des points pour chaque choix
                    session.getStepCount(), // chapterNumber
                    pointsEarned, // points gagnés pour ce choix
                    user.getPoints(), // points totaux actualisés
                    choiceResponse.getIsCompleted(),
                    "success" // status
            );

        } catch (Exception e) {
            log.error("Error processing choice: ", e);
            throw new RuntimeException("Failed to process choice: " + e.getMessage());
        }
    }

    private StoryResponse parseGeminiStoryResponse(String responseText) {
        try {
            // 🚀 PARSING ROBUSTE avec nouveau système
            StoryData parsed = RobustParser.parseStoryResponse(responseText, false);

            StoryResponse response = new StoryResponse();
            response.setStory(parsed.title + "\n\n" + parsed.content);
            response.setChoices(parsed.choices);

            log.info("✅ Successfully parsed story response: title='{}', choices={}",
                parsed.title, parsed.choices.size());

            return response;
        } catch (Exception e) {
            log.warn("❌ Error in robust parsing, using enhanced fallback: ", e);

            // 🛡️ FALLBACK AMÉLIORÉ
            StoryData fallback = RobustParser.createFallbackStory(false);
            StoryResponse response = new StoryResponse();
            response.setStory(fallback.title + "\n\n" + fallback.content);
            response.setChoices(fallback.choices);

            return response;
        }
    }

    private ChoiceResponse parseGeminiChoiceResponse(String responseText) {
        try {
            // 🚀 PARSING ROBUSTE avec nouveau système
            StoryData parsed = RobustParser.parseStoryResponse(responseText, true);

            ChoiceResponse response = new ChoiceResponse();
            response.setTitle(parsed.title);
            response.setContent(parsed.content);
            response.setChoices(parsed.choices);
            response.setIsCompleted(parsed.isCompleted);
            response.setPointsEarned(parsed.points);

            // 🚀 GÉNÉRATION POINTS PAR CHOIX (pour la prochaine décision)
            List<Integer> choicePoints = new ArrayList<>();
            for (int i = 0; i < parsed.choices.size(); i++) {
                // Attribuer des points variables selon la position (pour variété)
                int points = 15 + (i % 3) * 5; // 15, 20, 25 selon position
                choicePoints.add(points);
            }
            response.setChoicePoints(choicePoints);

            log.info("✅ Successfully parsed choice response: title='{}', choices={}, points={}",
                parsed.title, parsed.choices.size(), parsed.points);

            return response;
        } catch (Exception e) {
            log.warn("❌ Error in robust choice parsing, using enhanced fallback: ", e);

            // 🛡️ FALLBACK AMÉLIORÉ pour les choix
            StoryData fallback = RobustParser.createFallbackStory(true);
            ChoiceResponse fallbackResponse = new ChoiceResponse();
            fallbackResponse.setTitle(fallback.title);
            fallbackResponse.setContent(fallback.content);
            fallbackResponse.setChoices(fallback.choices);
            fallbackResponse.setIsCompleted(fallback.isCompleted);
            fallbackResponse.setPointsEarned(fallback.points);

            // Points par défaut pour les choix
            List<Integer> choicePoints = Arrays.asList(15, 20, 25);
            fallbackResponse.setChoicePoints(choicePoints);

            return fallbackResponse;
        }
    }

    private String updateConversationHistory(String history, String prompt, String response) {
        try {
            // Pour simplifier, on peut stocker l'historique comme du texte
            return history + "\nPrompt: " + prompt + "\nResponse: " + response;
        } catch (Exception e) {
            log.warn("Error updating conversation history: ", e);
            return history;
        }
    }
    
    /**
     * Sépare le titre et le contenu à partir de la réponse de l'histoire.
     * Si le format est "Titre: xxx | Situation: yyy", sépare proprement.
     * Sinon, génère un titre par défaut.
     */
    private String[] separateTitleAndContent(String story) {
        if (story == null || story.trim().isEmpty()) {
            return new String[]{"Chapitre", "Une nouvelle aventure écologique commence..."};
        }
        
        try {
            // Si le format contient "Titre:" et "Situation:"
            if (story.contains("Titre:") && story.contains("Situation:")) {
                String title = "";
                String content = "";
                
                // Extraire le titre
                int titleStart = story.indexOf("Titre:");
                int titleEnd = story.indexOf("|", titleStart);
                if (titleStart != -1 && titleEnd != -1) {
                    title = story.substring(titleStart + 6, titleEnd).trim();
                }
                
                // Extraire le contenu (situation)
                int situationStart = story.indexOf("Situation:");
                int situationEnd = story.indexOf("| Choix:");
                if (situationStart != -1) {
                    if (situationEnd != -1) {
                        content = story.substring(situationStart + 10, situationEnd).trim();
                    } else {
                        // Si pas de "| Choix:", prendre jusqu'à la fin ou "| Points:"
                        int pointsPos = story.indexOf("| Points:");
                        if (pointsPos != -1) {
                            content = story.substring(situationStart + 10, pointsPos).trim();
                        } else {
                            content = story.substring(situationStart + 10).trim();
                        }
                    }
                }
                
                return new String[]{
                    title.isEmpty() ? "Chapitre Écologique" : title,
                    content.isEmpty() ? story : content
                };
            } else {
                // Format simple, générer un titre par défaut
                String[] lines = story.split("\n", 2);
                if (lines.length > 1) {
                    return new String[]{
                        lines[0].length() > 50 ? "Aventure Écologique" : lines[0],
                        lines.length > 1 ? lines[1] : story
                    };
                } else {
                    return new String[]{
                        "Aventure Écologique",
                        story
                    };
                }
            }
        } catch (Exception e) {
            log.warn("Error separating title and content, using defaults", e);
            return new String[]{"Aventure Écologique", story};
        }
    }

    // Nouveau parsing JSON robuste
    private StoryResponse parseJsonStoryResponse(String jsonResponse) {
        try {
            StoryResponse response = new StoryResponse();

            // Parse JSON avec Jackson
            var jsonNode = objectMapper.readTree(jsonResponse);

            response.setTitle(jsonNode.path("title").asText("Aventure Écologique"));
            response.setContent(jsonNode.path("content").asText(""));
            response.setIsCompleted(jsonNode.path("isCompleted").asBoolean(false));

            // Parser les choix
            List<String> choices = new ArrayList<>();
            var choicesArray = jsonNode.path("choices");
            if (choicesArray.isArray()) {
                choicesArray.forEach(choice -> choices.add(choice.asText()));
            }
            response.setChoices(choices);

            // Parser les points pour chaque choix (nouveau format)
            List<Integer> choicePoints = new ArrayList<>();
            var pointsArray = jsonNode.path("points");
            if (pointsArray.isArray()) {
                pointsArray.forEach(points -> choicePoints.add(points.asInt(10))); // défaut 10 points
            } else if (pointsArray.isInt()) {
                // Compatibilité ancien format : si c'est un seul nombre, l'utiliser pour tous les choix
                int singlePoints = pointsArray.asInt(0);
                for (int i = 0; i < choices.size(); i++) {
                    choicePoints.add(singlePoints);
                }
            } else {
                // Si pas de points définis, utiliser des valeurs par défaut
                for (int i = 0; i < choices.size(); i++) {
                    choicePoints.add(15); // défaut 15 points par choix
                }
            }
            response.setChoicePoints(choicePoints);

            return response;
        } catch (JsonProcessingException e) {
            log.error("Error parsing JSON story response: ", e);
            throw new RuntimeException("Invalid JSON response from AI service");
        }
    }

    private ChoiceResponse parseJsonChoiceResponse(String jsonResponse) {
        try {
            ChoiceResponse response = new ChoiceResponse();

            // Parse JSON avec Jackson
            var jsonNode = objectMapper.readTree(jsonResponse);

            response.setTitle(jsonNode.path("title").asText("Suite de l'Histoire"));
            response.setContent(jsonNode.path("content").asText(""));
            response.setPointsEarned(jsonNode.path("points").asInt(15));
            response.setIsCompleted(jsonNode.path("isCompleted").asBoolean(false));

            // Parser les choix
            List<String> choices = new ArrayList<>();
            var choicesArray = jsonNode.path("choices");
            if (choicesArray.isArray()) {
                choicesArray.forEach(choice -> choices.add(choice.asText()));
            }
            response.setChoices(choices);

            // Parser les points pour chaque choix (nouveau format)
            List<Integer> choicePoints = new ArrayList<>();
            var pointsArray = jsonNode.path("points");
            if (pointsArray.isArray()) {
                pointsArray.forEach(points -> choicePoints.add(points.asInt(10))); // défaut 10 points
            } else if (pointsArray.isInt()) {
                // Compatibilité ancien format : si c'est un seul nombre, l'utiliser pour tous les choix
                int singlePoints = pointsArray.asInt(15);
                for (int i = 0; i < choices.size(); i++) {
                    choicePoints.add(singlePoints);
                }
            } else {
                // Si pas de points définis, utiliser des valeurs par défaut
                for (int i = 0; i < choices.size(); i++) {
                    choicePoints.add(15); // défaut 15 points par choix
                }
            }
            response.setChoicePoints(choicePoints);

            return response;
        } catch (JsonProcessingException e) {
            log.error("Error parsing JSON choice response: ", e);
            throw new RuntimeException("Invalid JSON response from AI service");
        }
    }

    // Classes internes pour parser les réponses JSON
    private static class StoryResponse {
        private String title;
        private String content;
        private List<String> choices;
        private List<Integer> choicePoints;
        private Integer points = 0;
        private Boolean isCompleted = false;

        // Getters et setters
        public String getTitle() { return title != null ? title : "Aventure Écologique"; }
        public void setTitle(String title) { this.title = title; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public void setStory(String story) { this.content = story; } // Compatibilité
        public List<String> getChoices() { return choices != null ? choices : Arrays.asList("Continuer", "Explorer", "Réfléchir"); }
        public void setChoices(List<String> choices) { this.choices = choices; }
        public List<Integer> getChoicePoints() { return choicePoints != null ? choicePoints : Arrays.asList(15, 15, 15); }
        public void setChoicePoints(List<Integer> choicePoints) { this.choicePoints = choicePoints; }
        public Integer getPoints() { return points != null ? points : 0; }
        public void setPoints(Integer points) { this.points = points; }
        public Boolean getIsCompleted() { return isCompleted != null ? isCompleted : false; }
        public void setIsCompleted(Boolean isCompleted) { this.isCompleted = isCompleted; }
    }

    private static class ChoiceResponse extends StoryResponse {
        private Boolean isCompleted = false;
        private Integer pointsEarned = 0;

        public Boolean getIsCompleted() { return isCompleted; }
        public void setIsCompleted(Boolean isCompleted) { this.isCompleted = isCompleted; }
        public Integer getPointsEarned() { return pointsEarned; }
        public void setPointsEarned(Integer pointsEarned) { this.pointsEarned = pointsEarned; }
    }

    // ========== MÉTHODES POUR LA GESTION DE L'HISTORIQUE ==========

    @Transactional
    public StoryHistoryListResponse getStoryHistory(String username, int page, int size) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Récupérer l'historique
        List<StoryHistory> stories = storyHistoryRepository.findByUserOrderByCompletedAtDesc(user);

        // Pagination simple
        int startIndex = Math.min(page * size, stories.size());
        int endIndex = Math.min(startIndex + size, stories.size());
        List<StoryHistory> paginatedStories = stories.subList(startIndex, endIndex);

        // Convertir en DTOs
        List<StoryHistoryResponse> storyResponses = paginatedStories.stream()
                .map(StoryHistoryResponse::new)
                .toList();

        // Calculer les statistiques
        Long completedCount = storyHistoryRepository.countByUserAndStatus(user, StoryHistory.StoryStatus.COMPLETED);
        Long totalPoints = storyHistoryRepository.sumTotalPointsByUser(user);
        Long totalCount = (long) stories.size();

        StoryHistoryListResponse.StoryHistoryStatsResponse stats =
                new StoryHistoryListResponse.StoryHistoryStatsResponse(completedCount, totalPoints, totalCount);

        return new StoryHistoryListResponse(storyResponses, stats);
    }

    @Transactional
    public StoryHistoryResponse saveStoryHistory(SaveStoryHistoryRequest request, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Vérifier si l'histoire existe déjà
        if (storyHistoryRepository.existsBySessionIdAndUser(request.getSessionId(), user)) {
            throw new RuntimeException("Story history already exists for this session");
        }

        // Créer l'entité
        StoryHistory storyHistory = new StoryHistory();
        storyHistory.setUser(user);
        storyHistory.setSessionId(request.getSessionId());
        storyHistory.setTitle(request.getTitle());
        storyHistory.setSummary(request.getSummary());
        storyHistory.setTotalPoints(request.getTotalPoints());
        storyHistory.setChapterCount(request.getChapterCount());
        storyHistory.setStatus(StoryHistory.StoryStatus.valueOf(request.getStatus().toUpperCase()));
        storyHistory.setTheme(request.getTheme() != null ? request.getTheme() : "general");

        storyHistory = storyHistoryRepository.save(storyHistory);

        log.info("Saved story history for user {} with session {}", username, request.getSessionId());

        return new StoryHistoryResponse(storyHistory);
    }

    public StoryHistoryResponse getStoryHistoryDetails(String sessionId, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        StoryHistory storyHistory = storyHistoryRepository.findBySessionIdAndUser(sessionId, user)
                .orElseThrow(() -> new RuntimeException("Story history not found"));

        return new StoryHistoryResponse(storyHistory);
    }

    private void saveCompletedStoryToHistory(NarrativeSession session, User user, ChoiceResponse choiceResponse) {
        try {
            // Éviter les doublons
            if (storyHistoryRepository.existsBySessionIdAndUser(session.getSessionId(), user)) {
                log.info("Story history already exists for session {}", session.getSessionId());
                return;
            }

            // Extraire le titre et le résumé depuis le contenu de l'histoire
            String[] titleAndContent = separateTitleAndContent(session.getCurrentStory());

            StoryHistory storyHistory = new StoryHistory();
            storyHistory.setUser(user);
            storyHistory.setSessionId(session.getSessionId());
            storyHistory.setTitle(titleAndContent[0]);
            storyHistory.setSummary(createSummary(titleAndContent[1]));
            storyHistory.setTotalPoints(user.getPoints()); // Points totaux actuels de l'utilisateur
            storyHistory.setChapterCount(session.getStepCount());
            storyHistory.setStatus(StoryHistory.StoryStatus.COMPLETED);
            storyHistory.setTheme(extractThemeFromContent(session.getCurrentStory()));

            storyHistoryRepository.save(storyHistory);

            log.info("Auto-saved completed story to history for user {} with session {}",
                    user.getUsername(), session.getSessionId());

        } catch (Exception e) {
            log.error("Error saving completed story to history: ", e);
            // Ne pas faire échouer l'histoire principale si la sauvegarde de l'historique échoue
        }
    }

    private String createSummary(String content) {
        if (content == null || content.trim().isEmpty()) {
            return "Une aventure écologique passionnante !";
        }

        // Créer un résumé de 100 caractères max
        String summary = content.length() > 100
            ? content.substring(0, 100).trim() + "..."
            : content.trim();

        return summary;
    }

    private String extractThemeFromContent(String content) {
        if (content == null) return "general";

        String contentLower = content.toLowerCase();

        if (contentLower.matches(".*\\b(transport|voiture|vélo|bus|train|avion)\\b.*")) {
            return "transport";
        } else if (contentLower.matches(".*\\b(énergie|électricité|chauffage|solaire|éolienne)\\b.*")) {
            return "energy";
        } else if (contentLower.matches(".*\\b(nourriture|alimentation|bio|local|végétarien)\\b.*")) {
            return "food";
        } else if (contentLower.matches(".*\\b(déchet|recyclage|plastique|tri)\\b.*")) {
            return "waste";
        } else if (contentLower.matches(".*\\b(eau|robinet|douche|pluie)\\b.*")) {
            return "water";
        } else if (contentLower.matches(".*\\b(nature|forêt|animal|biodiversité)\\b.*")) {
            return "biodiversity";
        }

        return "general";
    }

    private String extractChoiceText(String currentStory, String choice) {
        try {
            // Si le choix est un nombre (index), extraire le texte du choix correspondant
            int choiceIndex = Integer.parseInt(choice);

            // Parser les choix depuis l'histoire actuelle
            if (currentStory != null) {
                // Essayer de parser le JSON d'abord
                try {
                    var jsonNode = objectMapper.readTree(currentStory);
                    var choicesArray = jsonNode.path("choices");
                    if (choicesArray.isArray() && choiceIndex >= 0 && choiceIndex < choicesArray.size()) {
                        return choicesArray.get(choiceIndex).asText();
                    }
                } catch (Exception e) {
                    // Fallback vers l'ancien format si JSON échoue
                    if (currentStory.contains("Choix:")) {
                        int choixStart = currentStory.indexOf("Choix:");
                        String choixSection = currentStory.substring(choixStart + 6).trim();
                        String[] rawChoices = choixSection.split("\\|");

                        if (choiceIndex >= 0 && choiceIndex < rawChoices.length) {
                            return rawChoices[choiceIndex].trim();
                        }
                    }
                }
            }

            // Si on ne peut pas extraire le choix, retourner un choix générique
            return "Choix " + (choiceIndex + 1);

        } catch (NumberFormatException e) {
            // Si ce n'est pas un nombre, c'est déjà le texte du choix
            return choice;
        }
    }

    private Integer extractPointsForChoice(String currentStory, String choice) {
        try {
            // Si le choix est un nombre (index), extraire les points correspondants
            int choiceIndex = Integer.parseInt(choice);

            // Parser les points depuis l'histoire actuelle
            if (currentStory != null) {
                try {
                    var jsonNode = objectMapper.readTree(currentStory);
                    var pointsArray = jsonNode.path("points");
                    if (pointsArray.isArray() && choiceIndex >= 0 && choiceIndex < pointsArray.size()) {
                        return pointsArray.get(choiceIndex).asInt(15); // défaut 15 points
                    }
                } catch (Exception e) {
                    log.warn("Could not parse points from current story JSON");
                }
            }

            // Si on ne peut pas extraire les points, retourner une valeur par défaut
            return 15;

        } catch (NumberFormatException e) {
            // Si ce n'est pas un nombre, retourner une valeur par défaut
            return 15;
        }
    }

    // 🛡️ CLASSE UTILITAIRE POUR PARSING ROBUSTE
    private static class RobustParser {
        private static final Pattern TITLE_PATTERN = Pattern.compile("(?i)(?:titre?|title)\\s*[:|=]\\s*([^|\\n]+?)\\s*(?:[|\\n]|$)");
        private static final Pattern CONTENT_PATTERN = Pattern.compile("(?i)(?:situation|content|story)\\s*[:|=]\\s*([^|]+?)\\s*(?:[|\\n].*choix|[|\\n].*choice|$)", Pattern.DOTALL);
        private static final Pattern CHOICES_PATTERN = Pattern.compile("(?i)(?:choix|choice)\\s*[:|=]\\s*(.+?)(?:[|\\n].*points?|$)", Pattern.DOTALL);
        private static final Pattern POINTS_PATTERN = Pattern.compile("(?i)points?\\s*[:|=]\\s*(\\d+)");

        public static StoryData parseStoryResponse(String response, boolean isChoice) {
            if (response == null || response.trim().isEmpty()) {
                return createFallbackStory(isChoice);
            }

            StoryData story = new StoryData();

            // 🚀 ÉTAPE 1 : Nettoyer la réponse
            String cleanResponse = response.trim()
                .replaceAll("\\*+", "")  // Supprimer les astérisques
                .replaceAll("\\#+", "")  // Supprimer les hashtags
                .replaceAll("```\\w*", "") // Supprimer les blocs de code
                .replaceAll("\\n\\s*\\n", "\n"); // Normaliser les sauts de ligne

            // 🚀 ÉTAPE 2 : Parser avec regex robustes
            story.title = extractWithPattern(TITLE_PATTERN, cleanResponse,
                isChoice ? "Suite de l'Histoire" : "Nouvelle Aventure Écologique");
            story.content = extractWithPattern(CONTENT_PATTERN, cleanResponse,
                "Une situation écologique intéressante se présente à vous...");
            story.choices = extractChoices(cleanResponse);
            story.points = extractPoints(cleanResponse, isChoice);
            story.isCompleted = story.choices.isEmpty();

            // 🚀 ÉTAPE 3 : Validation et nettoyage
            validateAndCleanStory(story, isChoice);

            return story;
        }

        private static String extractWithPattern(Pattern pattern, String text, String defaultValue) {
            try {
                Matcher matcher = pattern.matcher(text);
                if (matcher.find()) {
                    String extracted = matcher.group(1).trim();
                    return extracted.isEmpty() ? defaultValue : extracted;
                }
            } catch (Exception e) {
                // Log silencieusement et continuer
            }
            return defaultValue;
        }

        private static List<String> extractChoices(String text) {
            List<String> choices = new ArrayList<>();

            try {
                Matcher matcher = CHOICES_PATTERN.matcher(text);
                if (matcher.find()) {
                    String choicesText = matcher.group(1).trim();

                    // 🚀 PARSING MULTIPLE : Essayer différents formats
                    // Format 1: Séparés par |
                    String[] splitByPipe = choicesText.split("\\|");
                    if (splitByPipe.length >= 2) {
                        for (String choice : splitByPipe) {
                            String clean = choice.trim().replaceAll("^[\"'\\[\\(]|[\"'\\]\\)]$", "");
                            if (!clean.isEmpty() && clean.length() > 3) {
                                choices.add(clean);
                            }
                        }
                    }

                    // Format 2: Liste numérotée/lettrée
                    if (choices.size() < 2) {
                        choices.clear();
                        Pattern listPattern = Pattern.compile("(?:^|\\n)\\s*[\\da-zA-Z][.)]\\s*(.+?)(?=\\n\\s*[\\da-zA-Z][.)]|$)", Pattern.MULTILINE);
                        Matcher listMatcher = listPattern.matcher(choicesText);
                        while (listMatcher.find()) {
                            String choice = listMatcher.group(1).trim();
                            if (!choice.isEmpty() && choice.length() > 3) {
                                choices.add(choice);
                            }
                        }
                    }

                    // Format 3: Lignes séparées
                    if (choices.size() < 2) {
                        choices.clear();
                        String[] lines = choicesText.split("\\n");
                        for (String line : lines) {
                            String clean = line.trim().replaceAll("^[-•*]\\s*", "");
                            if (!clean.isEmpty() && clean.length() > 5) {
                                choices.add(clean);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                // Log et continuer avec fallback
            }

            // 🚀 VALIDATION ET LIMITATION
            choices = choices.stream()
                .filter(c -> c != null && c.length() >= 3 && c.length() <= 100)
                .limit(3)
                .collect(java.util.stream.Collectors.toList());

            return choices;
        }

        private static int extractPoints(String text, boolean isChoice) {
            try {
                Matcher matcher = POINTS_PATTERN.matcher(text);
                if (matcher.find()) {
                    int points = Integer.parseInt(matcher.group(1));
                    return Math.max(0, Math.min(35, points)); // Clamp entre 0-35
                }
            } catch (Exception e) {
                // Ignorer et utiliser défaut
            }
            return isChoice ? 15 : 0; // Défaut différent selon contexte
        }

        private static void validateAndCleanStory(StoryData story, boolean isChoice) {
            // 🚀 VALIDATION TITRE
            if (story.title == null || story.title.trim().isEmpty() || story.title.length() > 60) {
                story.title = isChoice ? "Suite de l'Histoire" : "Nouvelle Aventure Écologique";
            }

            // 🚀 VALIDATION CONTENU
            if (story.content == null || story.content.trim().isEmpty()) {
                story.content = "Une nouvelle situation écologique se présente. Que décidez-vous de faire ?";
            } else if (story.content.length() > 500) {
                story.content = story.content.substring(0, 497) + "...";
            }

            // 🚀 VALIDATION CHOIX
            if (story.choices.isEmpty() && !story.isCompleted) {
                story.choices = Arrays.asList(
                    "Analyser la situation plus en détail",
                    "Agir immédiatement",
                    "Consulter des experts"
                );
            }

            // 🚀 VALIDATION POINTS
            if (story.points < 0 || story.points > 35) {
                story.points = isChoice ? 15 : 0;
            }
        }

        private static StoryData createFallbackStory(boolean isChoice) {
            StoryData fallback = new StoryData();
            fallback.title = isChoice ? "Suite de l'Histoire" : "Défi Écologique";
            fallback.content = "Face à cette situation environnementale, plusieurs options s'offrent à vous. Chaque choix aura un impact différent sur l'écosystème.";
            fallback.choices = Arrays.asList(
                "Privilégier une solution durable",
                "Chercher un compromis équilibré",
                "Évaluer toutes les alternatives"
            );
            fallback.points = isChoice ? 15 : 0;
            fallback.isCompleted = false;
            return fallback;
        }
    }

    // 🛡️ CLASSE DE DONNÉES POUR PARSING
    private static class StoryData {
        String title;
        String content;
        List<String> choices = new ArrayList<>();
        int points;
        boolean isCompleted;
    }
}