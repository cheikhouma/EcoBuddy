package sn.codiallo.ecoBuddy.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.codiallo.ecoBuddy.model.NarrativeSession;
import sn.codiallo.ecoBuddy.model.User;

import java.util.List;
import java.util.Optional;

@Repository
public interface NarrativeSessionRepository extends JpaRepository<NarrativeSession, Long> {
    
    Optional<NarrativeSession> findBySessionId(String sessionId);
    
    List<NarrativeSession> findByUserAndIsActiveTrue(User user);
    
    List<NarrativeSession> findByUserOrderByCreatedAtDesc(User user);
    
    Optional<NarrativeSession> findByUserAndIsActiveTrueOrderByUpdatedAtDesc(User user);
    
    // Compter les histoires terminées (sessions inactives)
    Long countByUserAndIsActiveFalse(User user);
}