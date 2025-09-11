package sn.codiallo.ecoBuddy.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.codiallo.ecoBuddy.model.Challenge;
import sn.codiallo.ecoBuddy.repository.ChallengeRepository;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChallengeInitializerService implements ApplicationRunner {

    private final ChallengeRepository challengeRepository;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (challengeRepository.count() == 0) {
            log.info("Initializing challenges database...");
            createInitialChallenges();
            log.info("Challenges database initialized successfully");
        }
    }

    private void createInitialChallenges() {
        List<Challenge> challenges = Arrays.asList(
            // Défis faciles
            createChallenge(
                "Recyclage quotidien", 
                "Triez et recyclez vos déchets pendant 7 jours consécutifs. Photographiez vos poubelles de tri pour valider.",
                "recycling", 
                50, 
                7, 
                "easy",
                Arrays.asList(
                    "Trier les déchets plastiques",
                    "Trier les déchets papier", 
                    "Trier les déchets verre",
                    "Prendre une photo quotidienne"
                )
            ),
            
            createChallenge(
                "Douches courtes", 
                "Limitez vos douches à 5 minutes maximum pendant une semaine.",
                "water", 
                25, 
                7, 
                "easy",
                Arrays.asList(
                    "Utiliser un minuteur",
                    "Couper l'eau pendant le savonnage",
                    "Surveiller la durée quotidiennement"
                )
            ),

            createChallenge(
                "Zéro déchet plastique", 
                "Passez une journée entière sans utiliser de plastique à usage unique.",
                "recycling", 
                30, 
                1, 
                "easy",
                Arrays.asList(
                    "Éviter les sacs plastiques",
                    "Utiliser une gourde réutilisable", 
                    "Éviter les emballages plastiques",
                    "Documenter vos alternatives"
                )
            ),

            // Défis moyens
            createChallenge(
                "Transport vert", 
                "Utilisez des moyens de transport écologiques (vélo, marche, transport en commun) pendant toute la semaine.",
                "transport", 
                75, 
                7, 
                "medium",
                Arrays.asList(
                    "Éviter la voiture personnelle",
                    "Privilégier le vélo ou la marche",
                    "Utiliser les transports en commun", 
                    "Documenter vos trajets"
                )
            ),

            createChallenge(
                "Alimentation locale", 
                "Achetez uniquement des produits locaux et de saison pendant 3 jours.",
                "food", 
                60, 
                3, 
                "medium",
                Arrays.asList(
                    "Acheter au marché local",
                    "Vérifier l'origine des produits",
                    "Choisir des produits de saison", 
                    "Éviter les produits importés"
                )
            ),

            createChallenge(
                "Semaine végétarienne", 
                "Adoptez une alimentation 100% végétarienne pendant 7 jours.",
                "food", 
                80, 
                7, 
                "medium",
                Arrays.asList(
                    "Éliminer la viande et le poisson",
                    "Découvrir de nouvelles recettes végétales",
                    "Calculer votre empreinte carbone économisée"
                )
            ),

            // Défis difficiles
            createChallenge(
                "Économie d'énergie", 
                "Réduisez votre consommation électrique de 20% par rapport à la semaine précédente.",
                "energy", 
                100, 
                7, 
                "hard",
                Arrays.asList(
                    "Éteindre les lumières inutiles",
                    "Débrancher les appareils en veille", 
                    "Optimiser le chauffage/climatisation",
                    "Suivre sa consommation quotidienne"
                )
            ),

            createChallenge(
                "Zéro déchet une semaine", 
                "Produisez un minimum absolu de déchets pendant 7 jours consécutifs.",
                "recycling", 
                120, 
                7, 
                "hard",
                Arrays.asList(
                    "Refuser les emballages superflus",
                    "Réutiliser tout ce qui est possible", 
                    "Composter les déchets organiques",
                    "Peser et documenter vos déchets"
                )
            ),

            createChallenge(
                "Jardin urbain", 
                "Créez un petit jardin ou potager sur votre balcon ou dans votre jardin.",
                "environment", 
                90, 
                14, 
                "hard",
                Arrays.asList(
                    "Choisir des plantes adaptées",
                    "Préparer le sol ou les contenants",
                    "Planter et arroser régulièrement", 
                    "Documenter la croissance"
                )
            ),

            // Défis bonus
            createChallenge(
                "Réparation vs remplacement", 
                "Réparez un objet cassé au lieu de le jeter et d'en acheter un nouveau.",
                "recycling", 
                40, 
                3, 
                "medium",
                Arrays.asList(
                    "Identifier l'objet à réparer",
                    "Trouver les outils/pièces nécessaires", 
                    "Effectuer la réparation",
                    "Partager votre expérience"
                )
            )
        );

        challengeRepository.saveAll(challenges);
    }

    private Challenge createChallenge(String title, String description, String category, 
                                   int points, int durationDays, String difficulty, 
                                   List<String> requirements) {
        Challenge challenge = new Challenge();
        challenge.setTitle(title);
        challenge.setDescription(description);
        challenge.setCategory(category);
        challenge.setPoints(points);
        challenge.setDurationDays(durationDays);
        challenge.setDifficulty(difficulty);
        challenge.setRequirements(String.join("|", requirements)); // Stocker comme string séparée par |
        challenge.setIsActive(true);
        challenge.setCreatedAt(LocalDateTime.now());
        return challenge;
    }
}