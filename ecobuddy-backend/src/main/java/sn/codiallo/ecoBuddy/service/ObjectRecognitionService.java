package sn.codiallo.ecoBuddy.service;

import sn.codiallo.ecoBuddy.dto.ObjectRecognitionResult;

/**
 * Interface pour la reconnaissance d'objets.
 * Cette interface sera implémentée par:
 * 1. MockObjectRecognitionService (implémentation actuelle)
 * 2. TensorFlowLiteObjectRecognitionService (implémentation future)
 */
public interface ObjectRecognitionService {
    
    /**
     * Reconnaît un objet à partir de son nom (mock) ou d'une image (TensorFlow Lite)
     * 
     * @param input L'entrée pour la reconnaissance (nom pour mock, image pour TF Lite)
     * @return Le résultat de la reconnaissance
     */
    ObjectRecognitionResult recognizeObject(Object input);
    
    /**
     * Indique si le service est basé sur l'IA
     * 
     * @return true si c'est TensorFlow Lite, false si c'est mock
     */
    boolean isAiPowered();
    
    /**
     * Retourne le nom du service
     * 
     * @return Nom du service de reconnaissance
     */
    String getServiceName();
}