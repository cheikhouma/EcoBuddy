# Test du système de Challenges

## Endpoints à tester :

### 1. Récupérer les challenges
```bash
curl -X GET http://localhost:8080/challenges \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

### 2. Mettre à jour la progression (clic sur "Progresser")
```bash
curl -X POST http://localhost:8080/challenges/progress \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"challengeId": "1"}'
```

### 3. Compléter un challenge (clic sur "Terminer")
```bash
curl -X POST http://localhost:8080/challenges/complete \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"challengeId": "1"}'
```

### 4. Récupérer les challenges complétés
```bash
curl -X GET http://localhost:8080/challenges/completed \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

## Scénario de test :

1. **Démarrer le backend** : `cd ecobuddy-backend && ./mvnw spring-boot:run`
2. **S'authentifier** pour obtenir un token JWT
3. **Récupérer la liste des challenges** - doit afficher 10 challenges prédéfinis
4. **Cliquer sur "Progresser"** plusieurs fois sur un challenge - la progression doit augmenter de 25% à chaque clic (4 étapes = 100%)
5. **Quand la progression atteint 100%**, le bouton "Terminer" devient actif
6. **Cliquer sur "Terminer"** - l'utilisateur gagne les points et le challenge apparaît dans "Complétés"

## Base de données :

Le système créera automatiquement ces tables :
- `challenges` (10 défis prédéfinis)
- `user_challenges` (progression des utilisateurs)
- `users` (comptes utilisateurs)

## Comportement attendu :

✅ **Progression incrémentale** : Chaque clic sur "Progresser" ajoute 25% (ou selon le nombre d'étapes du défi)
✅ **Persistance** : La progression est sauvegardée en base de données
✅ **Validation** : Impossible de compléter un défi à 50% de progression
✅ **Points** : Les points sont ajoutés au profil utilisateur lors de la complétion
✅ **Interface** : Le frontend affiche correctement la barre de progression et les boutons