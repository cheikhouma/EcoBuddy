package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import sn.codiallo.ecoBuddy.model.User;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    // Champs attendus par le frontend User.dart
    private Long id;                    // Backend Long -> frontend int (compatible)
    private String username;
    private String email;
    private String role;                // Enum converti en String
    private Integer points;
    private Integer age;
    private String city;
    private String country;
    private String region;
    private Double latitude;
    private Double longitude;
    private Boolean isLocationCompleted;
    
    /**
     * Crée un UserResponse depuis un User entity
     */
    public static UserResponse fromUser(User user) {
        return new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getRole().name(), // Conversion enum -> String
            user.getPoints(),
            user.getAge(),
            user.getCity(),
            user.getCountry(),
            user.getRegion(),
            user.getLatitude(),
            user.getLongitude(),
            user.getIsLocationCompleted()
        );
    }
}