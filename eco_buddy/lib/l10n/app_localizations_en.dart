// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EcoBuddy';

  @override
  String get ecologicalAssistant => '🌱 Your intelligent ecological assistant';

  @override
  String get loadingText => 'Loading...';

  @override
  String get home => 'Home';

  @override
  String get scanner => 'Scanner';

  @override
  String get errorLoading => 'Loading error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get continue_ => 'Continue';

  @override
  String get or => 'or';

  @override
  String get points => 'points';

  @override
  String get pts => 'pts';

  @override
  String get level => 'Level';

  @override
  String get usernameRequired => 'Username required';

  @override
  String get passwordRequired => 'Password required';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get connectToContinue => 'Log in to continue your ecological journey';

  @override
  String get loginTitle => 'Login';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get login => 'Log in';

  @override
  String newToApp(String appName) {
    return 'New to $appName?';
  }

  @override
  String get createAccount => 'Create account';

  @override
  String signupFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get createAccountSubtitle =>
      'Create your account to start your ecological journey';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get age => 'Age';

  @override
  String get yourAge => 'Your age';

  @override
  String get minimum6Characters => 'Minimum 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get repeatPassword => 'Repeat your password';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get signupTitle => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get termsConditionsPrivacy =>
      'By creating an account, you accept our terms of use and privacy policy.';

  @override
  String get usernameMinLength => 'Username must contain at least 3 characters';

  @override
  String get usernameMaxLength => 'Username cannot exceed 50 characters';

  @override
  String get emailMaxLength => 'Email cannot exceed 100 characters';

  @override
  String get passwordMinLength => 'Password must contain at least 6 characters';

  @override
  String get passwordMaxLength => 'Password cannot exceed 128 characters';

  @override
  String get weakPassword =>
      'Password too weak. Use uppercase, lowercase, numbers or special characters';

  @override
  String get ageRequired => 'Age required';

  @override
  String get invalidAge => 'Age must be a valid number';

  @override
  String get minimumAge =>
      'You must be at least 13 years old to create an account';

  @override
  String get invalidAgeRange => 'Invalid age';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get user => 'User';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get continueEcologicalJourney => 'Continue your ecological journey!';

  @override
  String get totalPoints => 'Total points';

  @override
  String get challengesCompleted => 'Challenges completed';

  @override
  String get arScanner => 'AR Scanner';

  @override
  String get discoverObjectImpact => 'Discover your objects\' impact';

  @override
  String get newStory => 'New story';

  @override
  String get liveEcologicalAdventure => 'Live an ecological adventure';

  @override
  String get dailyChallenges => 'Daily challenges';

  @override
  String get takeOnNewChallenges => 'Take on new challenges';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get seeYourPosition => 'See your position';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get plasticBottleScan => 'Plastic bottle scan';

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String plusPoints(int points) {
    return '+$points points';
  }

  @override
  String get challengeRecyclingCompleted => '\"Recycling\" challenge completed';

  @override
  String get storyMagicalForestCompleted =>
      'Story \"The Magical Forest\" completed';

  @override
  String get progress => 'Progress';

  @override
  String get ecoCitizenLevel => 'Eco-Citizen Level';

  @override
  String get monthlyGoal => 'Monthly goal';

  @override
  String challengesGoal(int current, int total) {
    return '$current/$total challenges';
  }

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get seeAll => 'See all';

  @override
  String get noLeaderboardData => 'No leaderboard data';

  @override
  String get completeChallengesForRanking =>
      'Complete challenges to appear in the leaderboard!';

  @override
  String andOthers(int count) {
    return 'and $count others...';
  }

  @override
  String userPoints(int points) {
    return '$points pts';
  }

  @override
  String userChallenges(int count) {
    return '$count challenges';
  }

  @override
  String get loadingLeaderboard => 'Loading leaderboard...';

  @override
  String get completeProfile => 'Complete your profile';

  @override
  String get addLocationForChallenges =>
      'Add your location to discover challenges near you!';

  @override
  String get later => 'Later';

  @override
  String get complete => 'Complete';

  @override
  String get refresh => 'Refresh';

  @override
  String get filter => 'Filter';

  @override
  String get ecoChamp => 'Top 3 Eco-Champions';

  @override
  String get top3 => 'Top 3 Eco-Champions';

  @override
  String get fullLeaderboard => 'Full leaderboard';

  @override
  String get yourCurrentPosition => 'Your current position';

  @override
  String get notRanked => 'Not ranked';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get filterLeaderboard => 'Filter leaderboard';

  @override
  String get friendsOnly => 'Friends only';

  @override
  String get localRegion => 'Local region';

  @override
  String get apply => 'Apply';

  @override
  String ecologicalPoints(int points) {
    return '$points ecological points';
  }

  @override
  String get challenges => 'Challenges';

  @override
  String get scans => 'Scans';

  @override
  String get stories => 'Stories';

  @override
  String get badgesEarned => 'Badges earned';

  @override
  String get noBadgesYet => 'No badges yet';

  @override
  String get ecologicalChallenges => 'Ecological Challenges';

  @override
  String get activeChallenges => 'Active challenges';

  @override
  String get activeChallengesCount => 'Active challenges';

  @override
  String get successfulChallenges => 'Successful challenges';

  @override
  String get completedChallenges => 'Completed challenges';

  @override
  String get noActiveChallenges => 'No active challenges';

  @override
  String get allChallengesCompleted => 'All your challenges are completed!';

  @override
  String get noCompletedChallenges => 'No completed challenges';

  @override
  String get startYourFirstChallenges => 'Start your first challenges!';

  @override
  String get loadingError => 'Loading error';

  @override
  String get startFirstChallenges => 'Start your first challenges!';

  @override
  String get challengesLeaderboard => 'Challenges leaderboard';

  @override
  String get topChallengesThisWeek => 'Top challenges this week';

  @override
  String get challengeCompleted => 'Challenge completed!';

  @override
  String get congratulationsChallenge =>
      'Congratulations! You have completed this ecological challenge.';

  @override
  String get pointsEarneds => 'points earned!';

  @override
  String get goodChoice => 'Good choice';

  @override
  String get viewResults => 'View results';

  @override
  String get continueStory => 'Continue story';

  @override
  String get storyCompleted => 'Story completed';

  @override
  String totalPoints_(int points) {
    return 'Total: $points points';
  }

  @override
  String get timeRemaining => 'Time remaining';

  @override
  String get expired => 'Expired';

  @override
  String daysRemaining(int days) {
    return '${days}d remaining';
  }

  @override
  String hoursRemaining(int hours) {
    return '${hours}h remaining';
  }

  @override
  String minutesRemaining(int minutes) {
    return '${minutes}min remaining';
  }

  @override
  String creatingUniqueEcoAdventure(int chapter) {
    return 'Creating a unique ecological adventure for you starting in chapter $chapter';
  }

  @override
  String continuingYourStory(int chapter) {
    return 'Continuing your story at chapter $chapter';
  }

  @override
  String get whatDoYouWantToDo => 'What do you want to do?';

  @override
  String get welcomeToInteractiveStories => 'Welcome to interactive stories!';

  @override
  String get startNewStory => 'Start new story';

  @override
  String get storyProgress => 'Story progress';

  @override
  String chapter(int number) {
    return 'Chapter $number';
  }

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get storyCompletedSuccessfully => 'Story completed successfully';

  @override
  String ecologicalPointsEarned(int points) {
    return '$points ecological points earned!';
  }

  @override
  String get mainMenu => 'Main menu';

  @override
  String get oopsAnErrorOccurred => 'Oops! An error occurred';

  @override
  String get smartARScanner => 'Smart AR\nScanner';

  @override
  String get discoverEcologicalImpact =>
      'Instantly discover the ecological impact of any object thanks to artificial intelligence!';

  @override
  String get multipleChoices => 'Multiple choices';

  @override
  String get suspense => 'Suspense';

  @override
  String get transformYourDaily =>
      'Transform your daily routine with fun ecological challenges and become an environmental hero!';

  @override
  String get ecoCitizensCommunity => 'Eco-Citizens\nCommunity';

  @override
  String get join => 'Join';

  @override
  String get joinThousandsOfEcoWarriors =>
      'Join thousands of eco-warriors and participate in the world\'s largest ecological movement!';

  @override
  String get ranking => 'Ranking';

  @override
  String get sharing => 'Sharing';

  @override
  String get impact => 'Impact';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get scanObjectsDiscoverImpact =>
      'Scan your objects and discover their environmental impact';

  @override
  String get takeChallengesEarnPoints => 'Take on challenges and earn points';

  @override
  String get description => 'Description';

  @override
  String get progression => 'Progression';

  @override
  String percentCompleted(int percent) {
    return '$percent% completed';
  }

  @override
  String get markProgress => 'Mark progress';

  @override
  String get finish => 'Finish';

  @override
  String get locked => 'Locked';

  @override
  String get settings => 'Settings';

  @override
  String get appSettings => 'App settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get aboutSupport => 'About & Support';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get enableDarkTheme => 'Enable dark theme';

  @override
  String get language => 'Language';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get vibrations => 'Vibrations';

  @override
  String get hapticFeedback => 'Haptic feedback';

  @override
  String get sounds => 'Sounds';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get receiveNotifications => 'Receive notifications';

  @override
  String get dailyChallengesNotif => 'Daily challenges';

  @override
  String get newChallengesReminder => 'New challenges reminders';

  @override
  String get leaderboardNotif => 'Leaderboard';

  @override
  String get leaderboardNotifications => 'Leaderboard notifications';

  @override
  String get activityReminders => 'Activity reminders';

  @override
  String get whenStopBeingActive => 'When to stop being active';

  @override
  String get location => 'Location';

  @override
  String get shareLocation => 'Share your location';

  @override
  String get usageData => 'Usage data';

  @override
  String get shareAnonymousData => 'Share anonymous data';

  @override
  String get security => 'Security';

  @override
  String get authenticationSecurity => 'Authentication and security';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get helpFAQ => 'Help & FAQ';

  @override
  String get frequentQuestions => 'Frequently asked questions';

  @override
  String get contactUs => 'Contact us';

  @override
  String get technicalSupport => 'Technical support';

  @override
  String get rateApp => 'Rate the app';

  @override
  String get giveYourFeedback => 'Give your feedback';

  @override
  String get about => 'About';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get logout => 'Log out';

  @override
  String get logoutFromAccount => 'Logout from your account';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String languageChangedTo(String language) {
    return 'Language changed to $language';
  }

  @override
  String get activityRemindersDialog => 'Activity reminders';

  @override
  String get everyHour => 'Every hour';

  @override
  String get everyday => 'Every day';

  @override
  String get everyWeek => 'Every week';

  @override
  String get remindersConfigured => 'Reminders configured';

  @override
  String get locationSettings => 'Location settings';

  @override
  String get findLocalChallenges => '• Find local challenges';

  @override
  String get locateRecyclingCenters => '• Locate recycling centers';

  @override
  String get seeRegionalImpact => '• See your region\'s environmental impact';

  @override
  String get participateLocalRankings => '• Participate in local rankings';

  @override
  String get decline => 'Decline';

  @override
  String get locationEnabled => 'Location enabled';

  @override
  String get allow => 'Allow';

  @override
  String get usageDataDialog => 'Usage data';

  @override
  String get anonymousUsageStats => '• Anonymous usage statistics';

  @override
  String get bugCrashReports => '• Bug and crash reports';

  @override
  String get usagePreferences => '• Usage preferences';

  @override
  String get performanceData => '• Performance data';

  @override
  String get doNotShare => 'Do not share';

  @override
  String get dataSharingEnabled => 'Data sharing enabled';

  @override
  String get accept => 'Accept';

  @override
  String get securityDialog => 'Security';

  @override
  String get changePassword => 'Change password';

  @override
  String get modifyYourPassword => 'Modify your password';

  @override
  String get biometricAuthentication => 'Biometric authentication';

  @override
  String get fingerprintFaceId => 'Fingerprint / Face ID';

  @override
  String get biometricAuthEnabled => 'Biometric authentication enabled';

  @override
  String get activeSessions => 'Active sessions';

  @override
  String get manageConnectedSessions => 'Manage your connected sessions';

  @override
  String get deleteAccountWarning => 'Deleting your account will result in:';

  @override
  String get lossAllPointsProgress => '• Loss of all your points and progress';

  @override
  String get deletionHistory => '• Deletion of your history';

  @override
  String get lossScanData => '• Loss of your scan data';

  @override
  String get deletionRanking => '• Deletion of your ranking';

  @override
  String get helpFAQDialog => 'Help & FAQ';

  @override
  String get howToScanObject => '• How to scan an object?';

  @override
  String get howToEarnPoints => '• How to earn points?';

  @override
  String get howToParticipateInChallenges =>
      '• How to participate in challenges?';

  @override
  String get howToSeeRanking => '• How to see my ranking?';

  @override
  String get forMoreHelpContact => 'For more help, contact technical support.';

  @override
  String get contactUsDialog => 'Contact us';

  @override
  String get emailCopied => 'Email copied to clipboard';

  @override
  String get phone => 'Phone';

  @override
  String get numberCopied => 'Number copied to clipboard';

  @override
  String get liveChat => 'Live chat';

  @override
  String get available9to6 => 'Available 9am-6pm';

  @override
  String get liveChatComingSoon => 'Live chat coming soon';

  @override
  String get rateEcoBuddy => 'Rate EcoBuddy';

  @override
  String thankYouRating(int rating) {
    return 'Thank you for your $rating star rating!';
  }

  @override
  String get send => 'Send';

  @override
  String get logoutDialog => 'Logout';

  @override
  String get confirmLogout => 'Are you sure you want to log out?';

  @override
  String logoutError(String error) {
    return 'Logout error: $error';
  }

  @override
  String get changePasswordDialog => 'Change password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get modify => 'Modify';

  @override
  String get activeSessionsDialog => 'Active sessions';

  @override
  String get androidCurrentDevice => 'Android - Current device';

  @override
  String get lastActivityNow => 'Last activity: now';

  @override
  String get chromeWindows => 'Chrome - Windows';

  @override
  String get lastActivity2Days => 'Last activity: 2 days ago';

  @override
  String get sessionRevoked => 'Session revoked';

  @override
  String get revoke => 'Revoke';

  @override
  String get allOtherSessionsRevoked => 'All other sessions have been revoked';

  @override
  String get revokeAll => 'Revoke all';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String get typeDeleteToConfirm => 'Please type \"DELETE\" to confirm';

  @override
  String get deletePermanentlyButton => 'Delete permanently';

  @override
  String get completeYourProfile => 'Complete your profile';

  @override
  String helloUser(String username) {
    return 'Hi $username! 👋';
  }

  @override
  String get tellUsWhereYouAre =>
      'Tell us where you are to discover challenges and recycling centers near you!';

  @override
  String get automaticLocation => '📍 Automatic location';

  @override
  String get useGpsLocation =>
      'Use your GPS position to automatically fill in your information.';

  @override
  String get locating => 'Locating...';

  @override
  String get useMyPosition => 'Use my position';

  @override
  String get orEnterManually => '✏️ Or enter manually';

  @override
  String get city => 'City *';

  @override
  String get pleaseEnterCity => 'Please enter your city';

  @override
  String get country => 'Country *';

  @override
  String get pleaseEnterCountry => 'Please enter your country';

  @override
  String get regionOptional => 'Region (optional)';

  @override
  String get privacy => 'Privacy';

  @override
  String get dataEncryptedSecure => '• Your data is encrypted and secure';

  @override
  String get neverSharedThirdParties => '• Never shared with third parties';

  @override
  String get canModifyAnytime => '• You can modify them at any time';

  @override
  String get usedOnlyImproveExperience =>
      '• Used only to improve your experience';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get completeMyProfile => 'Complete my profile';

  @override
  String get locationRetrievedSuccessfully =>
      '📍 Location retrieved successfully';

  @override
  String geolocationError(String error) {
    return '❌ Geolocation error: $error';
  }

  @override
  String get profileCompletedSuccessfully =>
      '🎉 Profile completed successfully!';

  @override
  String get yourEcologicalAssistant => 'Your intelligent ecological assistant';

  @override
  String get scanYourObjects =>
      'Scan your objects and discover their environmental impact';

  @override
  String get interactiveStories => 'Interactive stories';

  @override
  String get learnEcologyThroughAdventures =>
      'Learn ecology through captivating adventures';

  @override
  String get earnPointsAndChallenges => 'Take on challenges and earn points';

  @override
  String get discoverInstantlyEcologicalImpact =>
      'Instantly discover the ecological impact of any object using artificial intelligence!';

  @override
  String get geminiAI => 'Gemini AI';

  @override
  String get realTime => 'Real time';

  @override
  String get alternatives => 'Alternatives';

  @override
  String get liveEcologicalAdventures =>
      'Live captivating ecological adventures where every choice matters to save the planet!';

  @override
  String get dailyGreenChallenges => 'Daily Green\nChallenges';

  @override
  String get transformDailyLife =>
      'Transform your daily life with fun ecological challenges and become an environmental hero!';

  @override
  String get gamification => 'Gamification';

  @override
  String get rewards => 'Rewards';

  @override
  String get ecoWarriorsCommuntiy => 'Eco-Warriors\nCommunity';

  @override
  String get joinThousandsEcoWarriors =>
      'Join thousands of eco-warriors and participate in the largest global ecological movement!';

  @override
  String get previous => 'Previous';

  @override
  String get cameraPermissionRequired =>
      'Camera permission required to use AR scanner';

  @override
  String cameraError(String error) {
    return 'Camera error: $error';
  }

  @override
  String scannerError(String error) {
    return 'Error: $error';
  }

  @override
  String get scanWithCamera => 'Scan with camera';

  @override
  String get scanOther => 'Scan other';

  @override
  String get generatingStory => 'Generating story...';

  @override
  String get creatingUniqueEcologicalAdventure =>
      'Creating a unique ecological adventure for you';

  @override
  String get checkingPermissions => 'Checking permissions...';

  @override
  String thisFeatureRequires(String permissionName) {
    return 'This feature requires access to your $permissionName.';
  }

  @override
  String get openSettings => 'Open settings';

  @override
  String get camera => 'Camera';

  @override
  String get arScannerRequiresCamera =>
      'AR scanner requires camera access to detect objects in real time.';

  @override
  String get veryWeak => 'Very weak';

  @override
  String get veryStrong => 'Very strong';

  @override
  String get useReusableBottle => 'Use a reusable bottle';

  @override
  String get preferGlassPackaging => 'Prefer glass packaging';

  @override
  String get chooseBiodegradableAlternatives =>
      'Choose biodegradable alternatives';

  @override
  String get recycleInRightStream => 'Recycle in the right stream';

  @override
  String get reuseAsContainer => 'Reuse as container';

  @override
  String get useReusableBag => 'Use a reusable bag';

  @override
  String get avoidPlasticBags => 'Avoid plastic bags';

  @override
  String get reuseIfPossible => 'Reuse if possible';

  @override
  String get onlyLettersNumbersUnderscore =>
      'Only letters, numbers and _ are allowed';

  @override
  String get emailRequired => 'Email required';

  @override
  String get confirmationRequired => 'Confirmation required';

  @override
  String get pointsSystemTitle => 'Ecological Points System';

  @override
  String get pointsInfoTooltip => 'Points information';

  @override
  String get excellentChoice => 'Excellent ecological choice';

  @override
  String get excellentChoiceDesc => 'Sustainable, innovative, and impactful';

  @override
  String get goodChoiceTitle => 'Good choice';

  @override
  String get goodChoiceDesc => 'Environmentally responsible';

  @override
  String get averageChoice => 'Average choice';

  @override
  String get averageChoiceDesc => 'Some environmental benefits';

  @override
  String get suboptimalChoice => 'Suboptimal choice';

  @override
  String get suboptimalChoiceDesc => 'Limited impact';

  @override
  String get problematicChoice => 'Problematic choice';

  @override
  String get problematicChoiceDesc => 'Little or no ecological value';

  @override
  String get aiEvaluationNote =>
      'AI evaluates your choices based on their real environmental impact.';

  @override
  String get understood => 'Got it';

  @override
  String get yourStories => 'Your Stories';

  @override
  String get noStoriesYet => 'No stories yet';

  @override
  String get startFirstEcoAdventure => 'Start your first ecological adventure!';

  @override
  String get storiesCompleted => 'Stories Completed';

  @override
  String get totalPointsEarned => 'Total Points';

  @override
  String get storyDetails => 'Story Details';

  @override
  String pointsEarned(Object points) {
    return 'Points Earned';
  }

  @override
  String get chapters => 'Chapters';

  @override
  String get storySummary => 'Story Summary';

  @override
  String get detailedInformation => 'Detailed Information';

  @override
  String get sessionId => 'Session ID';

  @override
  String get ecologicalTheme => 'Ecological Theme';

  @override
  String get completionDate => 'Completion Date';

  @override
  String get status => 'Status';

  @override
  String get newSimilarStory => 'New Similar Story';

  @override
  String get backToHistory => 'Back to History';

  @override
  String get ecoStoryStep1 => '🌱 AI analyzing your ecological impact...';

  @override
  String get ecoStoryStep2 => ' Generating your personalized adventure...';

  @override
  String get ecoStoryStep3 => ' Finalizing your unique story...';

  @override
  String get ecoChoiceStep1 => ' Processing your choice...';

  @override
  String get ecoChoiceStep2 => ' Calculating ecological consequences...';

  @override
  String get ecoChoiceStep3 => ' Preparing the continuation of the story...';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(Object days, Object pluralS) {
    return '$days day$pluralS ago';
  }

  @override
  String weeksAgo(Object weeks, Object pluralS) {
    return '$weeks week$pluralS ago';
  }

  @override
  String monthsAgo(Object months) {
    return '$months months ago';
  }

  @override
  String get completeProfileTitle => 'Complete your profile';

  @override
  String greetingUser(Object username) {
    return 'Hello $username! 👋';
  }

  @override
  String get profileDescription =>
      'Tell us where you are to discover challenges and recycling centers near you!';

  @override
  String get autoLocationTitle => 'Automatic location';

  @override
  String get autoLocationDescription =>
      'Use your GPS position to automatically fill in your information.';

  @override
  String get locationInProgress => 'Locating...';

  @override
  String get locationSuccess => ' Location retrieved successfully';

  @override
  String locationError(Object error) {
    return ' Geolocation error: $error';
  }

  @override
  String get manualEntryTitle => ' Or enter manually';

  @override
  String get cityLabel => 'City *';

  @override
  String get cityValidator => 'Please enter your city';

  @override
  String get countryLabel => 'Country *';

  @override
  String get countryValidator => 'Please enter your country';

  @override
  String get regionLabel => 'Region (optional)';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyDetails =>
      '• Your data is encrypted and secure\n• It is never shared with third parties\n• You can modify it at any time\n• Used only to improve your experience';

  @override
  String get completeProfileButton => 'Complete my profile';

  @override
  String get profileCompleted => ' Profile completed successfully!';

  @override
  String errorGeneric(Object error) {
    return ' Error: $error';
  }

  @override
  String get registrationSuccessTitle => 'Welcome to EcoBuddy! ';

  @override
  String get registrationSuccessMessage =>
      'Thank you for joining our community! Your account has been created successfully. You can now log in to start your ecological journey.';

  @override
  String get readyToStart => 'Ready to start your adventure?';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get skipToApp => 'Skip to app';
}
