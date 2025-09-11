package sn.codiallo.ecoBuddy.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import sn.codiallo.ecoBuddy.dto.GeminiRequest;
import sn.codiallo.ecoBuddy.dto.GeminiResponse;

import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class GeminiService {

    private final WebClient webClient;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.base-url}")
    private String baseUrl;

    public String generateNarrative(String context, List<String> choices) {
        try {
            String prompt = buildPrompt(context, choices);
            GeminiRequest request = buildGeminiRequest(prompt);
            
            GeminiResponse response = webClient.post()
                    .uri(baseUrl + "/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey)
                    .header("Content-Type", "application/json")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(GeminiResponse.class)
                    .block();

            return extractTextFromResponse(response);
            
        } catch (Exception e) {
            log.error("Error calling Gemini API: ", e);
            return generateFallbackNarrative(context);
        }
    }

    public String generateStoryStart() {
        String prompt = "Tu es un conteur d'histoires interactives sur le thème écologique. " +
                       "Crée une histoire engageante avec EXACTEMENT ce format (respecte scrupuleusement les | et les séparateurs) : " +
                       "Titre: [un titre accrocheur] | Situation: [une description de 100-150 mots de la situation écologique] | " +
                       "Choix: [premier choix d'action]|[deuxième choix d'action]|[troisième choix d'action]" +
                       "\n\nIMPORTANT: Tu dois absolument fournir exactement 3 choix séparés par des | sans espaces autour.";
        try {
            GeminiRequest request = buildGeminiRequest(prompt);
            
            GeminiResponse response = webClient.post()
                    .uri(baseUrl + "/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey)
                    .header("Content-Type", "application/json")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(GeminiResponse.class)
                    .block();

            return extractTextFromResponse(response);
            
        } catch (Exception e) {
            log.error("Error calling Gemini API for story start: ", e);
            return generateFallbackStoryStart();
        }
    }

    private String buildPrompt(String context, List<String> choices) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("L'utilisateur joue un scénario climatique interactif. ");
        prompt.append("Situation précédente: ").append(context).append(". ");
        prompt.append("Choix fait par l'utilisateur: ").append(choices.get(0)).append(". ");
        
        prompt.append("Tu dois évaluer ce choix et générer la suite. ");
        prompt.append("Attribue des points selon la pertinence écologique du choix : ");
        prompt.append("- 30+ points : Excellent choix écologique (durable, innovant, impactant)");
        prompt.append("- 20-29 points : Bon choix (écologiquement responsable)");
        prompt.append("- 10-19 points : Choix moyen (quelques bénéfices environnementaux)");
        prompt.append("- 5-9 points : Choix peu optimal (impact limité)");
        prompt.append("- 0-4 points : Choix problématique (peu ou pas écologique)");
        
        prompt.append("\nFormat EXACT à respecter : ");
        prompt.append("Titre: [titre] | Situation: [description incluant les conséquences du choix] | ");
        prompt.append("Choix: [choix1]|[choix2]|[choix3] | Points: [nombre entre 0-35]");
        prompt.append("\nIMPORTANT: Respecte scrupuleusement ce format avec les | et fournis exactement 3 nouveaux choix.");
        
        return prompt.toString();
    }

    private GeminiRequest buildGeminiRequest(String prompt) {
        GeminiRequest request = new GeminiRequest();
        
        GeminiRequest.Content content = new GeminiRequest.Content();
        GeminiRequest.Part part = new GeminiRequest.Part();
        part.setText(prompt);
        content.setParts(List.of(part));
        
        request.setContents(List.of(content));
        
        // Configuration de génération
        GeminiRequest.GenerationConfig config = new GeminiRequest.GenerationConfig();
        config.setTemperature(0.7);
        config.setTopK(40);
        config.setTopP(0.95);
        config.setMaxOutputTokens(1024);
        request.setGenerationConfig(config);
        
        // Paramètres de sécurité
        GeminiRequest.SafetySetting safetySetting = new GeminiRequest.SafetySetting();
        safetySetting.setCategory("HARM_CATEGORY_HARASSMENT");
        safetySetting.setThreshold("BLOCK_MEDIUM_AND_ABOVE");
        request.setSafetySettings(List.of(safetySetting));
        
        return request;
    }

    private String extractTextFromResponse(GeminiResponse response) {
        if (response != null && 
            response.getCandidates() != null && 
            !response.getCandidates().isEmpty()) {
            
            GeminiResponse.Candidate candidate = response.getCandidates().get(0);
            if (candidate.getContent() != null && 
                candidate.getContent().getParts() != null && 
                !candidate.getContent().getParts().isEmpty()) {
                
                return candidate.getContent().getParts().get(0).getText();
            }
        }
        
        throw new RuntimeException("No valid response from Gemini API");
    }

    private String generateFallbackNarrative(String context) {
        return "Titre: Défi Écologique | " +
               "Situation: Suite à votre action, de nouveaux défis environnementaux apparaissent. " +
               "La situation évolue et vous devez prendre une nouvelle décision importante pour " +
               "préserver l'écosystème. Vos choix précédents ont eu un impact et influencent " +
               "maintenant les options disponibles. | " +
               "Choix: Analyser l'impact de vos actions précédentes|" +
               "Consulter des experts environnementaux|" +
               "Agir immédiatement selon votre instinct";
    }

    private String generateFallbackStoryStart() {
        return "Titre: La Forêt en Danger | " +
               "Situation: Vous vous promenez dans une magnifique forêt lorsque vous découvrez " +
               "une rivière polluée par des déchets plastiques. Des animaux vous regardent avec espoir, " +
               "semblant attendre votre aide. Cette pollution menace tout l'écosystème local. " +
               "Que décidez-vous de faire ? | " +
               "Choix: Commencer immédiatement à ramasser les déchets|" +
               "Retourner au village pour organiser une équipe de nettoyage|" +
               "Prendre des photos pour sensibiliser sur les réseaux sociaux";
    }
}