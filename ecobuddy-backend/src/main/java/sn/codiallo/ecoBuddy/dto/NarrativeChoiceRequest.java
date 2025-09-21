package sn.codiallo.ecoBuddy.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class NarrativeChoiceRequest {
    @NotBlank(message = "Session ID is required")
    private String sessionId;
    
    @NotBlank(message = "Choice is required")
    private String choice;
}