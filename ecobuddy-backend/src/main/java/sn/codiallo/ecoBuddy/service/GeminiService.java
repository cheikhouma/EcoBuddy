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
        String prompt = "You are an interactive storytelling narrator focused on ecology. " +
                "RESPOND ONLY IN VALID JSON FORMAT. No additional text before or after the JSON. " +
                "Create an engaging ecological story with this exact JSON structure:\n" +
                "{\n" +
                "  \"title\": \"A catchy title (max 50 characters)\",\n" +
                "  \"content\": \"A 100-150 word description of the ecological situation\",\n" +
                "  \"choices\": [\"First action choice\", \"Second action choice\", \"Third action choice\"],\n" +
                "  \"points\": 0,\n" +
                "  \"isCompleted\": false\n" +
                "}\n\n" +
                "IMPORTANT: Provide exactly 3 engaging choices. Make the story educational and inspiring about environmental action.";
        
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
            return generateFallbackStoryStartJSON();
        }
    }

    private String buildPrompt(String context, List<String> choices) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("You are an interactive storytelling narrator focused on ecology. ");
        prompt.append("RESPOND ONLY IN VALID JSON FORMAT. No additional text before or after the JSON.\n");
        prompt.append("Previous situation: ").append(context).append("\n");
        prompt.append("User's choice: ").append(choices.get(0)).append("\n\n");
        
        prompt.append("Evaluate this choice and generate the next scene. Assign points based on ecological relevance:\n");
        prompt.append("- 30+ points: Excellent ecological choice (sustainable, innovative, impactful)\n");
        prompt.append("- 20-29 points: Good choice (environmentally responsible)\n");
        prompt.append("- 10-19 points: Average choice (some environmental benefits)\n");
        prompt.append("- 5-9 points: Suboptimal choice (limited impact)\n");
        prompt.append("- 0-4 points: Problematic choice (little or no ecological value)\n\n");
        
        prompt.append("Respond with this exact JSON structure:\n");
        prompt.append("{\n");
        prompt.append("  \"title\": \"Chapter title (max 50 characters)\",\n");
        prompt.append("  \"content\": \"Story continuation describing consequences of the choice (100-150 words)\",\n");
        prompt.append("  \"choices\": [\"Choice 1\", \"Choice 2\", \"Choice 3\"],\n");
        prompt.append("  \"points\": [number between 0-35],\n");
        prompt.append("  \"isCompleted\": false\n");
        prompt.append("}\n\n");
        prompt.append("If the story should end, set isCompleted to true and provide empty choices array.");

        return prompt.toString();
    }

    private GeminiRequest buildGeminiRequest(String prompt) {
        GeminiRequest request = new GeminiRequest();

        GeminiRequest.Content content = new GeminiRequest.Content();
        GeminiRequest.Part part = new GeminiRequest.Part();
        part.setText(prompt);
        content.setParts(List.of(part));

        request.setContents(List.of(content));

        GeminiRequest.GenerationConfig config = new GeminiRequest.GenerationConfig();
        config.setTemperature(0.7);
        config.setTopK(40);
        config.setTopP(0.95);
        config.setMaxOutputTokens(1024);
        request.setGenerationConfig(config);

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
        return "Title: Ecological Challenge | " +
                "Situation: Following your action, new environmental challenges arise. " +
                "The situation evolves, and you must make a critical decision to " +
                "preserve the ecosystem. Your previous choices have had an impact and now influence " +
                "the available options. | " +
                "Choices: Analyze the impact of your previous actions|" +
                "Consult environmental experts|" +
                "Act immediately based on your instinct";
    }

    private String generateFallbackStoryStart() {
        return "Title: Forest in Danger | " +
                "Situation: You are walking through a beautiful forest when you discover " +
                "a river polluted with plastic waste. Animals look at you with hope, " +
                "seemingly waiting for your help. This pollution threatens the entire local ecosystem. " +
                "What will you decide to do? | " +
                "Choices: Start immediately to collect the waste|" +
                "Return to the village to organize a cleanup team|" +
                "Take photos to raise awareness on social media";
    }
    
    private String generateFallbackStoryStartJSON() {
        return "{\n" +
                "  \"title\": \"Forest in Danger\",\n" +
                "  \"content\": \"You are walking through a beautiful forest when you discover a river polluted with plastic waste. Animals look at you with hope, seemingly waiting for your help. This pollution threatens the entire local ecosystem. What will you decide to do?\",\n" +
                "  \"choices\": [\"Start immediately to collect the waste\", \"Return to the village to organize a cleanup team\", \"Take photos to raise awareness on social media\"],\n" +
                "  \"points\": 0,\n" +
                "  \"isCompleted\": false\n" +
                "}";
    }
    
    public String extractJsonFromResponse(String responseText) {
        if (responseText == null || responseText.trim().isEmpty()) {
            return null;
        }
        
        // Find the first { and last }
        int jsonStart = responseText.indexOf('{');
        int jsonEnd = responseText.lastIndexOf('}');
        
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
            return responseText.substring(jsonStart, jsonEnd + 1);
        }
        
        return null;
    }
}
