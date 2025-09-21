package sn.codiallo.ecoBuddy.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "eco_objects")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class EcoObject {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "Object name is required")
    @Column(unique = true, nullable = false)
    private String name;
    
    @NotNull(message = "Carbon impact is required")
    @Column(nullable = false)
    private Double carbonImpact;
    
    @NotNull(message = "Recyclable status is required")
    @Column(nullable = false)
    private Boolean recyclable;
    
    @Column(columnDefinition = "TEXT")
    private String alternative;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "eco_tips", columnDefinition = "TEXT")
    private String ecoTips;
    
    @Column(nullable = false)
    private Boolean isActive = true;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}