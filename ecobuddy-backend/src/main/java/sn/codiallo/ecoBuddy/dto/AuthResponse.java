package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import sn.codiallo.ecoBuddy.model.User;

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
    
    public AuthResponse(String token, User user) {
        this.token = token;
        this.user = UserResponse.fromUser(user);
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