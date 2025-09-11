package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NarrativeStartResponse {
    // Champs attendus par le frontend StoryModel.dart
    private String id;
    private String sessionId;
    private String title;
    private String content;
    private List<String> choices;
    private int chapterNumber;
    private int points;
    private boolean isCompleted;
}