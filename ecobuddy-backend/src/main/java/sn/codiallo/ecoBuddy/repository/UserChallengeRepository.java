package sn.codiallo.ecoBuddy.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import sn.codiallo.ecoBuddy.model.Challenge;
import sn.codiallo.ecoBuddy.model.User;
import sn.codiallo.ecoBuddy.model.UserChallenge;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserChallengeRepository extends JpaRepository<UserChallenge, Long> {
    
    Optional<UserChallenge> findByUserAndChallenge(User user, Challenge challenge);
    
    List<UserChallenge> findByUserAndCompleted(User user, Boolean completed);
    
    List<UserChallenge> findByUserOrderByCompletedAtDesc(User user);
    
    boolean existsByUserAndChallengeAndCompleted(User user, Challenge challenge, Boolean completed);
    
    @Query("SELECT COUNT(uc) FROM UserChallenge uc WHERE uc.user = :user AND uc.completed = true")
    Long countCompletedChallengesByUser(@Param("user") User user);
}