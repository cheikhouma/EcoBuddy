package sn.codiallo.ecoBuddy.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ObjectScanResponse {
    
    private String id;
    private String objectName;
    private String objectType; // "plastic", "glass", "paper", "metal", "organic", "electronic"
    private String environmentalImpact; // "low", "medium", "high"
    private String environmentalInfo;
    private List<String> recyclingSuggestions;
    private List<String> alternatives;
    private Integer points;
    private LocalDateTime scanDate;
    private Double confidence;
    
    // Nouvelles métriques environnementales détaillées
    private Double carbonFootprint; // kg CO2 équivalent
    private Double recyclingRate; // Taux de recyclage (0.0 à 1.0)
    private Integer biodegradabilityYears; // Années pour biodégradation
    private String impactDescription; // Description détaillée de l'impact
    
    // Informations Gemini AI
    private String geminiAnalysis; // Analyse générée par Gemini
    private List<String> ecoTips; // Conseils écologiques personnalisés
    private String funFact; // Fait intéressant sur l'objet
    
    // Métadonnées
    private Boolean isSuccessful;
    private String errorMessage;
    private String processingTime;
}