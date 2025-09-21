package sn.codiallo.ecoBuddy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardResponse {
    private List<LeaderboardEntry> leaderboard;
    private LeaderboardEntry currentUser;
    private Integer totalUsers;
}