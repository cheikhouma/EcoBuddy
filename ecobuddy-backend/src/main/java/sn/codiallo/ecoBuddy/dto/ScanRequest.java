package sn.codiallo.ecoBuddy.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ScanRequest {
    @NotBlank(message = "Object name is required")
    private String name;
}