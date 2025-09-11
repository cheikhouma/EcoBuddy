package sn.codiallo.ecoBuddy.service;

import org.springframework.stereotype.Service;
import sn.codiallo.ecoBuddy.dto.ObjectRecognitionResult;

/**
 * Implémentation mock du service de reconnaissance d'objets.
 * Sera remplacée par TensorFlowLiteObjectRecognitionService plus tard.
 */
@Service
public class MockObjectRecognitionService implements ObjectRecognitionService {

    @Override
    public ObjectRecognitionResult recognizeObject(Object input) {
        if (!(input instanceof String)) {
            throw new IllegalArgumentException("Mock service expects string input");
        }
        
        String objectName = ((String) input).toLowerCase().trim();
        
        // Simulation de reconnaissance avec différents niveaux de confiance
        double confidence = calculateMockConfidence(objectName);
        
        return new ObjectRecognitionResult(objectName, confidence, "mock_prediction");
    }

    @Override
    public boolean isAiPowered() {
        return false;
    }

    @Override
    public String getServiceName() {
        return "Mock Object Recognition Service";
    }

    private double calculateMockConfidence(String objectName) {
        // Simulation de confiance basée sur des objets connus
        return switch (objectName) {
            case "bottle", "plastic bottle", "water bottle" -> 0.95;
            case "can", "aluminum can", "soda can" -> 0.90;
            case "bag", "plastic bag", "shopping bag" -> 0.85;
            case "cup", "coffee cup", "disposable cup" -> 0.88;
            case "box", "cardboard box", "package" -> 0.82;
            case "phone", "smartphone", "mobile phone" -> 0.92;
            case "battery", "batteries" -> 0.87;
            case "light bulb", "bulb", "led bulb" -> 0.83;
            default -> 0.70; // Confiance modérée pour objets inconnus
        };
    }
}