package sn.codiallo.ecoBuddy.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ObjectScanRequest {
    
    @NotBlank(message = "Object label is required")
    private String objectLabel;
    
    @NotNull(message = "Confidence is required")
    @DecimalMin(value = "0.0", message = "Confidence must be between 0 and 1")
    @DecimalMax(value = "1.0", message = "Confidence must be between 0 and 1")
    private Double confidence;
    
    @NotNull(message = "Ecological relevance is required")
    private Boolean isEcologicallyRelevant;
    
    private List<String> alternatives;
    
    private String imageData; // Base64 encoded image (optional)
    
    private String timestamp;
    
    // Métadonnées optionnelles
    private String deviceInfo;
    private Double latitude;
    private Double longitude;
    private String scanType; // "real_time", "photo", "bulk"
}