package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChallengeResponse {
    // Champs attendus par le frontend ChallengeModel.dart
    private String id;              // Changé de Long à String pour compatibilité frontend
    private String title;
    private String description;
    private String category;
    private Integer points;
    private LocalDateTime createdAt; // Frontend calcule startDate depuis ça
    private Integer durationDays;    // Frontend calcule endDate avec ça
    private Boolean completed;       // Frontend mappe vers isCompleted
    private Double progress;         // Nouveau : pourcentage de progression (0.0-1.0)
    private String imageUrl;         // Nouveau : URL de l'image du défi
    private String requirements;     // Frontend split par '|'
    private String difficulty;       // easy/medium/hard
}