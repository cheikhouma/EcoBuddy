_AssertionError ('package:flutter/src/widgets/basic.dart': Failed assertion: line 340 pos 15: 'opacity >= 0.0 && opacity <= 1.0': is not true.) : login_screen : 118

Système d'historique des histoires

  Où stocker l'historique ?

  1. Base de données (recommandé) - Historique permanent avec synchronisation
   multi-appareils
  2. Local (SQLite/Hive) - Plus simple, mais limité à l'appareil

  Que stocker ?

  - Métadonnées de session : Date, durée, nombre d'étapes
  - Points totaux gagnés par histoire
  - Résumé de l'histoire (titre + première phrase)
  - Statut : Terminée/Abandonnée
  - Thème écologique abordé (transport, énergie, alimentation...)

  Interface utilisateur proposée :

  Option 1 : Onglet "Historique" dans la bottom navbar
  - Liste chronologique des histoires
  - Carte par histoire avec : date, points, titre, statut
  - Possibilité de "Rejouer une histoire similaire"

  Option 2 : Section dans le profil utilisateur
  - Statistiques globales : histoires complétées, points totaux, thèmes
  explorés
  - Dernières histoires avec aperçu rapide

  Option 3 : Écran d'accueil enrichi
  - "Continuer votre dernière histoire" si abandonnée
  - "Vos 3 dernières histoires" avec aperçu

  Fonctionnalités bonus :

  - Badges : "Explorateur écologique", "Maître du recyclage"...
  - Progression thématique : Graphique des thèmes abordés
  - Partage : "J'ai gagné 150 points en sauvant la forêt !"

  Ma recommandation :

  Option 2 (section profil) + Option 3 (accueil enrichi) pour commencer.
  Simple mais efficace, sans surcharger la navigation.

  Qu'est-ce qui vous semble le plus pertinent pour votre app ? 🤔
