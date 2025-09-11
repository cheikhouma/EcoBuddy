package sn.codiallo.ecoBuddy.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.codiallo.ecoBuddy.dto.ObjectRecognitionResult;
import sn.codiallo.ecoBuddy.dto.ScanResponse;
import sn.codiallo.ecoBuddy.dto.ObjectScanRequest;
import sn.codiallo.ecoBuddy.dto.ObjectScanResponse;
import sn.codiallo.ecoBuddy.model.EcoObject;
import sn.codiallo.ecoBuddy.model.User;
import sn.codiallo.ecoBuddy.repository.EcoObjectRepository;
import sn.codiallo.ecoBuddy.repository.UserRepository;

import java.util.List;
import java.util.Optional;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScannerService {

    private final ObjectRecognitionService objectRecognitionService;
    private final EcoObjectRepository ecoObjectRepository;
    private final UserRepository userRepository;
    private final GeminiService geminiService;

    private static final int SCAN_POINTS_REWARD = 5; // Points gagnés pour chaque scan

    @Transactional
    public ScanResponse scanObject(String objectName, String username) {
        log.info("Scanning object: {} for user: {}", objectName, username);

        // Reconnaissance d'objet (mock pour l'instant)
        ObjectRecognitionResult recognitionResult = objectRecognitionService.recognizeObject(objectName);
        
        // Rechercher les informations écologiques de l'objet
        Optional<EcoObject> ecoObjectOpt = findEcoObjectInfo(recognitionResult.getObjectName());
        
        if (ecoObjectOpt.isPresent()) {
            EcoObject ecoObject = ecoObjectOpt.get();
            
            // Récompenser l'utilisateur pour le scan
            rewardUserForScan(username);
            
            ScanResponse response = new ScanResponse();
            response.setName(ecoObject.getName());
            response.setCarbonImpact(ecoObject.getCarbonImpact());
            response.setRecyclable(ecoObject.getRecyclable());
            response.setAlternative(ecoObject.getAlternative());
            response.setDescription(ecoObject.getDescription());
            response.setEcoTips(ecoObject.getEcoTips());
            response.setPointsEarned(SCAN_POINTS_REWARD);
            return response;
        } else {
            // Objet non trouvé dans la base, retourner des valeurs par défaut
            log.warn("Object not found in database: {}", recognitionResult.getObjectName());
            
            return createDefaultResponse(recognitionResult.getObjectName(), username);
        }
    }

    private Optional<EcoObject> findEcoObjectInfo(String objectName) {
        // Recherche exacte d'abord
        Optional<EcoObject> exact = ecoObjectRepository.findByNameIgnoreCaseAndIsActiveTrue(objectName);
        if (exact.isPresent()) {
            return exact;
        }

        // Recherche par mots-clés si pas de correspondance exacte
        List<EcoObject> similar = ecoObjectRepository.findByNameContainingIgnoreCaseAndIsActiveTrue(objectName);
        if (!similar.isEmpty()) {
            return Optional.of(similar.get(0)); // Retourner le premier résultat
        }

        // Recherche par synonymes courants
        return findBySynonym(objectName);
    }

    private Optional<EcoObject> findBySynonym(String objectName) {
        String lowerName = objectName.toLowerCase();
        
        // Mapping de synonymes vers noms standardisés
        String standardName = switch (lowerName) {
            case "plastic bottle", "water bottle", "drink bottle" -> "bottle";
            case "aluminum can", "soda can", "drink can" -> "can";
            case "plastic bag", "shopping bag", "grocery bag" -> "bag";
            case "coffee cup", "disposable cup", "paper cup" -> "cup";
            case "cardboard box", "package", "shipping box" -> "box";
            case "smartphone", "mobile phone", "cell phone" -> "phone";
            case "batteries", "battery pack" -> "battery";
            case "light bulb", "led bulb", "incandescent bulb" -> "bulb";
            default -> lowerName;
        };

        return ecoObjectRepository.findByNameIgnoreCaseAndIsActiveTrue(standardName);
    }

    private ScanResponse createDefaultResponse(String objectName, String username) {
        // Récompenser quand même l'utilisateur pour le scan
        rewardUserForScan(username);
        
        // Valeurs par défaut pour objets inconnus
        ScanResponse response = new ScanResponse();
        response.setName(objectName);
        response.setCarbonImpact(5.0); // Impact carbone moyen
        response.setRecyclable(true); // Présumer recyclable par défaut
        response.setAlternative("Recherchez des alternatives écologiques");
        response.setDescription("Informations non disponibles pour cet objet");
        response.setEcoTips("Consultez votre centre de recyclage local pour plus d'informations");
        response.setPointsEarned(SCAN_POINTS_REWARD);
        return response;
    }

    private void rewardUserForScan(String username) {
        try {
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            user.setPoints(user.getPoints() + SCAN_POINTS_REWARD);
            userRepository.save(user);
            
            log.info("Rewarded user {} with {} points for scanning", username, SCAN_POINTS_REWARD);
        } catch (Exception e) {
            log.error("Failed to reward user for scan: ", e);
            // Ne pas faire échouer le scan si la récompense échoue
        }
    }

    public List<EcoObject> getAllEcoObjects() {
        return ecoObjectRepository.findByIsActiveTrueOrderByNameAsc();
    }

    public List<EcoObject> searchEcoObjects(String keyword) {
        return ecoObjectRepository.findByNameContainingIgnoreCaseAndIsActiveTrue(keyword);
    }
    
    @Transactional
    public ScanResponse scanObjectForAR(String objectLabel, String username, ObjectScanRequest request) {
        log.info("Scanning AR object: {} for user: {}", objectLabel, username);

        try {
            // Rechercher les informations écologiques de l'objet
            Optional<EcoObject> ecoObjectOpt = findEcoObjectInfo(objectLabel);
            
            if (ecoObjectOpt.isPresent()) {
                EcoObject ecoObject = ecoObjectOpt.get();
                
                // Récompenser l'utilisateur pour le scan
                rewardUserForScan(username);
                
                // Déterminer le type d'objet pour les champs AR
                String objectType = determineObjectType(objectLabel);
                String funFact = generateFunFact(objectLabel, ecoObject);
                
                ScanResponse response = new ScanResponse();
                response.setName(ecoObject.getName());
                response.setCarbonImpact(ecoObject.getCarbonImpact());
                response.setRecyclable(ecoObject.getRecyclable());
                response.setAlternative(ecoObject.getAlternative());
                response.setDescription(ecoObject.getDescription());
                response.setEcoTips(ecoObject.getEcoTips());
                response.setPointsEarned(SCAN_POINTS_REWARD);
                response.setObjectType(objectType);
                response.setFunFact(funFact);
                return response;
            } else {
                // Objet non trouvé dans la base, créer une réponse basée sur le label ML Kit
                return createARDefaultResponse(objectLabel, username);
            }
        } catch (Exception e) {
            log.error("Error processing AR scan: ", e);
            return createARDefaultResponse(objectLabel, username);
        }
    }
    
    private ScanResponse createARDefaultResponse(String objectLabel, String username) {
        // Récompenser quand même l'utilisateur pour le scan
        rewardUserForScan(username);
        
        String objectType = determineObjectType(objectLabel);
        String funFact = generateFunFact(objectLabel, null);
        
        // Valeurs intelligentes basées sur le type d'objet
        Double carbonImpact = estimateCarbonImpact(objectLabel);
        Boolean recyclable = estimateRecyclability(objectLabel);
        String alternative = generateAlternative(objectLabel);
        String description = generateDescription(objectLabel);
        String ecoTips = generateEcoTips(objectLabel);
        
        ScanResponse response = new ScanResponse();
        response.setName(formatObjectName(objectLabel));
        response.setCarbonImpact(carbonImpact);
        response.setRecyclable(recyclable);
        response.setAlternative(alternative);
        response.setDescription(description);
        response.setEcoTips(ecoTips);
        response.setPointsEarned(SCAN_POINTS_REWARD);
        response.setObjectType(objectType);
        response.setFunFact(funFact);
        return response;
    }
    
    private String determineObjectType(String objectLabel) {
        String lowerLabel = objectLabel.toLowerCase();
        if (lowerLabel.contains("plastic") || lowerLabel.contains("bottle") || lowerLabel.contains("bag")) {
            return "plastic";
        } else if (lowerLabel.contains("glass")) {
            return "glass";
        } else if (lowerLabel.contains("can") || lowerLabel.contains("metal") || lowerLabel.contains("aluminum")) {
            return "metal";
        } else if (lowerLabel.contains("paper") || lowerLabel.contains("cardboard")) {
            return "paper";
        } else if (lowerLabel.contains("electronic") || lowerLabel.contains("phone") || lowerLabel.contains("battery")) {
            return "electronic";
        } else if (lowerLabel.contains("textile") || lowerLabel.contains("fabric") || lowerLabel.contains("cloth")) {
            return "textile";
        }
        return "unknown";
    }
    
    private String generateFunFact(String objectLabel, EcoObject ecoObject) {
        String lowerLabel = objectLabel.toLowerCase();
        if (lowerLabel.contains("bottle")) {
            return "1 million de bouteilles plastique sont achetées chaque minute dans le monde !";
        } else if (lowerLabel.contains("can")) {
            return "Recycler une canette économise 95% de l'énergie nécessaire pour la fabriquer.";
        } else if (lowerLabel.contains("bag")) {
            return "8 millions de tonnes de plastique finissent dans les océans chaque année.";
        } else if (lowerLabel.contains("glass")) {
            return "Le verre peut être recyclé à l'infini sans perdre sa qualité !";
        } else if (lowerLabel.contains("paper")) {
            return "Il faut environ 17 arbres pour produire 1 tonne de papier.";
        }
        return "Chaque geste compte pour préserver notre planète !";
    }
    
    private Double estimateCarbonImpact(String objectLabel) {
        String lowerLabel = objectLabel.toLowerCase();
        if (lowerLabel.contains("bottle")) return 2.5;
        if (lowerLabel.contains("can")) return 1.8;
        if (lowerLabel.contains("bag")) return 0.6;
        if (lowerLabel.contains("glass")) return 1.2;
        if (lowerLabel.contains("paper")) return 0.9;
        if (lowerLabel.contains("phone") || lowerLabel.contains("electronic")) return 70.0;
        return 1.0;
    }
    
    private Boolean estimateRecyclability(String objectLabel) {
        String lowerLabel = objectLabel.toLowerCase();
        if (lowerLabel.contains("glass") || lowerLabel.contains("can") || lowerLabel.contains("metal")) return true;
        if (lowerLabel.contains("paper") || lowerLabel.contains("cardboard")) return true;
        if (lowerLabel.contains("bottle")) return true;
        if (lowerLabel.contains("bag") && lowerLabel.contains("plastic")) return false;
        return true; // Par défaut optimiste
    }
    
    private String generateAlternative(String objectLabel) {
        String lowerLabel = objectLabel.toLowerCase();
        if (lowerLabel.contains("bottle")) return "Utilisez une gourde réutilisable en acier inoxydable";
        if (lowerLabel.contains("can")) return "Buvez dans des verres réutilisables";
        if (lowerLabel.contains("bag")) return "Utilisez un sac en toile ou en coton bio";
        if (lowerLabel.contains("cup")) return "Utilisez une tasse réutilisable";
        if (lowerLabel.contains("phone")) return "Gardez votre téléphone plus longtemps (3-4 ans minimum)";
        return "Recherchez des alternatives durables et réutilisables";
    }
    
    private String generateDescription(String objectLabel) {
        String lowerLabel = objectLabel.toLowerCase();
        if (lowerLabel.contains("bottle")) return "Les bouteilles en plastique PET mettent 450 ans à se décomposer.";
        if (lowerLabel.contains("can")) return "L'aluminium est recyclable à l'infini sans perte de qualité.";
        if (lowerLabel.contains("bag")) return "Les sacs plastique polluent massivement les océans.";
        if (lowerLabel.contains("glass")) return "Le verre est recyclable à l'infini mais sa production est énergivore.";
        if (lowerLabel.contains("paper")) return "Le papier est biodégradable mais sa production consomme beaucoup d'eau.";
        return "Impact environnemental variable selon le matériau et l'usage.";
    }
    
    private String generateEcoTips(String objectLabel) {
        String lowerLabel = objectLabel.toLowerCase();
        if (lowerLabel.contains("bottle")) return "Recyclez dans le bac jaune, Retirez le bouchon avant recyclage";
        if (lowerLabel.contains("can")) return "Recyclez dans le bac de tri, Videz complètement avant recyclage";
        if (lowerLabel.contains("bag")) return "Réutilisez plusieurs fois, Apportez en magasin pour recyclage spécialisé";
        if (lowerLabel.contains("glass")) return "Rincez le contenant, Retirez les bouchons, Triez par couleur si demandé";
        if (lowerLabel.contains("paper")) return "Retirez les adhésifs et agrafes, Déposez dans le bac papier";
        return "Consultez les consignes de tri locales, Réutilisez quand c'est possible";
    }
    
    private String formatObjectName(String objectLabel) {
        String lowerLabel = objectLabel.toLowerCase();
        if (lowerLabel.contains("bottle")) return "Bouteille en plastique";
        if (lowerLabel.contains("can")) return "Canette en aluminium";
        if (lowerLabel.contains("bag")) return "Sac plastique";
        if (lowerLabel.contains("glass")) return "Objet en verre";
        if (lowerLabel.contains("paper")) return "Papier";
        if (lowerLabel.contains("phone")) return "Smartphone";
        return objectLabel.substring(0, 1).toUpperCase() + objectLabel.substring(1);
    }

    @Transactional
    public ObjectScanResponse scanObjectWithTensorFlow(ObjectScanRequest request, String username) {
        long startTime = System.currentTimeMillis();
        log.info("Scanning TensorFlow object: {} (confidence: {}) for user: {}", 
                request.getObjectLabel(), request.getConfidence(), username);

        try {
            // 1. Rechercher les informations de base dans la DB
            Optional<EcoObject> ecoObjectOpt = findEcoObjectInfo(request.getObjectLabel());
            
            // 2. Générer une analyse Gemini enrichie
            String geminiAnalysis = generateGeminiAnalysis(request);
            
            // 3. Calculer les métriques environnementales
            EnvironmentalMetrics metrics = calculateEnvironmentalMetrics(request.getObjectLabel());
            
            // 4. Récompenser l'utilisateur
            int pointsEarned = calculatePointsReward(request);
            rewardUserForScan(username, pointsEarned);
            
            // 5. Construire la réponse
            ObjectScanResponse response = buildScanResponse(
                request, ecoObjectOpt, geminiAnalysis, metrics, pointsEarned, startTime
            );
            
            log.info("Successfully processed scan for object: {} in {}ms", 
                    request.getObjectLabel(), System.currentTimeMillis() - startTime);
            
            return response;
            
        } catch (Exception e) {
            log.error("Error processing TensorFlow scan: ", e);
            return createErrorResponse(request, e, startTime);
        }
    }

    private String generateGeminiAnalysis(ObjectScanRequest request) {
        try {
            String prompt = buildGeminiPrompt(request);
            return geminiService.generateNarrative(prompt, List.of("Analyser l'impact écologique"));
        } catch (Exception e) {
            log.warn("Failed to generate Gemini analysis: ", e);
            return getDefaultAnalysis(request.getObjectLabel());
        }
    }

    private String buildGeminiPrompt(ObjectScanRequest request) {
        return String.format(
            "Analyse cet objet détecté par IA : %s (confiance: %.2f). " +
            "Fournis un résumé écologique incluant : " +
            "1) Impact environnemental détaillé " +
            "2) Conseils de recyclage spécifiques " +
            "3) Alternatives durables " +
            "4) Un fait intéressant. " +
            "Réponds en français, sois informatif et encourageant.",
            request.getObjectLabel(), request.getConfidence()
        );
    }

    private EnvironmentalMetrics calculateEnvironmentalMetrics(String objectLabel) {
        String lowerLabel = objectLabel.toLowerCase();
        
        // Métriques basées sur des données environnementales réelles
        if (lowerLabel.contains("plastic") || lowerLabel.contains("bottle")) {
            return new EnvironmentalMetrics(2.3, 0.65, 450, "high");
        } else if (lowerLabel.contains("glass")) {
            return new EnvironmentalMetrics(0.8, 0.85, 1000000, "medium");
        } else if (lowerLabel.contains("can") || lowerLabel.contains("aluminum")) {
            return new EnvironmentalMetrics(8.1, 0.92, 100, "high");
        } else if (lowerLabel.contains("paper") || lowerLabel.contains("cardboard")) {
            return new EnvironmentalMetrics(1.4, 0.78, 1, "low");
        } else if (lowerLabel.contains("bag") && lowerLabel.contains("plastic")) {
            return new EnvironmentalMetrics(0.6, 0.12, 500, "high");
        }
        
        // Valeurs par défaut
        return new EnvironmentalMetrics(1.5, 0.50, 50, "medium");
    }

    private int calculatePointsReward(ObjectScanRequest request) {
        int basePoints = 5;
        
        // Bonus pour la confiance de classification
        if (request.getConfidence() > 0.9) {
            basePoints += 3;
        } else if (request.getConfidence() > 0.7) {
            basePoints += 1;
        }
        
        // Bonus pour objets écologiquement pertinents
        if (Boolean.TRUE.equals(request.getIsEcologicallyRelevant())) {
            basePoints += 2;
        }
        
        // Bonus pour objets à impact environnemental élevé (sensibilisation)
        String label = request.getObjectLabel().toLowerCase();
        if (label.contains("plastic") || label.contains("battery") || label.contains("electronic")) {
            basePoints += 3;
        }
        
        return Math.min(basePoints, 15); // Maximum 15 points par scan
    }

    private void rewardUserForScan(String username, int points) {
        try {
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            user.setPoints(user.getPoints() + points);
            userRepository.save(user);
            
            log.info("Rewarded user {} with {} points for TensorFlow scan", username, points);
        } catch (Exception e) {
            log.error("Failed to reward user for TensorFlow scan: ", e);
        }
    }

    private ObjectScanResponse buildScanResponse(
            ObjectScanRequest request, 
            Optional<EcoObject> ecoObjectOpt, 
            String geminiAnalysis,
            EnvironmentalMetrics metrics,
            int pointsEarned,
            long startTime) {
        
        return ObjectScanResponse.builder()
                .id("scan_" + System.currentTimeMillis())
                .objectName(formatObjectName(request.getObjectLabel()))
                .objectType(determineObjectType(request.getObjectLabel()))
                .environmentalImpact(metrics.impactLevel)
                .environmentalInfo(extractEnvironmentalInfo(geminiAnalysis))
                .recyclingSuggestions(getRecyclingSuggestions(request.getObjectLabel(), ecoObjectOpt))
                .alternatives(request.getAlternatives() != null ? 
                            request.getAlternatives() : 
                            getDefaultAlternatives(request.getObjectLabel()))
                .points(pointsEarned)
                .scanDate(LocalDateTime.now())
                .confidence(request.getConfidence())
                .carbonFootprint(metrics.carbonFootprint)
                .recyclingRate(metrics.recyclingRate)
                .biodegradabilityYears(metrics.biodegradabilityYears)
                .impactDescription(buildImpactDescription(request.getObjectLabel(), metrics))
                .geminiAnalysis(geminiAnalysis)
                .ecoTips(extractEcoTips(geminiAnalysis, request.getObjectLabel()))
                .funFact(generateFunFact(request.getObjectLabel(), ecoObjectOpt.orElse(null)))
                .isSuccessful(true)
                .processingTime((System.currentTimeMillis() - startTime) + "ms")
                .build();
    }

    private ObjectScanResponse createErrorResponse(ObjectScanRequest request, Exception e, long startTime) {
        return ObjectScanResponse.builder()
                .id("error_" + System.currentTimeMillis())
                .objectName("Objet non identifié")
                .objectType("unknown")
                .environmentalImpact("unknown")
                .environmentalInfo("Impossible d'analyser cet objet")
                .recyclingSuggestions(Arrays.asList("Consultez votre centre de tri local"))
                .alternatives(Arrays.asList("Privilégiez des alternatives durables"))
                .points(1)
                .scanDate(LocalDateTime.now())
                .confidence(0.0)
                .geminiAnalysis("Analyse indisponible")
                .ecoTips(Arrays.asList("Réduisez votre consommation"))
                .funFact("Chaque geste compte pour l'environnement!")
                .isSuccessful(false)
                .errorMessage(e.getMessage())
                .processingTime((System.currentTimeMillis() - startTime) + "ms")
                .build();
    }

    // Méthodes utilitaires - utiliser celles définies plus haut

    private String extractEnvironmentalInfo(String geminiAnalysis) {
        // Extraction simple - dans un cas réel, on pourrait parser plus finement
        if (geminiAnalysis != null && geminiAnalysis.length() > 50) {
            int endIndex = Math.min(geminiAnalysis.indexOf('.', 50), geminiAnalysis.length());
            return geminiAnalysis.substring(0, endIndex > 0 ? endIndex + 1 : 100);
        }
        return "Impact environnemental variable selon l'usage et le traitement.";
    }

    private List<String> getRecyclingSuggestions(String objectLabel, Optional<EcoObject> ecoObjectOpt) {
        if (ecoObjectOpt.isPresent() && ecoObjectOpt.get().getEcoTips() != null) {
            return Arrays.asList(ecoObjectOpt.get().getEcoTips().split("\\|"));
        }
        
        return getDefaultRecyclingSuggestions(objectLabel);
    }

    private List<String> getDefaultRecyclingSuggestions(String objectLabel) {
        String lower = objectLabel.toLowerCase();
        
        if (lower.contains("plastic")) {
            return Arrays.asList(
                "Rincez le contenant avant recyclage",
                "Vérifiez le code de recyclage (1-7)",
                "Déposez dans le bac jaune de tri sélectif"
            );
        } else if (lower.contains("glass")) {
            return Arrays.asList(
                "Retirez les bouchons et couvercles",
                "Rincez rapidement",
                "Déposez dans les conteneurs verre"
            );
        } else if (lower.contains("paper")) {
            return Arrays.asList(
                "Retirez les agrafes et spirales",
                "Évitez le papier souillé",
                "Triez avec les autres papiers"
            );
        }
        
        return Arrays.asList("Consultez les consignes de tri de votre commune");
    }

    private List<String> getDefaultAlternatives(String objectLabel) {
        String lower = objectLabel.toLowerCase();
        
        if (lower.contains("bottle")) {
            return Arrays.asList(
                "Gourde réutilisable",
                "Fontaine à eau",
                "Bouteilles consignées"
            );
        } else if (lower.contains("bag")) {
            return Arrays.asList(
                "Sacs réutilisables en toile",
                "Cabas en matières naturelles",
                "Paniers en osier"
            );
        }
        
        return Arrays.asList("Cherchez des alternatives durables et réutilisables");
    }

    private String buildImpactDescription(String objectLabel, EnvironmentalMetrics metrics) {
        return String.format(
            "Cet objet génère environ %.1f kg de CO2, avec un taux de recyclage de %.0f%% et une durée de dégradation de %d ans.",
            metrics.carbonFootprint,
            metrics.recyclingRate * 100,
            metrics.biodegradabilityYears
        );
    }

    private List<String> extractEcoTips(String geminiAnalysis, String objectLabel) {
        // Extraction basique - peut être améliorée avec NLP
        List<String> tips = new ArrayList<>();
        
        if (geminiAnalysis != null && geminiAnalysis.contains("conseil")) {
            tips.add("Suivez les conseils de l'analyse Gemini");
        }
        
        tips.add("Réduisez votre consommation");
        tips.add("Privilégiez les produits durables");
        
        return tips;
    }


    private String getDefaultAnalysis(String objectLabel) {
        return String.format(
            "L'objet '%s' a été détecté par intelligence artificielle. " +
            "Pour une analyse complète de son impact environnemental, " +
            "consultez les suggestions de recyclage et les alternatives proposées.",
            objectLabel
        );
    }

    // Classe interne pour les métriques environnementales
    private static class EnvironmentalMetrics {
        final double carbonFootprint;
        final double recyclingRate;
        final int biodegradabilityYears;
        final String impactLevel;
        
        EnvironmentalMetrics(double carbonFootprint, double recyclingRate, int biodegradabilityYears, String impactLevel) {
            this.carbonFootprint = carbonFootprint;
            this.recyclingRate = recyclingRate;
            this.biodegradabilityYears = biodegradabilityYears;
            this.impactLevel = impactLevel;
        }
    }
}