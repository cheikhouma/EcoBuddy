package sn.codiallo.ecoBuddy.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SaveStoryHistoryRequest {

    @NotBlank
    private String sessionId;

    @NotBlank
    private String title;

    private String summary;

    @NotNull
    private Integer totalPoints;

    @NotNull
    private Integer chapterCount;

    @NotBlank
    private String status; // "COMPLETED" ou "ABANDONED"

    private String theme;
}