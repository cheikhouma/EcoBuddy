package sn.codiallo.ecoBuddy.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ChallengeCompleteRequest {
    @NotNull(message = "Challenge ID is required")
    private String challengeId; // Changé de Long à String pour compatibilité frontend
}