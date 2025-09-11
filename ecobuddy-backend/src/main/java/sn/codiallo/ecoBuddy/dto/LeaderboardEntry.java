package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LeaderboardEntry {
    // Champs attendus par le frontend LeaderboardUser.dart
    private String id;              // ID de l'utilisateur
    private String username;        // Nom d'utilisateur
    private Integer points;         // Points totaux
    private Integer rank;           // Rang dans le classement
    private String avatar;          // URL ou identifiant d'avatar
    private Integer level;          // Niveau basé sur les points
    private List<String> badges;    // Liste des badges obtenus
    private Integer challengesCompleted;  // Nombre de défis terminés
    private Integer scansCompleted;       // Nombre de scans AR effectués
    private Integer storiesCompleted;     // Nombre d'histoires terminées
}