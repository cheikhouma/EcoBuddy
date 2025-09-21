package sn.codiallo.ecoBuddy.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import sn.codiallo.ecoBuddy.dto.DashboardResponse;
import sn.codiallo.ecoBuddy.dto.LeaderboardEntry;
import sn.codiallo.ecoBuddy.model.User;
import sn.codiallo.ecoBuddy.repository.UserChallengeRepository;
import sn.codiallo.ecoBuddy.repository.UserRepository;
import sn.codiallo.ecoBuddy.repository.NarrativeSessionRepository;
import sn.codiallo.ecoBuddy.repository.ScanRepository;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final UserRepository userRepository;
    private final UserChallengeRepository userChallengeRepository;
    private final NarrativeSessionRepository narrativeSessionRepository;
    private final ScanRepository scanRepository;

    public DashboardResponse getDashboard(String username) {
        User currentUser = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Récupérer le top 10 des utilisateurs par points
        Pageable topUsersPageable = PageRequest.of(0, 10, Sort.by("points").descending());
        List<User> topUsers = userRepository.findAll(
                PageRequest.of(0, 10, Sort.by("points").descending().and(Sort.by("username")))
        ).getContent();

        // Créer le leaderboard avec les rangs
        AtomicInteger rank = new AtomicInteger(1);
        List<LeaderboardEntry> leaderboard = topUsers.stream()
                .map(user -> createLeaderboardEntry(user, rank.getAndIncrement()))
                .collect(Collectors.toList());

        // Trouver la position de l'utilisateur actuel dans le classement général
        LeaderboardEntry currentUserEntry = getCurrentUserRank(currentUser);
        
        // Compter le nombre total d'utilisateurs
        Integer totalUsers = Math.toIntExact(userRepository.count());

        return new DashboardResponse(leaderboard, currentUserEntry, totalUsers);
    }

    private LeaderboardEntry getCurrentUserRank(User user) {
        // Récupérer tous les utilisateurs classés par points décroissants puis par username
        List<User> allUsers = userRepository.findAll(
                Sort.by("points").descending().and(Sort.by("username"))
        );
        
        // Trouver la position de l'utilisateur dans le classement
        Integer userRank = 1;
        for (int i = 0; i < allUsers.size(); i++) {
            if (allUsers.get(i).getId().equals(user.getId())) {
                userRank = i + 1;
                break;
            }
        }
        
        return createLeaderboardEntry(user, userRank);
    }

    public List<LeaderboardEntry> getFullLeaderboard() {
        List<User> allUsers = userRepository.findAll(
                Sort.by("points").descending().and(Sort.by("username"))
        );

        AtomicInteger rank = new AtomicInteger(1);
        return allUsers.stream()
                .map(user -> createLeaderboardEntry(user, rank.getAndIncrement()))
                .collect(Collectors.toList());
    }
    
    /**
     * Crée une entrée de leaderboard enrichie avec toutes les statistiques
     */
    private LeaderboardEntry createLeaderboardEntry(User user, Integer rank) {
        // Calculer les statistiques
        Integer challengesCompleted = Math.toIntExact(
            userChallengeRepository.countCompletedChallengesByUser(user)
        );
        
        // Compter les histoires terminées
        Integer storiesCompleted = narrativeSessionRepository
            .countByUserAndIsActiveFalse(user).intValue();
        
        // Compter les scans effectués (si la table existe, sinon 0)
        Integer scansCompleted = 0;
        try {
            scansCompleted = scanRepository.countByUser(user).intValue();
        } catch (Exception e) {
            // Si la table scan n'existe pas encore, on met 0
            scansCompleted = 0;
        }
        
        // Calculer le niveau basé sur les points (1 niveau par 100 points)
        Integer level = Math.max(1, user.getPoints() / 100);
        
        // Générer l'avatar basé sur l'username (identifiant simple)
        String avatar = generateAvatarIdentifier(user.getUsername());
        
        // Générer les badges basés sur les accomplissements
        List<String> badges = generateUserBadges(user, challengesCompleted, 
                                               storiesCompleted, scansCompleted);
        
        return new LeaderboardEntry(
            user.getId().toString(),
            user.getUsername(),
            user.getPoints(),
            rank,
            avatar,
            level,
            badges,
            challengesCompleted,
            scansCompleted,
            storiesCompleted
        );
    }
    
    /**
     * Génère un identifiant d'avatar basé sur l'username
     */
    private String generateAvatarIdentifier(String username) {
        // Utiliser un système simple basé sur la première lettre
        if (username == null || username.isEmpty()) {
            return "default";
        }
        return "avatar_" + Character.toLowerCase(username.charAt(0));
    }
    
    /**
     * Génère les badges basés sur les accomplissements
     */
    private List<String> generateUserBadges(User user, Integer challenges, 
                                           Integer stories, Integer scans) {
        List<String> badges = new ArrayList<>();
        
        // Badges basés sur les points
        if (user.getPoints() >= 1000) {
            badges.add("🏆 Maître Écologique");
        } else if (user.getPoints() >= 500) {
            badges.add("🌱 Expert Vert");
        } else if (user.getPoints() >= 100) {
            badges.add("✨ Éco-Enthousiaste");
        }
        
        // Badges basés sur les défis
        if (challenges >= 10) {
            badges.add("🎨 Challenger");
        } else if (challenges >= 5) {
            badges.add("💪 Déterminé");
        }
        
        // Badges basés sur les histoires
        if (stories >= 5) {
            badges.add("📚 Conteur");
        } else if (stories >= 1) {
            badges.add("📖 Lecteur");
        }
        
        // Badges basés sur les scans
        if (scans >= 20) {
            badges.add("🔍 Explorateur AR");
        } else if (scans >= 5) {
            badges.add("📱 Scanner");
        }
        
        return badges;
    }
}