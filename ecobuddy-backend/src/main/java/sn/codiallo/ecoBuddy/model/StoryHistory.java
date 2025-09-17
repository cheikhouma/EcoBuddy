package sn.codiallo.ecoBuddy.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "story_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StoryHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String sessionId;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String summary;

    @Column(nullable = false)
    private Integer totalPoints;

    @Column(nullable = false)
    private Integer chapterCount;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private StoryStatus status;

    @Column(nullable = false)
    private String theme;

    @CreationTimestamp
    @Column(name = "completed_at", nullable = false, updatable = false)
    private LocalDateTime completedAt;

    public enum StoryStatus {
        COMPLETED,
        ABANDONED
    }
}