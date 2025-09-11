package sn.codiallo.ecoBuddy.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.codiallo.ecoBuddy.model.Challenge;

import java.util.List;

@Repository
public interface ChallengeRepository extends JpaRepository<Challenge, Long> {
    
    List<Challenge> findByIsActiveTrueOrderByCreatedAtDesc();
    
    List<Challenge> findByIsActiveTrue();
}