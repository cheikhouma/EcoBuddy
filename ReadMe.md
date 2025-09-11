# EcoBuddy – AI-powered Climate Education App  

## 📌 Objectif  
EcoBuddy est une application mobile éducative qui combine **IA, gamification et AR** pour sensibiliser les jeunes et les communautés au changement climatique et les encourager à agir.  

Fonctionnalités clés :  
1. **Narration interactive personnalisée** avec IA.  
2. **Gamification sociale + tableau de bord communautaire**.  
3. **Scanner AR d’objets** avec reconnaissance d’impact environnemental.  

---

## 🏗️ Architecture  

- **Frontend (Flutter)**  
  - UI mobile multiplateforme.  
  - Intégration API REST (Spring Boot).  
  - Modules : Auth, Narration, Gamification, Scanner AR, Dashboard.  

- **Backend (Spring Boot)**  
  - API RESTful.  
  - Gestion des utilisateurs, scoring, défis, objets scannés.  
  - Communication avec services IA.  
  - Base de données MySQL.  

- **IA**  
  - **Google Gemini API (free tier)** pour narration interactive + chatbot Q&A.  
  - **TensorFlow Lite/ML Kit** pour reconnaissance d’objets via caméra.  
  - Recommandations personnalisées basées sur profils + comportements.  


## ⚙️ Installation  



### 2. Backend (Spring Boot)

```bash
cd backend
./mvnw clean install
./mvnw spring-boot:run
```

* Variables d’environnement :

  * `DB_URL` : connexion MySQL
  * `GEMINI_API_KEY` : clé API Google Gemini

### 3. Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

---

## 📦 Fonctionnalités

### 1. Narration interactive IA

* L’utilisateur choisit un scénario (transport, alimentation, énergie).
* L’IA génère une histoire interactive où chaque choix a un impact environnemental.
* API : Gemini → Spring Boot → Flutter.

### 2. Gamification sociale

* Défis individuels et collectifs.
* Classements par région ou école.
* Tableau de bord global affichant l’impact cumulé.

### 3. Scanner AR

* Utilisation de **Google ML Kit / TensorFlow Lite** pour reconnaître des objets via caméra.
* L’app affiche : empreinte carbone, recyclabilité, alternatives écologiques.

---

## 🗄️ API Endpoints (Spring Boot)

* `POST /auth/signup` → Créer un compte
* `POST /auth/login` → Authentification
* `GET /narration/start` → Démarrer une session IA
* `POST /narration/choice` → Envoyer un choix utilisateur
* `GET /challenges` → Lister défis
* `POST /challenges/complete` → Marquer un défi comme réussi
* `POST /scanner/object` → Analyser un objet (retour impact carbone + alternatives)
* `GET /dashboard` → Données globales + leaderboard

---

## 🛠️ Stack technique

* **Frontend :** Flutter, Riverpod/Bloc (state management), ARKit (iOS) / ARCore (Android).
* **Backend :** Spring Boot, MySQL, Hibernate, JWT Auth.
* **IA :**

  * Gemini API pour narration et Q\&A.
  * TensorFlow Lite / Google ML Kit pour reconnaissance d’objets.
* **Infra :** Docker (optionnel), déploiement cloud (Heroku/Render/AWS).

---

## 📊 Démo (Pitch 3 min)

1. **Intro rapide (15s)** : présenter le problème → manque d’éducation pratique et engageante sur le climat.
2. **Narration IA (1 min)** : montrer un scénario interactif.
3. **Gamification (1 min)** : montrer un défi réussi + dashboard global.
4. **Scanner AR (30s)** : scanner une bouteille et voir impact carbone.
5. **Conclusion (15s)** : impact potentiel et vision future.

---

## 🚀 Roadmap

* [x] Setup Flutter + Spring Boot
* [ ] Authentification + profil utilisateur
* [ ] Narration IA (Gemini API)
* [ ] Système de défis + leaderboard
* [ ] Scanner AR (TensorFlow Lite / ML Kit)
* [ ] Tableau de bord global + API analytics
* [ ] Optimisation UX & design


## 📖 Licence

MIT
