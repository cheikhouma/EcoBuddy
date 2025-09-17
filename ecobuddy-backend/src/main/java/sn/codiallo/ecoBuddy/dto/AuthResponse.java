package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import sn.codiallo.ecoBuddy.model.User;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    // Informations de token
    private String token;
    private String type = "Bearer";
    private Long expiresIn = 86400L; // 24h en secondes
    
    // Informations utilisateur complètes
    private UserResponse user;

    // Historique des histoires narratives
    private List<StoryHistoryResponse> storyHistory;

    public AuthResponse(String token, User user) {
        this.token = token;
        this.user = UserResponse.fromUser(user);
        this.storyHistory = List.of(); // Empty by default
    }

    public AuthResponse(String token, User user, List<StoryHistoryResponse> storyHistory) {
        this.token = token;
        this.user = UserResponse.fromUser(user);
        this.storyHistory = storyHistory != null ? storyHistory : List.of();
    }
    
    // Constructeur legacy pour compatibilité
    public AuthResponse(String token, String username, String email, String role, Integer points) {
        this.token = token;
        this.user = new UserResponse();
        this.user.setUsername(username);
        this.user.setEmail(email);
        this.user.setRole(role);
        this.user.setPoints(points);
    }
}