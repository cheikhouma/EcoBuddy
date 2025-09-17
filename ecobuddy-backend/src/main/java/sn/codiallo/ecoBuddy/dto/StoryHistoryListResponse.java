package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StoryHistoryListResponse {

    private List<StoryHistoryResponse> stories;
    private StoryHistoryStatsResponse stats;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StoryHistoryStatsResponse {
        private Long completedStoriesCount;
        private Long totalPoints;
        private Long totalStoriesCount;
    }
}