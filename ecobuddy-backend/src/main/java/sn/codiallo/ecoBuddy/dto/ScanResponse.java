package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor  
public class ScanResponse {
    // Champs de base (compatibilité frontend existant)
    private String name;
    private Double carbonImpact;
    private Boolean recyclable;
    private String alternative;
    private String description;
    private String ecoTips;
    private Integer pointsEarned;
    
    // Nouveaux champs pour compatibilité AR
    private String objectType; // "plastic", "glass", "paper", "metal", "unknown"
    private String funFact; // Fait intéressant sur l'objet
    
    // Champs pour l'enum EnvironmentalImpact (calculé côté frontend)
    // carbonImpact < 1.0 => low, < 10.0 => medium, >= 10.0 => high
}