package sn.codiallo.ecoBuddy.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import sn.codiallo.ecoBuddy.dto.GeminiRequest;
import sn.codiallo.ecoBuddy.dto.GeminiResponse;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeoutException;

@Service
@Slf4j
@RequiredArgsConstructor
public class GeminiService {

    private final WebClient webClient;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.base-url}")
    private String baseUrl;

    // 🚀 CACHE SIMPLE pour histoires de démarrage
    private final Map<String, CachedStory> storyStartCache = new ConcurrentHashMap<>();
    private static final long CACHE_DURATION_MINUTES = 30;

    private static class CachedStory {
        final String content;
        final LocalDateTime timestamp;

        CachedStory(String content) {
            this.content = content;
            this.timestamp = LocalDateTime.now();
        }

        boolean isExpired() {
            return LocalDateTime.now().minusMinutes(CACHE_DURATION_MINUTES).isAfter(timestamp);
        }
    }

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
                    .timeout(Duration.ofSeconds(12)) // 🚀 TIMEOUT OPTIMISÉ
                    .doOnSubscribe(subscription -> log.info("🤖 Starting Gemini generation..."))
                    .doOnNext(resp -> log.info("✅ Gemini responded in time"))
                    .onErrorResume(TimeoutException.class, ex -> {
                        log.warn("⏰ Gemini timeout, using fallback");
                        return Mono.empty();
                    })
                    .block(Duration.ofSeconds(15)); // 🛡️ BACKUP TIMEOUT

            if (response != null) {
                return extractTextFromResponse(response);
            } else {
                log.warn("🔄 No response from Gemini, using fallback");
                return generateFallbackNarrative(context);
            }

        } catch (Exception e) {
            log.error("❌ Error calling Gemini API: ", e);
            return generateFallbackNarrative(context);
        }
    }

    public String generateStoryStart() {
        // 🚀 VÉRIFIER LE CACHE D'ABORD
        String cacheKey = "story_start";
        CachedStory cached = storyStartCache.get(cacheKey);

        if (cached != null && !cached.isExpired()) {
            log.info("⚡ Using cached story start ({}s old)",
                Duration.between(cached.timestamp, LocalDateTime.now()).getSeconds());
            return cached.content;
        }

        String prompt = "Generate an eco-story. RESPOND ONLY IN JSON:\n" +
                "{\n" +
                "  \"title\": \"Catchy title (max 40 chars)\",\n" +
                "  \"content\": \"40-60 word eco-situation\",\n" +
                "  \"choices\": [\"Action 1\", \"Action 2\", \"Action 3\"],\n" +
                "  \"points\": [25, 15, 10],\n" +
                "  \"isCompleted\": false\n" +
                "}\n" +
                "Make it engaging. Points: 25-35=excellent, 15-24=good, 5-14=average eco impact.";

        try {
            GeminiRequest request = buildGeminiRequest(prompt);

            GeminiResponse response = webClient.post()
                    .uri(baseUrl + "/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey)
                    .header("Content-Type", "application/json")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(GeminiResponse.class)
                    .timeout(Duration.ofSeconds(10)) // 🚀 TIMEOUT PLUS COURT pour story start
                    .doOnSubscribe(subscription -> log.info("🌱 Starting new story generation..."))
                    .doOnNext(resp -> log.info("✅ Story start generated successfully"))
                    .onErrorResume(TimeoutException.class, ex -> {
                        log.warn("⏰ Story start timeout, using fallback");
                        return Mono.empty();
                    })
                    .block(Duration.ofSeconds(12)); // 🛡️ BACKUP TIMEOUT

            if (response != null) {
                String result = extractTextFromResponse(response);
                // 🚀 METTRE EN CACHE LE RÉSULTAT
                storyStartCache.put(cacheKey, new CachedStory(result));
                log.info("💾 Cached new story start for 30 minutes");
                return result;
            } else {
                log.warn("🔄 No response for story start, using fallback");
                String fallback = generateFallbackStoryStartJSON();
                // Cache aussi le fallback (pour éviter les appels répétés)
                storyStartCache.put(cacheKey, new CachedStory(fallback));
                return fallback;
            }

        } catch (Exception e) {
            log.error("❌ Error calling Gemini API for story start: ", e);
            String fallback = generateFallbackStoryStartJSON();
            // Cache le fallback aussi
            storyStartCache.put(cacheKey, new CachedStory(fallback));
            return fallback;
        }
    }

    private String buildPrompt(String context, List<String> choices) {
        // 🚀 PROMPT OPTIMISÉ - Plus court = plus rapide
        return "Continue eco-story. JSON only:\n" +
                "Previous: " + context + "\n" +
                "Choice: " + choices.get(0) + "\n\n" +
                "{\n" +
                "  \"title\": \"Next chapter (max 40 chars)\",\n" +
                "  \"content\": \"60-100 word consequence\",\n" +
                "  \"choices\": [\"Option 1\", \"Option 2\", \"Option 3\"],\n" +
                "  \"points\": 15,\n" +
                "  \"isCompleted\": false\n" +
                "}\n" +
                "Points: 25-35=excellent, 15-24=good, 5-14=average eco impact. End story if natural conclusion.";
    }

    private GeminiRequest buildGeminiRequest(String prompt) {
        GeminiRequest request = new GeminiRequest();

        GeminiRequest.Content content = new GeminiRequest.Content();
        GeminiRequest.Part part = new GeminiRequest.Part();
        part.setText(prompt);
        content.setParts(List.of(part));

        request.setContents(List.of(content));

        GeminiRequest.GenerationConfig config = new GeminiRequest.GenerationConfig();
        config.setTemperature(0.6); // 🚀 Réduire créativité pour plus de rapidité
        config.setTopK(20);          // 🚀 Réduire options pour réponse plus rapide
        config.setTopP(0.8);         // 🚀 Plus focalisé
        config.setMaxOutputTokens(512); // 🚀 Limiter taille réponse
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
    
    private String generateFallbackStoryStartJSON() {
        // 🚀 POOL DE FALLBACKS pour plus de variété
        String[] fallbacks = {
            "{\n" +
            "  \"title\": \"🌊 Ocean Rescue Mission\",\n" +
            "  \"content\": \"You discover a beach covered in plastic waste while rare sea turtles struggle to reach the ocean. Time is running out as the tide is rising.\",\n" +
            "  \"choices\": [\"Immediately clear a path for turtles\", \"Organize beach cleanup volunteers\", \"Document and report to authorities\"],\n" +
            "  \"points\": [30, 25, 15],\n" +
            "  \"isCompleted\": false\n" +
            "}",

            "{\n" +
            "  \"title\": \"🌱 Urban Garden Challenge\",\n" +
            "  \"content\": \"Your neighborhood lacks green spaces and fresh food. You have a vacant lot and community support to create change.\",\n" +
            "  \"choices\": [\"Start community garden project\", \"Plant native trees for carbon capture\", \"Create educational eco-workshops\"],\n" +
            "  \"points\": [28, 25, 20],\n" +
            "  \"isCompleted\": false\n" +
            "}",

            "{\n" +
            "  \"title\": \"⚡ Energy Revolution\",\n" +
            "  \"content\": \"Your school wants to reduce energy consumption by 50%. As student eco-leader, you need to propose an action plan.\",\n" +
            "  \"choices\": [\"Install solar panels on rooftop\", \"Launch energy-saving competition\", \"Switch to LED lighting system\"],\n" +
            "  \"points\": [32, 22, 18],\n" +
            "  \"isCompleted\": false\n" +
            "}"
        };

        // Choisir aléatoirement un fallback
        int randomIndex = (int) (Math.random() * fallbacks.length);
        return fallbacks[randomIndex];
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
