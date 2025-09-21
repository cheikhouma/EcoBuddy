package sn.codiallo.ecoBuddy.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import sn.codiallo.ecoBuddy.model.EcoObject;

import java.util.List;
import java.util.Optional;

@Repository
public interface EcoObjectRepository extends JpaRepository<EcoObject, Long> {
    
    Optional<EcoObject> findByNameIgnoreCaseAndIsActiveTrue(String name);
    
    List<EcoObject> findByIsActiveTrueOrderByNameAsc();
    
    @Query("SELECT e FROM EcoObject e WHERE LOWER(e.name) LIKE LOWER(CONCAT('%', :keyword, '%')) AND e.isActive = true")
    List<EcoObject> findByNameContainingIgnoreCaseAndIsActiveTrue(@Param("keyword") String keyword);
    
    boolean existsByNameIgnoreCase(String name);
}