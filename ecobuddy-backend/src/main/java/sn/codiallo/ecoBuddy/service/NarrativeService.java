package sn.codiallo.ecoBuddy.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import sn.codiallo.ecoBuddy.dto.*;
import sn.codiallo.ecoBuddy.model.NarrativeSession;
import sn.codiallo.ecoBuddy.model.User;
import sn.codiallo.ecoBuddy.repository.NarrativeSessionRepository;
import sn.codiallo.ecoBuddy.repository.UserRepository;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class NarrativeService {

    private final WebClient geminiWebClient;
    private final GeminiService geminiService;
    private final NarrativeSessionRepository narrativeSessionRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    @Value("${gemini.api.key}")
    private String geminiApiKey;

    private static final String INITIAL_PROMPT = """
        Tu es un narrateur interactif spécialisé dans les histoires environnementales et écologiques.
        Crée une histoire interactive courte (3-5 étapes) sur le changement climatique et l'écologie.
        L'histoire doit être engageante, éducative et adaptée à tous les âges.
        
        À chaque étape, présente une situation et propose exactement 3 choix possibles.
        Format de réponse requis (JSON):
        {
          "story": "Texte de l'histoire à cette étape",
          "choices": ["Choix 1", "Choix 2", "Choix 3"]
        }
        
        Commence maintenant une nouvelle histoire :
        """;

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
            StoryResponse storyResponse = parseGeminiStoryResponse(responseText);
            
            session.setCurrentStory(storyResponse.getStory());
            session.setConversationHistory(updateConversationHistory("[]", "Start story", responseText));
            
            narrativeSessionRepository.save(session);

            // Générer un ID unique pour cette étape
            String storyId = UUID.randomUUID().toString();
            
            // Séparer titre et contenu
            String[] titleAndContent = separateTitleAndContent(storyResponse.getStory());
            
            return new NarrativeStartResponse(
                    storyId,
                    sessionId,
                    titleAndContent[0], // title
                    titleAndContent[1], // content
                    storyResponse.getChoices(),
                    session.getStepCount() + 1, // chapterNumber (commence à 1)
                    user.getPoints(), // points actuels de l'utilisateur
                    false // isCompleted - false au début
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
            // Utiliser GeminiService pour générer la suite de l'histoire
            String responseText = geminiService.generateNarrative(session.getCurrentStory(), List.of(choice));
            ChoiceResponse choiceResponse = parseGeminiChoiceResponse(responseText);
            
            session.setCurrentStory(choiceResponse.getStory());
            session.setStepCount(session.getStepCount() + 1);
            session.setConversationHistory(updateConversationHistory(session.getConversationHistory(), choice, responseText));

            // Attribuer les points IMMÉDIATEMENT après le choix
            Integer pointsEarned = choiceResponse.getPointsEarned();
            if (pointsEarned > 0) {
                user.setPoints(user.getPoints() + pointsEarned);
                userRepository.save(user);
                log.info("User {} earned {} points for choice: {}", username, pointsEarned, choice);
            }

            // Marquer l'histoire comme terminée si nécessaire
            if (choiceResponse.getIsCompleted()) {
                session.setIsActive(false);
                log.info("Story completed for user {}", username);
            }

            narrativeSessionRepository.save(session);

            // Générer un ID unique pour cette étape
            String storyId = UUID.randomUUID().toString();
            
            // Séparer titre et contenu
            String[] titleAndContent = separateTitleAndContent(choiceResponse.getStory());
            
            return new NarrativeChoiceResponse(
                    storyId,
                    sessionId,
                    titleAndContent[0], // title
                    titleAndContent[1], // content
                    choiceResponse.getChoices(),
                    session.getStepCount(), // chapterNumber
                    user.getPoints(), // points totaux actualisés
                    choiceResponse.getIsCompleted()
            );

        } catch (Exception e) {
            log.error("Error processing choice: ", e);
            throw new RuntimeException("Failed to process choice: " + e.getMessage());
        }
    }

    private GeminiRequest createGeminiRequest(String prompt) {
        GeminiRequest.Part part = new GeminiRequest.Part(prompt);
        GeminiRequest.Content content = new GeminiRequest.Content(List.of(part));
        return new GeminiRequest(List.of(content), null, null);
    }

    private GeminiResponse callGeminiApi(GeminiRequest request) {
        return geminiWebClient
                .post()
                .uri("/v1beta/models/gemini-1.5-flash:generateContent?key=" + geminiApiKey)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(GeminiResponse.class)
                .block();
    }

    private String extractTextFromResponse(GeminiResponse response) {
        return response.getCandidates().get(0)
                .getContent()
                .getParts().get(0)
                .getText();
    }

    private StoryResponse parseGeminiStoryResponse(String responseText) {
        try {
            StoryResponse response = new StoryResponse();
            
            // Parser le format "Titre: xxx | Situation: xxx | Choix: choix1 | choix2 | choix3"
            if (responseText.contains("Titre:") && responseText.contains("Situation:") && responseText.contains("Choix:")) {
                
                // Extraire le titre
                String title = "";
                int titleStart = responseText.indexOf("Titre:");
                int titleEnd = responseText.indexOf("|", titleStart);
                if (titleStart != -1 && titleEnd != -1) {
                    title = responseText.substring(titleStart + 6, titleEnd).trim();
                }
                
                // Extraire la situation
                String situation = "";
                int situationStart = responseText.indexOf("Situation:");
                int situationEnd = responseText.indexOf("| Choix:");
                if (situationStart != -1 && situationEnd != -1) {
                    situation = responseText.substring(situationStart + 10, situationEnd).trim();
                }
                
                response.setStory(title + "\n\n" + situation);
                
                // Extraire les choix - NOUVEAU PARSING
                List<String> choices = new ArrayList<>();
                int choixStart = responseText.indexOf("Choix:");
                if (choixStart != -1) {
                    String choixSection = responseText.substring(choixStart + 6).trim();
                    
                    // Split par | et nettoyer
                    String[] rawChoices = choixSection.split("\\|");
                    for (String choice : rawChoices) {
                        String cleanChoice = choice.trim();
                        if (!cleanChoice.isEmpty()) {
                            choices.add(cleanChoice);
                        }
                    }
                }
                
                // Vérifier qu'on a au moins 3 choix
                if (choices.size() >= 3) {
                    response.setChoices(choices.subList(0, Math.min(3, choices.size())));
                } else {
                    // Fallback avec des choix par défaut
                    response.setChoices(Arrays.asList("Continuer", "Explorer", "Analyser"));
                }
                
            } else {
                response.setStory(responseText);
                response.setChoices(Arrays.asList("Continuer", "Explorer", "Analyser"));
            }
            
            return response;
        } catch (Exception e) {
            log.warn("Error parsing Gemini story response, using fallback: ", e);
            StoryResponse fallback = new StoryResponse();
            fallback.setStory(responseText);
            fallback.setChoices(Arrays.asList("Continuer", "Explorer", "Analyser"));
            return fallback;
        }
    }

    private ChoiceResponse parseGeminiChoiceResponse(String responseText) {
        try {
            ChoiceResponse response = new ChoiceResponse();
            
            if (responseText.contains("Titre:") && responseText.contains("Situation:") && responseText.contains("Choix:")) {
                
                // Extraire le titre
                String title = "";
                int titleStart = responseText.indexOf("Titre:");
                int titleEnd = responseText.indexOf("|", titleStart);
                if (titleStart != -1 && titleEnd != -1) {
                    title = responseText.substring(titleStart + 6, titleEnd).trim();
                }
                
                // Extraire la situation
                String situation = "";
                int situationStart = responseText.indexOf("Situation:");
                int situationEnd = responseText.indexOf("| Choix:");
                if (situationStart != -1 && situationEnd != -1) {
                    situation = responseText.substring(situationStart + 10, situationEnd).trim();
                } else {
                    // Si pas de "| Choix:", prendre jusqu'à "| Points:" ou fin
                    int pointsPos = responseText.indexOf("| Points:");
                    if (pointsPos != -1) {
                        situation = responseText.substring(situationStart + 10, pointsPos).trim();
                    } else {
                        situation = responseText.substring(situationStart + 10).trim();
                    }
                }
                
                response.setStory(title + "\n\n" + situation);
                
                // Extraire les choix
                List<String> choices = new ArrayList<>();
                int choixStart = responseText.indexOf("Choix:");
                if (choixStart != -1) {
                    int pointsStart = responseText.indexOf("| Points:");
                    String choixSection;
                    if (pointsStart != -1) {
                        choixSection = responseText.substring(choixStart + 6, pointsStart).trim();
                    } else {
                        choixSection = responseText.substring(choixStart + 6).trim();
                    }
                    
                    // Split par | et nettoyer
                    String[] rawChoices = choixSection.split("\\|");
                    for (String choice : rawChoices) {
                        String cleanChoice = choice.trim();
                        if (!cleanChoice.isEmpty()) {
                            choices.add(cleanChoice);
                        }
                    }
                }
                
                // Extraire les points
                Integer pointsEarned = 15; // Default
                int pointsStart = responseText.indexOf("Points:");
                if (pointsStart != -1) {
                    try {
                        String pointsSection = responseText.substring(pointsStart + 7).trim();
                        // Prendre seulement les premiers chiffres
                        String pointsStr = pointsSection.replaceAll("[^0-9].*", "");
                        if (!pointsStr.isEmpty()) {
                            pointsEarned = Integer.parseInt(pointsStr);
                        }
                    } catch (NumberFormatException e) {
                        log.warn("Could not parse points from response");
                    }
                }
                
                // Si pas de choix, l'histoire est terminée
                if (choices.isEmpty()) {
                    response.setIsCompleted(true);
                    response.setPointsEarned(pointsEarned + 10); // Bonus completion
                    response.setChoices(Arrays.asList());
                } else {
                    response.setChoices(choices.size() >= 3 ? choices.subList(0, 3) : choices);
                    response.setIsCompleted(false);
                    response.setPointsEarned(pointsEarned);
                }
                
            } else {
                response.setStory(responseText);
                response.setChoices(Arrays.asList());
                response.setIsCompleted(true);
                response.setPointsEarned(25);
            }
            
            return response;
        } catch (Exception e) {
            log.warn("Error parsing Gemini choice response, using fallback: ", e);
            ChoiceResponse fallback = new ChoiceResponse();
            fallback.setStory(responseText);
            fallback.setChoices(Arrays.asList());
            fallback.setIsCompleted(true);
            fallback.setPointsEarned(15);
            return fallback;
        }
    }

    private String extractJsonFromText(String text) {
        int jsonStart = text.indexOf("{");
        int jsonEnd = text.lastIndexOf("}") + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
            return text.substring(jsonStart, jsonEnd);
        }
        return text;
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

    // Classes internes pour parser les réponses JSON
    private static class StoryResponse {
        private String story;
        private List<String> choices;

        // Getters et setters
        public String getStory() { return story; }
        public void setStory(String story) { this.story = story; }
        public List<String> getChoices() { return choices != null ? choices : Arrays.asList("Continuer", "Explorer", "Réfléchir"); }
        public void setChoices(List<String> choices) { this.choices = choices; }
    }

    private static class ChoiceResponse extends StoryResponse {
        private Boolean isCompleted = false;
        private Integer pointsEarned = 0;

        public Boolean getIsCompleted() { return isCompleted; }
        public void setIsCompleted(Boolean isCompleted) { this.isCompleted = isCompleted; }
        public Integer getPointsEarned() { return pointsEarned; }
        public void setPointsEarned(Integer pointsEarned) { this.pointsEarned = pointsEarned; }
    }
}