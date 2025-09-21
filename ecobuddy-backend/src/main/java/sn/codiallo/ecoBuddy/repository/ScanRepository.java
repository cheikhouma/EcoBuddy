package sn.codiallo.ecoBuddy.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.codiallo.ecoBuddy.model.Scan;
import sn.codiallo.ecoBuddy.model.User;

@Repository
public interface ScanRepository extends JpaRepository<Scan, Long> {
    
    // Compte le nombre de scans pour un utilisateur donné
    Long countByUser(User user);
}