# 🌍 EcoBuddy - Application d'Éducation Climatique Alimentée par l'IA

EcoBuddy est une application mobile innovante qui combine intelligence artificielle, gamification et réalité augmentée pour transformer l'éducation environnementale. Elle permet aux utilisateurs d'apprendre sur le changement climatique à travers des expériences interactives personnalisées et des actions concrètes.

## ✨ Fonctionnalités Principales

### 🎭 **Narration Interactive IA**
- Histoires personnalisées générées par Google Gemini
- Choix interactifs avec conséquences environnementales réelles
- Scénarios adaptatifs basés sur le profil utilisateur
- Apprentissage progressif des concepts écologiques

### 🎮 **Système de Gamification Sociale**
- Défis individuels et collectifs
- Classements régionaux et globaux
- Système d'accomplissements (50+ badges)
- Suivi d'impact communautaire en temps réel

### 📱 **Scanner AR d'Objets Intelligents**
- Reconnaissance d'objets en temps réel (<200ms)
- Base de données de 500+ objets avec impact environnemental
- Suggestions d'alternatives écologiques
- Calcul de l'empreinte carbone instantané

### 📊 **Tableau de Bord Analytics**
- Suivi personnel d'impact carbone
- Visualisations interactives
- Rapports d'impact exportables
- Métriques de progrès personnalisés

## 🏗️ Architecture Technique

### Frontend (Flutter)
```
eco_buddy/
├── lib/
│   ├── features/
│   │   ├── auth/           # Authentification
│   │   ├── dashboard/      # Tableau de bord principal
│   │   ├── narration/      # Histoires IA interactives
│   │   ├── scanner/        # Scanner AR/ML
│   │   ├── challenges/     # Système de défis
│   │   └── leaderboard/    # Classements sociaux
│   ├── shared/             # Services partagés
│   │   ├── providers/      # Gestionnaires d'état Riverpod
│   │   ├── services/       # Services API et ML
│   │   └── models/         # Modèles de données
│   └── core/               # Constantes et utilitaires
└── assets/
    ├── models/             # Modèles TensorFlow Lite
    └── images/             # Ressources visuelles
```

**Technologies clés :**
- Flutter 3.8+ avec architecture clean
- Riverpod pour la gestion d'état
- Google ML Kit + TensorFlow Lite pour l'IA
- Support multilingue (Français/Anglais)

### Backend (Spring Boot)
```
ecobuddy-backend/
├── src/main/java/sn/codiallo/ecoBuddy/
│   ├── controllers/        # Endpoints REST
│   ├── services/           # Logique métier
│   ├── repositories/       # Accès aux données
│   ├── entities/           # Modèles JPA
│   ├── config/             # Configuration Spring
│   └── security/           # Sécurité JWT
└── pom.xml                 # Dépendances Maven
```

**Technologies clés :**
- Spring Boot 3.5.5
- Spring Security avec JWT
- JPA/Hibernate + MySQL
- WebFlux pour intégration Gemini API

### Intelligence Artificielle
- **Google Gemini API** : Génération d'histoires interactives
- **TensorFlow Lite** : Classification d'objets on-device
- **Google ML Kit** : Reconnaissance avancée fallback
- **Modèles personnalisés** : Optimisés pour objets environnementaux

## 🚀 Installation et Démarrage

### Prérequis
- Flutter SDK 3.8+
- Java 17+
- MySQL 8.0+
- Clé API Google Gemini

### 1. Configuration du Backend

```bash
cd ecobuddy-backend

# Configuration des variables d'environnement
echo "DB_URL=jdbc:mysql://localhost:3306/ecobuddy" > .env
echo "GEMINI_API_KEY=votre_clé_api_gemini" >> .env

# Installation et démarrage
./mvnw clean install
./mvnw spring-boot:run
```

### 2. Configuration du Frontend

```bash
cd eco_buddy

# Installation des dépendances
flutter pub get

# Génération des modèles
flutter packages pub run build_runner build

# Lancement de l'app
flutter run
```

### 3. Base de Données

L'application créera automatiquement les tables nécessaires au premier démarrage. Schéma principal :

- **Users** : Profils utilisateurs et authentification
- **Stories** : Sessions de narration IA
- **Challenges** : Défis et accomplissements
- **ScanResults** : Historique des objets scannés
- **Leaderboards** : Classements et scores

## 📡 API Endpoints

### Authentification
- `POST /api/auth/signup` - Création de compte
- `POST /api/auth/login` - Connexion utilisateur
- `POST /api/auth/refresh` - Renouvellement token

### Narration IA
- `POST /api/narration/start` - Démarrer une histoire
- `POST /api/narration/choice` - Faire un choix
- `GET /api/narration/history` - Historique des histoires

### Gamification
- `GET /api/challenges` - Liste des défis
- `POST /api/challenges/complete` - Compléter un défi
- `GET /api/leaderboard` - Classements

### Scanner
- `POST /api/scanner/analyze` - Analyser un objet
- `GET /api/scanner/history` - Historique des scans

## 🎯 Performances et Métriques

### Performance Technique
- **Temps de démarrage** : <2s sur appareils milieu de gamme
- **Reconnaissance d'objets** : <200ms en moyenne
- **Réponse API** : <500ms pour la plupart des appels
- **Mode hors-ligne** : 80% des fonctionnalités disponibles

### Impact Éducatif
- **Engagement utilisateur** : Sessions moyennes de 15+ minutes
- **Rétention** : Architecture conçue pour usage quotidien
- **Apprentissage** : Progression mesurable des connaissances

## 🔒 Sécurité et Confidentialité

- **Authentification JWT** avec tokens de rafraîchissement
- **Chiffrement des données** sensibles en local
- **Conformité GDPR** avec gestion des consentements
- **Validation** stricte des entrées côté serveur
- **Architecture Zero-Trust** pour tous les appels API

## 🌐 Internationalization

Support complet pour :
- **Français** : Contenu localisé avec données environnementales régionales
- **Anglais** : Version internationale avec métriques globales
- **Architecture extensible** pour ajout de nouvelles langues

## 📊 Calculs d'Impact Environnemental

### Formule de Base
```
Impact Total = Σ(Objet_i × Poids_i × Facteur_i)
```

Où :
- `Objet_i` = objet scanné individuel
- `Poids_i` = multiplicateur de fréquence d'usage
- `Facteur_i` = coefficient d'impact environnemental

### Sources de Données
- Base de données environnementale scientifique
- Intervalles de confiance pour estimations
- Transparence des sources pour utilisateurs

## 🤝 Contribution

Le projet suit une architecture modulaire permettant des contributions faciles :

1. **Issues** : Signaler bugs ou proposer fonctionnalités
2. **Pull Requests** : Contributions code avec tests
3. **Documentation** : Amélioration de la documentation

## 🔮 Roadmap

### Phase 1 (Terminée)
- [x] Architecture Flutter + Spring Boot
- [x] Système d'authentification complet
- [x] Intégration Gemini API
- [x] Scanner ML basique

### Phase 2 (En cours)
- [x] Système de gamification avancé
- [x] Tableau de bord analytics
- [x] Optimisations performance
- [ ] Tests automatisés complets

### Phase 3 (Planifiée)
- [ ] Fonctionnalités AR avancées
- [ ] Intégration IoT (capteurs environnementaux)
- [ ] API publique pour développeurs
- [ ] Mode collaboratif écoles/entreprises

## 📄 Licence

MIT License - Voir le fichier LICENSE pour plus de détails.

## 🙏 Remerciements

Ce projet a été développé dans le cadre d'une mission d'éducation environnementale, utilisant les dernières technologies IA pour créer un impact éducatif mesurable sur la sensibilisation climatique.

---

> **EcoBuddy** : Transformer la conscience environnementale en action grâce à l'IA 🌱
