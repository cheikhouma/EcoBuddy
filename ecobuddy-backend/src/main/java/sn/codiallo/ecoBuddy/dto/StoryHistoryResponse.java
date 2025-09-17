package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import sn.codiallo.ecoBuddy.model.StoryHistory;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StoryHistoryResponse {

    private Long id;
    private String sessionId;
    private String title;
    private String summary;
    private Integer totalPoints;
    private Integer chapterCount;
    private String status;
    private String theme;
    private LocalDateTime completedAt;

    // Constructor depuis l'entité
    public StoryHistoryResponse(StoryHistory storyHistory) {
        this.id = storyHistory.getId();
        this.sessionId = storyHistory.getSessionId();
        this.title = storyHistory.getTitle();
        this.summary = storyHistory.getSummary();
        this.totalPoints = storyHistory.getTotalPoints();
        this.chapterCount = storyHistory.getChapterCount();
        this.status = storyHistory.getStatus().name();
        this.theme = storyHistory.getTheme();
        this.completedAt = storyHistory.getCompletedAt();
    }
}