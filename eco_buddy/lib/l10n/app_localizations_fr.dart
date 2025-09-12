// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'EcoBuddy';

  @override
  String get ecologicalAssistant => '🌱 Votre assistant écologique intelligent';

  @override
  String get loadingText => 'Chargement...';

  @override
  String get home => 'Accueil';

  @override
  String get scanner => 'Scanner';

  @override
  String get errorLoading => 'Erreur de chargement';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Sauvegarder';

  @override
  String get close => 'Fermer';

  @override
  String get continue_ => 'Continuer';

  @override
  String get or => 'ou';

  @override
  String get points => 'points';

  @override
  String get pts => 'pts';

  @override
  String get level => 'Niveau';

  @override
  String get usernameRequired => 'Nom d\'utilisateur requis';

  @override
  String get passwordRequired => 'Mot de passe requis';

  @override
  String loginFailed(String error) {
    return 'Connexion échouée: $error';
  }

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String get connectToContinue =>
      'Connectez-vous pour continuer votre parcours écologique';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get enterUsername => 'Entrez votre nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get login => 'Se connecter';

  @override
  String newToApp(String appName) {
    return 'Nouveau sur $appName ?';
  }

  @override
  String get createAccount => 'Créer un compte';

  @override
  String signupFailed(String error) {
    return 'Inscription échouée: $error';
  }

  @override
  String get createAccountSubtitle =>
      'Créez votre compte pour commencer votre parcours écologique';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Entrez votre email';

  @override
  String get age => 'Âge';

  @override
  String get yourAge => 'Votre âge';

  @override
  String get minimum6Characters => 'Minimum 6 caractères';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get repeatPassword => 'Répétez votre mot de passe';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get signupTitle => 'Inscription';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get termsConditionsPrivacy =>
      'En créant un compte, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité.';

  @override
  String get usernameMinLength =>
      'Le nom d\'utilisateur doit contenir au moins 3 caractères';

  @override
  String get usernameMaxLength =>
      'Le nom d\'utilisateur ne peut pas dépasser 50 caractères';

  @override
  String get emailMaxLength => 'L\'email ne peut pas dépasser 100 caractères';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordMaxLength =>
      'Le mot de passe ne peut pas dépasser 128 caractères';

  @override
  String get weakPassword =>
      'Mot de passe trop faible. Utilisez majuscules, minuscules, chiffres ou caractères spéciaux';

  @override
  String get ageRequired => 'Âge requis';

  @override
  String get invalidAge => 'L\'âge doit être un nombre valide';

  @override
  String get minimumAge =>
      'Vous devez avoir au moins 13 ans pour créer un compte';

  @override
  String get invalidAgeRange => 'Âge invalide';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get user => 'Utilisateur';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get continueEcologicalJourney =>
      'Continuez votre parcours écologique !';

  @override
  String get totalPoints => 'Points totaux';

  @override
  String get challengesCompleted => 'Défis réalisés';

  @override
  String get arScanner => 'Scanner AR';

  @override
  String get discoverObjectImpact => 'Découvrez l\'impact de vos objets';

  @override
  String get newStory => 'Nouvelle histoire';

  @override
  String get liveEcologicalAdventure => 'Vivez une aventure écologique';

  @override
  String get dailyChallenges => 'Défis du jour';

  @override
  String get takeOnNewChallenges => 'Relevez de nouveaux défis';

  @override
  String get leaderboard => 'Classement';

  @override
  String get seeYourPosition => 'Voir votre position';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get plasticBottleScan => 'Scan d\'une bouteille plastique';

  @override
  String hoursAgo(int hours) {
    return 'Il y a $hours heures';
  }

  @override
  String plusPoints(int points) {
    return '+$points points';
  }

  @override
  String get challengeRecyclingCompleted => 'Défi \"Recyclage\" terminé';

  @override
  String daysAgo(int days) {
    return 'Il y a $days jour';
  }

  @override
  String get storyMagicalForestCompleted =>
      'Histoire \"La Forêt Magique\" complétée';

  @override
  String get progress => 'Progression';

  @override
  String get ecoCitizenLevel => 'Niveau Éco-Citoyen';

  @override
  String get monthlyGoal => 'Objectif mensuel';

  @override
  String challengesGoal(int current, int total) {
    return '$current/$total défis';
  }

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get noLeaderboardData => 'Aucune donnée de classement';

  @override
  String get completeChallengesForRanking =>
      'Complétez des défis pour apparaître dans le classement !';

  @override
  String andOthers(int count) {
    return 'et $count autres...';
  }

  @override
  String userPoints(int points) {
    return '$points pts';
  }

  @override
  String userChallenges(int count) {
    return '$count défis';
  }

  @override
  String get loadingLeaderboard => 'Chargement du classement...';

  @override
  String get completeProfile => 'Complétez votre profil';

  @override
  String get addLocationForChallenges =>
      'Ajoutez votre localisation pour découvrir des défis près de chez vous !';

  @override
  String get later => 'Plus tard';

  @override
  String get complete => 'Compléter';

  @override
  String get refresh => 'Actualiser';

  @override
  String get filter => 'Filtrer';

  @override
  String get fullLeaderboard => 'Classement complet';

  @override
  String get yourCurrentPosition => 'Votre position actuelle';

  @override
  String get notRanked => 'Non classé';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String get year => 'Année';

  @override
  String get filterLeaderboard => 'Filtrer le classement';

  @override
  String get friendsOnly => 'Amis uniquement';

  @override
  String get localRegion => 'Région locale';

  @override
  String get apply => 'Appliquer';

  @override
  String ecologicalPoints(int points) {
    return '$points points écologiques';
  }

  @override
  String get challenges => 'Défis';

  @override
  String get scans => 'Scans';

  @override
  String get stories => 'Histoires';

  @override
  String get badgesEarned => 'Badges obtenus';

  @override
  String get noBadgesYet => 'Aucun badge pour le moment';

  @override
  String get ecologicalChallenges => 'Défis Écologiques';

  @override
  String get activeChallenges => 'Défis actifs';

  @override
  String get activeChallengesCount => 'Défis actifs';

  @override
  String get successfulChallenges => 'Défis réussis';

  @override
  String get completedChallenges => 'Défis terminés';

  @override
  String get noActiveChallenges => 'Aucun défi actif';

  @override
  String get allChallengesCompleted => 'Tous vos défis sont terminés !';

  @override
  String get noCompletedChallenges => 'Aucun défi terminé';

  @override
  String get startYourFirstChallenges => 'Commencez vos premiers défis !';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get startFirstChallenges => 'Commencez vos premiers défis !';

  @override
  String get challengesLeaderboard => 'Classement des défis';

  @override
  String get topChallengesThisWeek => 'Top défis cette semaine';

  @override
  String get challengeCompleted => 'Défi terminé !';

  @override
  String get congratulationsChallenge =>
      'Félicitations ! Vous avez terminé ce défi écologique.';

  @override
  String get pointsEarneds => 'points gagnés !';

  @override
  String get goodChoice => 'Bon choix';

  @override
  String get viewResults => 'View results';

  @override
  String get continueStory => 'Continue story';

  @override
  String get storyCompleted => 'Histoire complète';

  @override
  String pointsEarned(int points) {
    return '+$points points gagnés !';
  }

  @override
  String totalPoints_(int points) {
    return 'Total : $points points';
  }

  @override
  String get timeRemaining => 'Temps restant';

  @override
  String get expired => 'Expiré';

  @override
  String daysRemaining(int days) {
    return '${days}j restants';
  }

  @override
  String hoursRemaining(int hours) {
    return '${hours}h restantes';
  }

  @override
  String minutesRemaining(int minutes) {
    return '${minutes}min restantes';
  }

  @override
  String get creatingUniqueEcoAdventure =>
      'Création d\'une aventure écologique unique pour vous';

  @override
  String get whatDoYouWantToDo => 'Que voulez-vous faire ?';

  @override
  String get welcomeToInteractiveStories =>
      'Bienvenue dans les histoires interactives !';

  @override
  String get startNewStory => 'Commencer une nouvelle histoire';

  @override
  String get storyProgress => 'Progression de l\'histoire';

  @override
  String chapter(int number) {
    return 'Chapitre $number';
  }

  @override
  String get congratulations => 'Félicitations !';

  @override
  String get storyCompletedSuccessfully => 'Histoire terminée avec succès';

  @override
  String ecologicalPointsEarned(int points) {
    return '$points points écologiques gagnés !';
  }

  @override
  String get mainMenu => 'Menu principal';

  @override
  String get oopsAnErrorOccurred => 'Oops ! Une erreur s\'est produite';

  @override
  String get smartARScanner => 'Scanner AR\nIntelligent';

  @override
  String get discoverEcologicalImpact =>
      'Découvrez instantanément l\'impact écologique de n\'importe quel objet grâce à l\'intelligence artificielle !';

  @override
  String get multipleChoices => 'Choix multiples';

  @override
  String get suspense => 'Suspense';

  @override
  String get transformYourDaily =>
      'Transformez votre quotidien avec des défis écologiques amusants et devenez un héros de l\'environnement !';

  @override
  String get ecoCitizensCommunity => 'Communauté\nÉco-citoyens';

  @override
  String get join => 'Rejoignez';

  @override
  String get joinThousandsOfEcoWarriors =>
      'Rejoignez des milliers d\'éco-warriors et participez au plus grand mouvement écologique mondial !';

  @override
  String get ranking => 'Classement';

  @override
  String get sharing => 'Partage';

  @override
  String get impact => 'Impact';

  @override
  String get getStarted => 'Commencer';

  @override
  String get next => 'Suivant';

  @override
  String get scanObjectsDiscoverImpact =>
      'Scannez vos objets et découvrez leur impact environnemental';

  @override
  String get takeChallengesEarnPoints =>
      'Relevez des défis et gagnez des points';

  @override
  String get description => 'Description';

  @override
  String get progression => 'Progression';

  @override
  String percentCompleted(int percent) {
    return '$percent% complété';
  }

  @override
  String get markProgress => 'Progression';

  @override
  String get finish => 'Terminer';

  @override
  String get locked => 'Verrouillé';

  @override
  String get settings => 'Paramètres';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacySecurity => 'Confidentialité & Sécurité';

  @override
  String get aboutSupport => 'À propos & Support';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get enableDarkTheme => 'Activer le thème sombre';

  @override
  String get language => 'Langue';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get vibrations => 'Vibrations';

  @override
  String get hapticFeedback => 'Retour haptique';

  @override
  String get sounds => 'Sons';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get receiveNotifications => 'Recevoir les notifications';

  @override
  String get dailyChallengesNotif => 'Défis quotidiens';

  @override
  String get newChallengesReminder => 'Rappels des nouveaux défis';

  @override
  String get leaderboardNotif => 'Classement';

  @override
  String get leaderboardNotifications => 'Notifications de classement';

  @override
  String get activityReminders => 'Rappels d\'activité';

  @override
  String get whenStopBeingActive => 'Quand arrêter d\'être actif';

  @override
  String get location => 'Localisation';

  @override
  String get shareLocation => 'Partager votre localisation';

  @override
  String get usageData => 'Données d\'usage';

  @override
  String get shareAnonymousData => 'Partager les données anonymes';

  @override
  String get security => 'Sécurité';

  @override
  String get authenticationSecurity => 'Authentification et sécurité';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get deletePermanently => 'Supprimer définitivement';

  @override
  String get helpFAQ => 'Aide & FAQ';

  @override
  String get frequentQuestions => 'Questions fréquentes';

  @override
  String get contactUs => 'Nous contacter';

  @override
  String get technicalSupport => 'Support technique';

  @override
  String get rateApp => 'Évaluer l\'app';

  @override
  String get giveYourFeedback => 'Donner votre avis';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutFromAccount => 'Déconnexion de votre compte';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get invalidEmailFormat => 'Format d\'email invalide';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String errorMessage(String error) {
    return 'Erreur: $error';
  }

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String languageChangedTo(String language) {
    return 'Langue changée en $language';
  }

  @override
  String get activityRemindersDialog => 'Rappels d\'activité';

  @override
  String get everyHour => 'Toutes les heures';

  @override
  String get everyday => 'Tous les jours';

  @override
  String get everyWeek => 'Toutes les semaines';

  @override
  String get remindersConfigured => 'Rappels configurés';

  @override
  String get locationSettings => 'Paramètres de localisation';

  @override
  String get findLocalChallenges => '• Trouver des défis locaux';

  @override
  String get locateRecyclingCenters => '• Localiser les centres de recyclage';

  @override
  String get seeRegionalImpact =>
      '• Voir l\'impact environnemental de votre région';

  @override
  String get participateLocalRankings => '• Participer aux classements locaux';

  @override
  String get decline => 'Refuser';

  @override
  String get locationEnabled => 'Localisation activée';

  @override
  String get allow => 'Autoriser';

  @override
  String get usageDataDialog => 'Données d\'usage';

  @override
  String get anonymousUsageStats => '• Statistiques d\'utilisation anonymes';

  @override
  String get bugCrashReports => '• Rapport de bugs et plantages';

  @override
  String get usagePreferences => '• Préférences d\'utilisation';

  @override
  String get performanceData => '• Données de performance';

  @override
  String get doNotShare => 'Ne pas partager';

  @override
  String get dataSharingEnabled => 'Partage de données activé';

  @override
  String get accept => 'Accepter';

  @override
  String get securityDialog => 'Sécurité';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get modifyYourPassword => 'Modifier votre mot de passe';

  @override
  String get biometricAuthentication => 'Authentification biométrique';

  @override
  String get fingerprintFaceId => 'Empreinte digitale / Face ID';

  @override
  String get biometricAuthEnabled => 'Authentification biométrique activée';

  @override
  String get activeSessions => 'Sessions actives';

  @override
  String get manageConnectedSessions => 'Gérer vos sessions connectées';

  @override
  String get deleteAccountWarning =>
      'La suppression de votre compte entraînera:';

  @override
  String get lossAllPointsProgress => '• Perte de tous vos points et progrès';

  @override
  String get deletionHistory => '• Suppression de votre historique';

  @override
  String get lossScanData => '• Perte de vos données de scan';

  @override
  String get deletionRanking => '• Suppression de votre classement';

  @override
  String get helpFAQDialog => 'Aide & FAQ';

  @override
  String get howToScanObject => '• Comment scanner un objet ?';

  @override
  String get howToEarnPoints => '• Comment gagner des points ?';

  @override
  String get howToParticipateInChallenges => '• Comment participer aux défis ?';

  @override
  String get howToSeeRanking => '• Comment voir mon classement ?';

  @override
  String get forMoreHelpContact =>
      'Pour plus d\'aide, contactez le support technique.';

  @override
  String get contactUsDialog => 'Nous contacter';

  @override
  String get emailCopied => 'Email copié dans le presse-papiers';

  @override
  String get phone => 'Téléphone';

  @override
  String get numberCopied => 'Numéro copié dans le presse-papiers';

  @override
  String get liveChat => 'Chat en direct';

  @override
  String get available9to6 => 'Disponible 9h-18h';

  @override
  String get liveChatComingSoon => 'Chat en direct bientôt disponible';

  @override
  String get rateEcoBuddy => 'Évaluer EcoBuddy';

  @override
  String thankYouRating(int rating) {
    return 'Merci pour votre note de $rating étoile !';
  }

  @override
  String get send => 'Envoyer';

  @override
  String get logoutDialog => 'Déconnexion';

  @override
  String get confirmLogout => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String logoutError(String error) {
    return 'Erreur lors de la déconnexion: $error';
  }

  @override
  String get changePasswordDialog => 'Changer le mot de passe';

  @override
  String get passwordChangedSuccessfully => 'Mot de passe modifié avec succès';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get modify => 'Modifier';

  @override
  String get activeSessionsDialog => 'Sessions actives';

  @override
  String get androidCurrentDevice => 'Android - Appareil actuel';

  @override
  String get lastActivityNow => 'Dernière activité: maintenant';

  @override
  String get chromeWindows => 'Chrome - Windows';

  @override
  String get lastActivity2Days => 'Dernière activité: il y a 2 jours';

  @override
  String get sessionRevoked => 'Session révoquée';

  @override
  String get revoke => 'Révoquer';

  @override
  String get allOtherSessionsRevoked =>
      'Toutes les autres sessions ont été révoquées';

  @override
  String get revokeAll => 'Révoquer toutes';

  @override
  String get accountDeletedSuccessfully => 'Compte supprimé avec succès';

  @override
  String get typeDeleteToConfirm =>
      'Veuillez taper \"SUPPRIMER\" pour confirmer';

  @override
  String get deletePermanentlyButton => 'Supprimer définitivement';

  @override
  String get completeYourProfile => 'Compléter votre profil';

  @override
  String helloUser(String username) {
    return 'Salut $username ! 👋';
  }

  @override
  String get tellUsWhereYouAre =>
      'Dites-nous où vous êtes pour découvrir des défis et centres de recyclage près de chez vous !';

  @override
  String get automaticLocation => '📍 Localisation automatique';

  @override
  String get useGpsLocation =>
      'Utilisez votre position GPS pour remplir automatiquement vos informations.';

  @override
  String get locating => 'Localisation...';

  @override
  String get useMyPosition => 'Utiliser ma position';

  @override
  String get orEnterManually => '✏️ Ou saisissez manuellement';

  @override
  String get city => 'Ville *';

  @override
  String get pleaseEnterCity => 'Veuillez saisir votre ville';

  @override
  String get country => 'Pays *';

  @override
  String get pleaseEnterCountry => 'Veuillez saisir votre pays';

  @override
  String get regionOptional => 'Région (optionnel)';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get dataEncryptedSecure =>
      '• Vos données sont chiffrées et sécurisées';

  @override
  String get neverSharedThirdParties =>
      '• Elles ne sont jamais partagées avec des tiers';

  @override
  String get canModifyAnytime => '• Vous pouvez les modifier à tout moment';

  @override
  String get usedOnlyImproveExperience =>
      '• Utilisées uniquement pour améliorer votre expérience';

  @override
  String get skipForNow => 'Ignorer pour l\'instant';

  @override
  String get completeMyProfile => 'Compléter mon profil';

  @override
  String get locationRetrievedSuccessfully =>
      '📍 Localisation récupérée avec succès';

  @override
  String geolocationError(String error) {
    return '❌ Erreur de géolocalisation: $error';
  }

  @override
  String get profileCompletedSuccessfully => '🎉 Profil complété avec succès !';

  @override
  String get yourEcologicalAssistant =>
      'Votre assistant écologique intelligent';

  @override
  String get scanYourObjects =>
      'Scannez vos objets et découvrez leur impact environnemental';

  @override
  String get interactiveStories => 'Histoires interactives';

  @override
  String get learnEcologyThroughAdventures =>
      'Apprenez l\'écologie à travers des aventures captivantes';

  @override
  String get earnPointsAndChallenges =>
      'Relevez des défis et gagnez des points';

  @override
  String get discoverInstantlyEcologicalImpact =>
      'Découvrez instantanément l\'impact écologique de n\'importe quel objet grâce à l\'intelligence artificielle !';

  @override
  String get geminiAI => 'IA Gemini';

  @override
  String get realTime => 'Temps réel';

  @override
  String get alternatives => 'Alternatives';

  @override
  String get liveEcologicalAdventures =>
      'Vivez des aventures écologiques captivantes où vos choix façonnent l\'histoire et impactent l\'environnement.';

  @override
  String get dailyGreenChallenges => 'Défis Verts\nQuotidiens';

  @override
  String get transformDailyLife =>
      'Transformez votre quotidien avec des défis écologiques amusants et devenez un héros de l\'environnement !';

  @override
  String get gamification => 'Gamification';

  @override
  String get rewards => 'Récompenses';

  @override
  String get ecoWarriorsCommuntiy => 'Communauté\nÉco-citoyens';

  @override
  String get joinThousandsEcoWarriors =>
      'Rejoignez des milliers d\'éco-warriors et participez au plus grand mouvement écologique mondial !';

  @override
  String get previous => 'Précédent';

  @override
  String get cameraPermissionRequired =>
      'Permission caméra requise pour utiliser le scanner AR';

  @override
  String cameraError(String error) {
    return 'Erreur caméra: $error';
  }

  @override
  String scannerError(String error) {
    return 'Erreur: $error';
  }

  @override
  String get scanWithCamera => 'Scanner avec caméra';

  @override
  String get scanOther => 'Scanner autre';

  @override
  String get generatingStory => 'Génération de l\'histoire...';

  @override
  String get creatingUniqueEcologicalAdventure =>
      'Création d\'une aventure écologique unique pour vous';

  @override
  String get checkingPermissions => 'Vérification des permissions...';

  @override
  String thisFeatureRequires(String permissionName) {
    return 'Cette fonctionnalité nécessite l\'accès à votre $permissionName.';
  }

  @override
  String get openSettings => 'Ouvrir paramètres';

  @override
  String get camera => 'Caméra';

  @override
  String get arScannerRequiresCamera =>
      'Le scanner AR nécessite l\'accès à la caméra pour détecter les objets en temps réel.';

  @override
  String get veryWeak => 'Très faible';

  @override
  String get veryStrong => 'Très fort';

  @override
  String get useReusableBottle => 'Utiliser une gourde réutilisable';

  @override
  String get preferGlassPackaging => 'Privilégier les emballages en verre';

  @override
  String get chooseBiodegradableAlternatives =>
      'Choisir des alternatives biodégradables';

  @override
  String get recycleInRightStream => 'Recycler dans la bonne filière';

  @override
  String get reuseAsContainer => 'Réutiliser comme contenant';

  @override
  String get useReusableBag => 'Utiliser un sac réutilisable';

  @override
  String get avoidPlasticBags => 'Éviter les sacs plastique';

  @override
  String get reuseIfPossible => 'Réutiliser si possible';

  @override
  String get onlyLettersNumbersUnderscore =>
      'Seuls les lettres, chiffres et _ sont autorisés';

  @override
  String get emailRequired => 'Email requis';

  @override
  String get confirmationRequired => 'Confirmation requise';
}
