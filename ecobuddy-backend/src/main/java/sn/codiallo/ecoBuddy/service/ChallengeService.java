package sn.codiallo.ecoBuddy.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.codiallo.ecoBuddy.dto.ChallengeCompleteResponse;
import sn.codiallo.ecoBuddy.dto.ChallengeResponse;
import sn.codiallo.ecoBuddy.model.Challenge;
import sn.codiallo.ecoBuddy.model.User;
import sn.codiallo.ecoBuddy.model.UserChallenge;
import sn.codiallo.ecoBuddy.repository.ChallengeRepository;
import sn.codiallo.ecoBuddy.repository.UserChallengeRepository;
import sn.codiallo.ecoBuddy.repository.UserRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChallengeService {

    private final ChallengeRepository challengeRepository;
    private final UserChallengeRepository userChallengeRepository;
    private final UserRepository userRepository;

    public List<ChallengeResponse> getAllChallenges(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Challenge> challenges = challengeRepository.findByIsActiveTrueOrderByCreatedAtDesc();
        
        return challenges.stream()
                .map(challenge -> {
                    boolean completed = userChallengeRepository.existsByUserAndChallengeAndCompleted(
                            user, challenge, true);
                    
                    return new ChallengeResponse(
                            challenge.getId().toString(), // Conversion Long -> String
                            challenge.getTitle(),
                            challenge.getDescription(),
                            challenge.getCategory(),
                            challenge.getPoints(),
                            challenge.getCreatedAt(),
                            challenge.getDurationDays(),
                            completed,
                            calculateProgress(challenge, user), // Nouveau : calcul progression
                            generateImageUrl(challenge),        // Nouveau : génération imageUrl
                            challenge.getRequirements(),
                            challenge.getDifficulty()
                    );
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public ChallengeCompleteResponse completeChallenge(String challengeId, String username) {
        // Conversion String -> Long pour la DB
        Long challengeIdLong;
        try {
            challengeIdLong = Long.parseLong(challengeId);
        } catch (NumberFormatException e) {
            throw new RuntimeException("Invalid challenge ID format");
        }
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Challenge challenge = challengeRepository.findById(challengeIdLong)
                .orElseThrow(() -> new RuntimeException("Challenge not found"));

        if (!challenge.getIsActive()) {
            throw new RuntimeException("Challenge is not active");
        }

        // Vérifier si le défi n'est pas déjà complété
        if (userChallengeRepository.existsByUserAndChallengeAndCompleted(user, challenge, true)) {
            throw new RuntimeException("Challenge already completed");
        }

        // Créer ou mettre à jour l'entrée UserChallenge
        UserChallenge userChallenge = userChallengeRepository.findByUserAndChallenge(user, challenge)
                .orElse(new UserChallenge());

        userChallenge.setUser(user);
        userChallenge.setChallenge(challenge);
        userChallenge.setCompleted(true);
        userChallenge.setPointsEarned(challenge.getPoints());
        userChallenge.setProgressPercentage(1.0); // 100% complété
        userChallenge.setCompletedAt(java.time.LocalDateTime.now());
        
        userChallengeRepository.save(userChallenge);

        // Ajouter les points à l'utilisateur
        user.setPoints(user.getPoints() + challenge.getPoints());
        userRepository.save(user);

        log.info("User {} completed challenge {} and earned {} points", 
                username, challenge.getTitle(), challenge.getPoints());

        return new ChallengeCompleteResponse(
                "Challenge completed successfully!",
                challenge.getPoints(),
                user.getPoints()
        );
    }
    
    /**
     * Calcule la progression d'un utilisateur pour un défi donné
     */
    private Double calculateProgress(Challenge challenge, User user) {
        // Si complété = 100%
        boolean completed = userChallengeRepository.existsByUserAndChallengeAndCompleted(
                user, challenge, true);

        if (completed) {
            return 1.0; // 100%
        }

        // Récupérer l'entrée UserChallenge pour la progression stockée
        UserChallenge userChallenge = userChallengeRepository.findByUserAndChallenge(user, challenge)
                .orElse(null);

        if (userChallenge != null && !userChallenge.getCompleted()) {
            // Retourner la progression stockée
            return userChallenge.getProgressPercentage();
        }

        return 0.0; // Pas encore commencé
    }
    
    /**
     * Génère une URL d'image pour un défi basée sur sa catégorie
     */
    private String generateImageUrl(Challenge challenge) {
        if (challenge.getCategory() == null) {
            return "https://via.placeholder.com/300x200?text=Eco+Challenge";
        }
        
        // Générer des URLs d'images basées sur la catégorie
        switch (challenge.getCategory().toLowerCase()) {
            case "energy":
            case "energie":
                return "https://via.placeholder.com/300x200/4CAF50/white?text=🔋+Energie";
            case "water":
            case "eau":
                return "https://via.placeholder.com/300x200/2196F3/white?text=💧+Eau";
            case "waste":
            case "dechets":
                return "https://via.placeholder.com/300x200/FF9800/white?text=♻️+Déchets";
            case "transport":
                return "https://via.placeholder.com/300x200/8BC34A/white?text=🚲+Transport";
            case "food":
            case "alimentation":
                return "https://via.placeholder.com/300x200/FFC107/white?text=🌱+Bio";
            default:
                return "https://via.placeholder.com/300x200/4CAF50/white?text=🌍+Eco";
        }
    }

    public List<ChallengeResponse> getUserCompletedChallenges(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<UserChallenge> completedChallenges = userChallengeRepository.findByUserAndCompleted(user, true);
        
        return completedChallenges.stream()
                .map(uc -> new ChallengeResponse(
                        uc.getChallenge().getId().toString(), // Conversion Long -> String
                        uc.getChallenge().getTitle(),
                        uc.getChallenge().getDescription(),
                        uc.getChallenge().getCategory(),
                        uc.getPointsEarned(),
                        uc.getCompletedAt(),
                        uc.getChallenge().getDurationDays(),
                        true, // completed
                        1.0,  // progress 100% pour les défis terminés
                        generateImageUrl(uc.getChallenge()),
                        uc.getChallenge().getRequirements(),
                        uc.getChallenge().getDifficulty()
                ))
                .collect(Collectors.toList());
    }

    @Transactional
    public void updateChallengeProgress(String challengeId, String username) {
        // Conversion String -> Long pour la DB
        Long challengeIdLong;
        try {
            challengeIdLong = Long.parseLong(challengeId);
        } catch (NumberFormatException e) {
            throw new RuntimeException("Invalid challenge ID format");
        }

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Challenge challenge = challengeRepository.findById(challengeIdLong)
                .orElseThrow(() -> new RuntimeException("Challenge not found"));

        if (!challenge.getIsActive()) {
            throw new RuntimeException("Challenge is not active");
        }

        // Créer ou récupérer l'entrée UserChallenge
        UserChallenge userChallenge = userChallengeRepository.findByUserAndChallenge(user, challenge)
                .orElse(new UserChallenge());

        // Si le challenge est déjà complété, ne rien faire
        if (userChallenge.getCompleted()) {
            return;
        }

        // Si c'est un nouveau challenge, l'initialiser
        if (userChallenge.getId() == null) {
            userChallenge.setUser(user);
            userChallenge.setChallenge(challenge);
            userChallenge.setProgressSteps(0);
            userChallenge.setProgressPercentage(0.0);
        }

        // Incrémenter les étapes de progression
        int newSteps = userChallenge.getProgressSteps() + 1;
        userChallenge.setProgressSteps(newSteps);

        // Calculer le nombre total d'étapes basé sur les requirements
        int totalSteps = challenge.getRequirements() != null ?
            challenge.getRequirements().split("\\|").length : 4; // Par défaut 4 étapes

        // Calculer le pourcentage
        double newPercentage = Math.min(1.0, (double) newSteps / totalSteps);
        userChallenge.setProgressPercentage(newPercentage);

        userChallengeRepository.save(userChallenge);

        log.info("User {} updated progress for challenge {} to {}%",
                username, challenge.getTitle(), (int)(newPercentage * 100));
    }
}