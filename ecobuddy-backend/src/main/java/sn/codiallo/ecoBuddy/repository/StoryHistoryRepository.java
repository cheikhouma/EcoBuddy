package sn.codiallo.ecoBuddy.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import sn.codiallo.ecoBuddy.model.StoryHistory;
import sn.codiallo.ecoBuddy.model.User;

import java.util.List;
import java.util.Optional;

@Repository
public interface StoryHistoryRepository extends JpaRepository<StoryHistory, Long> {

    // Récupérer l'historique d'un utilisateur, trié par date (plus récent d'abord)
    List<StoryHistory> findByUserOrderByCompletedAtDesc(User user);

    // Récupérer l'historique paginé d'un utilisateur
    Page<StoryHistory> findByUserOrderByCompletedAtDesc(User user, Pageable pageable);

    // Récupérer une histoire spécifique par son sessionId
    Optional<StoryHistory> findBySessionIdAndUser(String sessionId, User user);

    // Compter les histoires terminées d'un utilisateur
    Long countByUserAndStatus(User user, StoryHistory.StoryStatus status);

    // Calculer le total des points gagnés par un utilisateur
    @Query("SELECT COALESCE(SUM(sh.totalPoints), 0) FROM StoryHistory sh WHERE sh.user = :user")
    Long sumTotalPointsByUser(@Param("user") User user);

    // Récupérer les histoires par thème
    List<StoryHistory> findByUserAndThemeOrderByCompletedAtDesc(User user, String theme);

    // Compter les histoires par statut
    Long countByUserAndStatusOrderByCompletedAtDesc(User user, StoryHistory.StoryStatus status);

    // Vérifier si une histoire existe déjà (éviter les doublons)
    boolean existsBySessionIdAndUser(String sessionId, User user);
}