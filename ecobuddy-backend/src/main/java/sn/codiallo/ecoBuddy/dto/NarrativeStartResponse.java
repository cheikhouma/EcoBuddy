package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NarrativeStartResponse {
    // Champs attendus par le frontend StoryModel.dart
    private String id;
    private String sessionId;
    private String title;
    private String content;
    private List<String> choices;
    private int chapterNumber;
    private int pointsEarned; // Points gagnés pour cette étape
    private int totalPoints;  // Points totaux de l'utilisateur
    private boolean isCompleted;
    private String status = "success"; // Nouveau: statut de la réponse
}