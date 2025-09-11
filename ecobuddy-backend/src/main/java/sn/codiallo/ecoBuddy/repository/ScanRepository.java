package sn.codiallo.ecoBuddy.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.codiallo.ecoBuddy.model.User;

@Repository
public interface ScanRepository extends JpaRepository<Object, Long> {
    
    // Cette méthode sera implémentée quand le modèle Scan sera créé
    // Pour l'instant, on retourne 0 par défaut
    default Long countByUser(User user) {
        return 0L;
    }
}