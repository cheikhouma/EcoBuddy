import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'EcoBuddy'**
  String get appName;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'🌱 Your intelligent ecological assistant'**
  String get ecologicalAssistant;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// Generic loading error
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get errorLoading;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// Or separator
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Points label
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// Points abbreviation
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pts;

  /// Level label
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// Username validation error
  ///
  /// In en, this message translates to:
  /// **'Username required'**
  String get usernameRequired;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordRequired;

  /// Login failure message
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// Welcome back message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your ecological journey'**
  String get connectToContinue;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// Username label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Username field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// Password label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// New user message
  ///
  /// In en, this message translates to:
  /// **'New to {appName}?'**
  String newToApp(String appName);

  /// Create account link text
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Signup failure message
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String signupFailed(String error);

  /// Signup screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your account to start your ecological journey'**
  String get createAccountSubtitle;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// Age label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Age field hint
  ///
  /// In en, this message translates to:
  /// **'Your age'**
  String get yourAge;

  /// Password requirement
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minimum6Characters;

  /// Confirm password label
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Confirm password hint
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get repeatPassword;

  /// Signup button text
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get createMyAccount;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupTitle;

  /// Login link text
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Terms and conditions text
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you accept our terms of use and privacy policy.'**
  String get termsConditionsPrivacy;

  /// Username validation error
  ///
  /// In en, this message translates to:
  /// **'Username must contain at least 3 characters'**
  String get usernameMinLength;

  /// Username validation error
  ///
  /// In en, this message translates to:
  /// **'Username cannot exceed 50 characters'**
  String get usernameMaxLength;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Email cannot exceed 100 characters'**
  String get emailMaxLength;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters'**
  String get passwordMinLength;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password cannot exceed 128 characters'**
  String get passwordMaxLength;

  /// Weak password validation error
  ///
  /// In en, this message translates to:
  /// **'Password too weak. Use uppercase, lowercase, numbers or special characters'**
  String get weakPassword;

  /// Age validation error
  ///
  /// In en, this message translates to:
  /// **'Age required'**
  String get ageRequired;

  /// Age validation error
  ///
  /// In en, this message translates to:
  /// **'Age must be a valid number'**
  String get invalidAge;

  /// Minimum age validation error
  ///
  /// In en, this message translates to:
  /// **'You must be at least 13 years old to create an account'**
  String get minimumAge;

  /// Age range validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid age'**
  String get invalidAgeRange;

  /// Dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// User label
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// Dashboard encouragement message
  ///
  /// In en, this message translates to:
  /// **'Continue your ecological journey!'**
  String get continueEcologicalJourney;

  /// Total points label
  ///
  /// In en, this message translates to:
  /// **'Total points'**
  String get totalPoints;

  /// Challenges completed label
  ///
  /// In en, this message translates to:
  /// **'Challenges completed'**
  String get challengesCompleted;

  /// AR Scanner feature name
  ///
  /// In en, this message translates to:
  /// **'AR Scanner'**
  String get arScanner;

  /// AR Scanner description
  ///
  /// In en, this message translates to:
  /// **'Discover your objects\' impact'**
  String get discoverObjectImpact;

  /// New story feature name
  ///
  /// In en, this message translates to:
  /// **'New story'**
  String get newStory;

  /// Story feature description
  ///
  /// In en, this message translates to:
  /// **'Live an ecological adventure'**
  String get liveEcologicalAdventure;

  /// Daily challenges feature name
  ///
  /// In en, this message translates to:
  /// **'Daily challenges'**
  String get dailyChallenges;

  /// Challenges description
  ///
  /// In en, this message translates to:
  /// **'Take on new challenges'**
  String get takeOnNewChallenges;

  /// Leaderboard feature name
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// Leaderboard description
  ///
  /// In en, this message translates to:
  /// **'See your position'**
  String get seeYourPosition;

  /// Recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// Activity example
  ///
  /// In en, this message translates to:
  /// **'Plastic bottle scan'**
  String get plasticBottleScan;

  /// Time ago format
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// Points earned format
  ///
  /// In en, this message translates to:
  /// **'+{points} points'**
  String plusPoints(int points);

  /// Challenge completion example
  ///
  /// In en, this message translates to:
  /// **'\"Recycling\" challenge completed'**
  String get challengeRecyclingCompleted;

  /// Days ago format
  ///
  /// In en, this message translates to:
  /// **'{days} day ago'**
  String daysAgo(int days);

  /// Story completion example
  ///
  /// In en, this message translates to:
  /// **'Story \"The Magical Forest\" completed'**
  String get storyMagicalForestCompleted;

  /// Progress label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// User level label
  ///
  /// In en, this message translates to:
  /// **'Eco-Citizen Level'**
  String get ecoCitizenLevel;

  /// Monthly goal label
  ///
  /// In en, this message translates to:
  /// **'Monthly goal'**
  String get monthlyGoal;

  /// Challenge progress format
  ///
  /// In en, this message translates to:
  /// **'{current}/{total} challenges'**
  String challengesGoal(int current, int total);

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// See all button text
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Empty leaderboard message
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data'**
  String get noLeaderboardData;

  /// Empty leaderboard instruction
  ///
  /// In en, this message translates to:
  /// **'Complete challenges to appear in the leaderboard!'**
  String get completeChallengesForRanking;

  /// Additional users count
  ///
  /// In en, this message translates to:
  /// **'and {count} others...'**
  String andOthers(int count);

  /// User points format
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String userPoints(int points);

  /// User challenges count
  ///
  /// In en, this message translates to:
  /// **'{count} challenges'**
  String userChallenges(int count);

  /// Loading leaderboard message
  ///
  /// In en, this message translates to:
  /// **'Loading leaderboard...'**
  String get loadingLeaderboard;

  /// Complete profile action
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeProfile;

  /// Location completion message
  ///
  /// In en, this message translates to:
  /// **'Add your location to discover challenges near you!'**
  String get addLocationForChallenges;

  /// Later button text
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Filter button text
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @ecoChamp.
  ///
  /// In en, this message translates to:
  /// **'Top 3 Eco-Champions'**
  String get ecoChamp;

  /// No description provided for @top3.
  ///
  /// In en, this message translates to:
  /// **'Top 3 Eco-Champions'**
  String get top3;

  /// Full leaderboard section title
  ///
  /// In en, this message translates to:
  /// **'Full leaderboard'**
  String get fullLeaderboard;

  /// User position description
  ///
  /// In en, this message translates to:
  /// **'Your current position'**
  String get yourCurrentPosition;

  /// Not ranked status
  ///
  /// In en, this message translates to:
  /// **'Not ranked'**
  String get notRanked;

  /// Week period
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Month period
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Year period
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Filter dialog title
  ///
  /// In en, this message translates to:
  /// **'Filter leaderboard'**
  String get filterLeaderboard;

  /// Friends filter option
  ///
  /// In en, this message translates to:
  /// **'Friends only'**
  String get friendsOnly;

  /// Region filter option
  ///
  /// In en, this message translates to:
  /// **'Local region'**
  String get localRegion;

  /// Apply button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Ecological points format
  ///
  /// In en, this message translates to:
  /// **'{points} ecological points'**
  String ecologicalPoints(int points);

  /// Challenges label
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// Scans label
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get scans;

  /// Stories label
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// Badges section title
  ///
  /// In en, this message translates to:
  /// **'Badges earned'**
  String get badgesEarned;

  /// Empty badges message
  ///
  /// In en, this message translates to:
  /// **'No badges yet'**
  String get noBadgesYet;

  /// Challenges screen title
  ///
  /// In en, this message translates to:
  /// **'Ecological Challenges'**
  String get ecologicalChallenges;

  /// Active challenges section
  ///
  /// In en, this message translates to:
  /// **'Active challenges'**
  String get activeChallenges;

  /// Active challenges stat
  ///
  /// In en, this message translates to:
  /// **'Active challenges'**
  String get activeChallengesCount;

  /// Successful challenges stat
  ///
  /// In en, this message translates to:
  /// **'Successful challenges'**
  String get successfulChallenges;

  /// Completed challenges section
  ///
  /// In en, this message translates to:
  /// **'Completed challenges'**
  String get completedChallenges;

  /// Empty active challenges title
  ///
  /// In en, this message translates to:
  /// **'No active challenges'**
  String get noActiveChallenges;

  /// Empty active challenges message
  ///
  /// In en, this message translates to:
  /// **'All your challenges are completed!'**
  String get allChallengesCompleted;

  /// Empty completed challenges title
  ///
  /// In en, this message translates to:
  /// **'No completed challenges'**
  String get noCompletedChallenges;

  /// Empty completed challenges subtitle
  ///
  /// In en, this message translates to:
  /// **'Start your first challenges!'**
  String get startYourFirstChallenges;

  /// Generic loading error message
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get loadingError;

  /// Empty completed challenges message
  ///
  /// In en, this message translates to:
  /// **'Start your first challenges!'**
  String get startFirstChallenges;

  /// Challenges leaderboard section
  ///
  /// In en, this message translates to:
  /// **'Challenges leaderboard'**
  String get challengesLeaderboard;

  /// Weekly challenges leaderboard
  ///
  /// In en, this message translates to:
  /// **'Top challenges this week'**
  String get topChallengesThisWeek;

  /// Challenge completion title
  ///
  /// In en, this message translates to:
  /// **'Challenge completed!'**
  String get challengeCompleted;

  /// Challenge completion message
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have completed this ecological challenge.'**
  String get congratulationsChallenge;

  /// No description provided for @pointsEarneds.
  ///
  /// In en, this message translates to:
  /// **'points earned!'**
  String get pointsEarneds;

  /// No description provided for @goodChoice.
  ///
  /// In en, this message translates to:
  /// **'Good choice'**
  String get goodChoice;

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'Regarder les resultats'**
  String get viewResults;

  /// No description provided for @continueStory.
  ///
  /// In en, this message translates to:
  /// **'Continue story'**
  String get continueStory;

  /// No description provided for @storyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Story completed'**
  String get storyCompleted;

  /// Label for points earned in a story
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String pointsEarned(Object points);

  /// Total points message
  ///
  /// In en, this message translates to:
  /// **'Total: {points} points'**
  String totalPoints_(int points);

  /// Time remaining label
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// Expired status
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Days remaining format
  ///
  /// In en, this message translates to:
  /// **'{days}d remaining'**
  String daysRemaining(int days);

  /// Hours remaining format
  ///
  /// In en, this message translates to:
  /// **'{hours}h remaining'**
  String hoursRemaining(int hours);

  /// Minutes remaining format
  ///
  /// In en, this message translates to:
  /// **'{minutes}min remaining'**
  String minutesRemaining(int minutes);

  /// Subtitle while generating new story
  ///
  /// In en, this message translates to:
  /// **'Creating a unique ecological adventure for you starting in chapter {chapter}'**
  String creatingUniqueEcoAdventure(int chapter);

  /// Subtitle while continuing existing story
  ///
  /// In en, this message translates to:
  /// **'Continuing your story at chapter {chapter}'**
  String continuingYourStory(int chapter);

  /// Choices section title
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get whatDoYouWantToDo;

  /// Welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to interactive stories!'**
  String get welcomeToInteractiveStories;

  /// Start new story button
  ///
  /// In en, this message translates to:
  /// **'Start new story'**
  String get startNewStory;

  /// Story progress indicator title
  ///
  /// In en, this message translates to:
  /// **'Story progress'**
  String get storyProgress;

  /// Chapter number format
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapter(int number);

  /// Congratulations title
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Story completion message
  ///
  /// In en, this message translates to:
  /// **'Story completed successfully'**
  String get storyCompletedSuccessfully;

  /// Points earned message
  ///
  /// In en, this message translates to:
  /// **'{points} ecological points earned!'**
  String ecologicalPointsEarned(int points);

  /// Main menu button text
  ///
  /// In en, this message translates to:
  /// **'Main menu'**
  String get mainMenu;

  /// Error message title
  ///
  /// In en, this message translates to:
  /// **'Oops! An error occurred'**
  String get oopsAnErrorOccurred;

  /// Onboarding page 1 title
  ///
  /// In en, this message translates to:
  /// **'Smart AR\nScanner'**
  String get smartARScanner;

  /// Onboarding page 1 description
  ///
  /// In en, this message translates to:
  /// **'Instantly discover the ecological impact of any object thanks to artificial intelligence!'**
  String get discoverEcologicalImpact;

  /// Feature tag for interactive stories
  ///
  /// In en, this message translates to:
  /// **'Multiple choices'**
  String get multipleChoices;

  /// Feature tag for stories
  ///
  /// In en, this message translates to:
  /// **'Suspense'**
  String get suspense;

  /// Onboarding page 3 description
  ///
  /// In en, this message translates to:
  /// **'Transform your daily routine with fun ecological challenges and become an environmental hero!'**
  String get transformYourDaily;

  /// Onboarding page 4 title
  ///
  /// In en, this message translates to:
  /// **'Eco-Citizens\nCommunity'**
  String get ecoCitizensCommunity;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// Onboarding page 4 description
  ///
  /// In en, this message translates to:
  /// **'Join thousands of eco-warriors and participate in the world\'s largest ecological movement!'**
  String get joinThousandsOfEcoWarriors;

  /// Feature tag for community
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get ranking;

  /// Feature tag for community
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get sharing;

  /// Feature tag for community impact
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// AR Scanner feature description
  ///
  /// In en, this message translates to:
  /// **'Scan your objects and discover their environmental impact'**
  String get scanObjectsDiscoverImpact;

  /// Ecological challenges feature description
  ///
  /// In en, this message translates to:
  /// **'Take on challenges and earn points'**
  String get takeChallengesEarnPoints;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Progression label
  ///
  /// In en, this message translates to:
  /// **'Progression'**
  String get progression;

  /// Completion percentage
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed'**
  String percentCompleted(int percent);

  /// Mark progress button
  ///
  /// In en, this message translates to:
  /// **'Mark progress'**
  String get markProgress;

  /// Finish button text
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Locked status
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// App settings section
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettings;

  /// Notifications section
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Privacy & Security section
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// About & Support section
  ///
  /// In en, this message translates to:
  /// **'About & Support'**
  String get aboutSupport;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Dark mode description
  ///
  /// In en, this message translates to:
  /// **'Enable dark theme'**
  String get enableDarkTheme;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// French language
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// English language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Vibrations setting
  ///
  /// In en, this message translates to:
  /// **'Vibrations'**
  String get vibrations;

  /// Haptic feedback description
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedback;

  /// Sounds setting
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get sounds;

  /// Sound effects description
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// Push notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive notifications'**
  String get receiveNotifications;

  /// Daily challenges notifications
  ///
  /// In en, this message translates to:
  /// **'Daily challenges'**
  String get dailyChallengesNotif;

  /// New challenges reminder description
  ///
  /// In en, this message translates to:
  /// **'New challenges reminders'**
  String get newChallengesReminder;

  /// Leaderboard notifications
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardNotif;

  /// Leaderboard notifications description
  ///
  /// In en, this message translates to:
  /// **'Leaderboard notifications'**
  String get leaderboardNotifications;

  /// Activity reminders setting
  ///
  /// In en, this message translates to:
  /// **'Activity reminders'**
  String get activityReminders;

  /// Activity reminders description
  ///
  /// In en, this message translates to:
  /// **'When to stop being active'**
  String get whenStopBeingActive;

  /// Location setting
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Location sharing description
  ///
  /// In en, this message translates to:
  /// **'Share your location'**
  String get shareLocation;

  /// Usage data setting
  ///
  /// In en, this message translates to:
  /// **'Usage data'**
  String get usageData;

  /// Usage data description
  ///
  /// In en, this message translates to:
  /// **'Share anonymous data'**
  String get shareAnonymousData;

  /// Security setting
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Security description
  ///
  /// In en, this message translates to:
  /// **'Authentication and security'**
  String get authenticationSecurity;

  /// Delete account setting
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// Delete account description
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// Help & FAQ setting
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFAQ;

  /// FAQ description
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get frequentQuestions;

  /// Contact setting
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// Technical support description
  ///
  /// In en, this message translates to:
  /// **'Technical support'**
  String get technicalSupport;

  /// Rate app setting
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get rateApp;

  /// Rate app description
  ///
  /// In en, this message translates to:
  /// **'Give your feedback'**
  String get giveYourFeedback;

  /// About setting
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// Logout setting
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// Logout description
  ///
  /// In en, this message translates to:
  /// **'Logout from your account'**
  String get logoutFromAccount;

  /// Edit profile dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// Form validation error
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(String error);

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// Language change confirmation
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedTo(String language);

  /// Activity reminders dialog title
  ///
  /// In en, this message translates to:
  /// **'Activity reminders'**
  String get activityRemindersDialog;

  /// Reminder frequency option
  ///
  /// In en, this message translates to:
  /// **'Every hour'**
  String get everyHour;

  /// Reminder frequency option
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyday;

  /// Reminder frequency option
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get everyWeek;

  /// Reminders configuration success
  ///
  /// In en, this message translates to:
  /// **'Reminders configured'**
  String get remindersConfigured;

  /// Location settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Location settings'**
  String get locationSettings;

  /// Location benefit
  ///
  /// In en, this message translates to:
  /// **'• Find local challenges'**
  String get findLocalChallenges;

  /// Location benefit
  ///
  /// In en, this message translates to:
  /// **'• Locate recycling centers'**
  String get locateRecyclingCenters;

  /// Location benefit
  ///
  /// In en, this message translates to:
  /// **'• See your region\'s environmental impact'**
  String get seeRegionalImpact;

  /// Location benefit
  ///
  /// In en, this message translates to:
  /// **'• Participate in local rankings'**
  String get participateLocalRankings;

  /// Decline button text
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Location enabled confirmation
  ///
  /// In en, this message translates to:
  /// **'Location enabled'**
  String get locationEnabled;

  /// Allow button text
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// Usage data dialog title
  ///
  /// In en, this message translates to:
  /// **'Usage data'**
  String get usageDataDialog;

  /// Usage data type
  ///
  /// In en, this message translates to:
  /// **'• Anonymous usage statistics'**
  String get anonymousUsageStats;

  /// Usage data type
  ///
  /// In en, this message translates to:
  /// **'• Bug and crash reports'**
  String get bugCrashReports;

  /// Usage data type
  ///
  /// In en, this message translates to:
  /// **'• Usage preferences'**
  String get usagePreferences;

  /// Usage data type
  ///
  /// In en, this message translates to:
  /// **'• Performance data'**
  String get performanceData;

  /// Do not share button text
  ///
  /// In en, this message translates to:
  /// **'Do not share'**
  String get doNotShare;

  /// Data sharing enabled confirmation
  ///
  /// In en, this message translates to:
  /// **'Data sharing enabled'**
  String get dataSharingEnabled;

  /// Accept button text
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Security dialog title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityDialog;

  /// Change password setting
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// Change password description
  ///
  /// In en, this message translates to:
  /// **'Modify your password'**
  String get modifyYourPassword;

  /// Biometric authentication setting
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get biometricAuthentication;

  /// Biometric authentication description
  ///
  /// In en, this message translates to:
  /// **'Fingerprint / Face ID'**
  String get fingerprintFaceId;

  /// Biometric auth enabled confirmation
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled'**
  String get biometricAuthEnabled;

  /// Active sessions setting
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get activeSessions;

  /// Active sessions description
  ///
  /// In en, this message translates to:
  /// **'Manage your connected sessions'**
  String get manageConnectedSessions;

  /// Account deletion warning
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will result in:'**
  String get deleteAccountWarning;

  /// Account deletion consequence
  ///
  /// In en, this message translates to:
  /// **'• Loss of all your points and progress'**
  String get lossAllPointsProgress;

  /// Account deletion consequence
  ///
  /// In en, this message translates to:
  /// **'• Deletion of your history'**
  String get deletionHistory;

  /// Account deletion consequence
  ///
  /// In en, this message translates to:
  /// **'• Loss of your scan data'**
  String get lossScanData;

  /// Account deletion consequence
  ///
  /// In en, this message translates to:
  /// **'• Deletion of your ranking'**
  String get deletionRanking;

  /// Help & FAQ dialog title
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFAQDialog;

  /// FAQ item
  ///
  /// In en, this message translates to:
  /// **'• How to scan an object?'**
  String get howToScanObject;

  /// FAQ item
  ///
  /// In en, this message translates to:
  /// **'• How to earn points?'**
  String get howToEarnPoints;

  /// FAQ item
  ///
  /// In en, this message translates to:
  /// **'• How to participate in challenges?'**
  String get howToParticipateInChallenges;

  /// FAQ item
  ///
  /// In en, this message translates to:
  /// **'• How to see my ranking?'**
  String get howToSeeRanking;

  /// Additional help text
  ///
  /// In en, this message translates to:
  /// **'For more help, contact technical support.'**
  String get forMoreHelpContact;

  /// Contact us dialog title
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUsDialog;

  /// Email copied confirmation
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get emailCopied;

  /// Phone label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Phone copied confirmation
  ///
  /// In en, this message translates to:
  /// **'Number copied to clipboard'**
  String get numberCopied;

  /// Live chat option
  ///
  /// In en, this message translates to:
  /// **'Live chat'**
  String get liveChat;

  /// Live chat availability
  ///
  /// In en, this message translates to:
  /// **'Available 9am-6pm'**
  String get available9to6;

  /// Live chat not available message
  ///
  /// In en, this message translates to:
  /// **'Live chat coming soon'**
  String get liveChatComingSoon;

  /// Rate app dialog title
  ///
  /// In en, this message translates to:
  /// **'Rate EcoBuddy'**
  String get rateEcoBuddy;

  /// Rating thank you message
  ///
  /// In en, this message translates to:
  /// **'Thank you for your {rating} star rating!'**
  String thankYouRating(int rating);

  /// Send button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Logout dialog title
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutDialog;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogout;

  /// Logout error message
  ///
  /// In en, this message translates to:
  /// **'Logout error: {error}'**
  String logoutError(String error);

  /// Change password dialog title
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordDialog;

  /// Password change success message
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// Password mismatch error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Modify button text
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// Active sessions dialog title
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get activeSessionsDialog;

  /// Current Android device session
  ///
  /// In en, this message translates to:
  /// **'Android - Current device'**
  String get androidCurrentDevice;

  /// Current session last activity
  ///
  /// In en, this message translates to:
  /// **'Last activity: now'**
  String get lastActivityNow;

  /// Chrome Windows session
  ///
  /// In en, this message translates to:
  /// **'Chrome - Windows'**
  String get chromeWindows;

  /// Session last activity
  ///
  /// In en, this message translates to:
  /// **'Last activity: 2 days ago'**
  String get lastActivity2Days;

  /// Session revoked confirmation
  ///
  /// In en, this message translates to:
  /// **'Session revoked'**
  String get sessionRevoked;

  /// Revoke button text
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revoke;

  /// All sessions revoked confirmation
  ///
  /// In en, this message translates to:
  /// **'All other sessions have been revoked'**
  String get allOtherSessionsRevoked;

  /// Revoke all button text
  ///
  /// In en, this message translates to:
  /// **'Revoke all'**
  String get revokeAll;

  /// Account deletion success message
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccessfully;

  /// Account deletion confirmation instruction
  ///
  /// In en, this message translates to:
  /// **'Please type \"DELETE\" to confirm'**
  String get typeDeleteToConfirm;

  /// Delete permanently button text
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanentlyButton;

  /// Complete profile screen title
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeYourProfile;

  /// Profile completion greeting
  ///
  /// In en, this message translates to:
  /// **'Hi {username}! 👋'**
  String helloUser(String username);

  /// Profile completion instruction
  ///
  /// In en, this message translates to:
  /// **'Tell us where you are to discover challenges and recycling centers near you!'**
  String get tellUsWhereYouAre;

  /// Automatic location option
  ///
  /// In en, this message translates to:
  /// **'📍 Automatic location'**
  String get automaticLocation;

  /// GPS location description
  ///
  /// In en, this message translates to:
  /// **'Use your GPS position to automatically fill in your information.'**
  String get useGpsLocation;

  /// GPS locating status
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get locating;

  /// Use GPS button text
  ///
  /// In en, this message translates to:
  /// **'Use my position'**
  String get useMyPosition;

  /// Manual entry option
  ///
  /// In en, this message translates to:
  /// **'✏️ Or enter manually'**
  String get orEnterManually;

  /// City field label
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get city;

  /// City field validation
  ///
  /// In en, this message translates to:
  /// **'Please enter your city'**
  String get pleaseEnterCity;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country *'**
  String get country;

  /// Country field validation
  ///
  /// In en, this message translates to:
  /// **'Please enter your country'**
  String get pleaseEnterCountry;

  /// Region field label
  ///
  /// In en, this message translates to:
  /// **'Region (optional)'**
  String get regionOptional;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Privacy point
  ///
  /// In en, this message translates to:
  /// **'• Your data is encrypted and secure'**
  String get dataEncryptedSecure;

  /// Privacy point
  ///
  /// In en, this message translates to:
  /// **'• Never shared with third parties'**
  String get neverSharedThirdParties;

  /// Privacy point
  ///
  /// In en, this message translates to:
  /// **'• You can modify them at any time'**
  String get canModifyAnytime;

  /// Privacy point
  ///
  /// In en, this message translates to:
  /// **'• Used only to improve your experience'**
  String get usedOnlyImproveExperience;

  /// Skip profile completion button
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Complete profile button text
  ///
  /// In en, this message translates to:
  /// **'Complete my profile'**
  String get completeMyProfile;

  /// Location success message
  ///
  /// In en, this message translates to:
  /// **'📍 Location retrieved successfully'**
  String get locationRetrievedSuccessfully;

  /// Geolocation error message
  ///
  /// In en, this message translates to:
  /// **'❌ Geolocation error: {error}'**
  String geolocationError(String error);

  /// Profile completion success message
  ///
  /// In en, this message translates to:
  /// **'🎉 Profile completed successfully!'**
  String get profileCompletedSuccessfully;

  /// App description on splash screen
  ///
  /// In en, this message translates to:
  /// **'Your intelligent ecological assistant'**
  String get yourEcologicalAssistant;

  /// AR Scanner description on splash
  ///
  /// In en, this message translates to:
  /// **'Scan your objects and discover their environmental impact'**
  String get scanYourObjects;

  /// Stories feature name on splash
  ///
  /// In en, this message translates to:
  /// **'Interactive stories'**
  String get interactiveStories;

  /// Stories description on splash
  ///
  /// In en, this message translates to:
  /// **'Learn ecology through captivating adventures'**
  String get learnEcologyThroughAdventures;

  /// Challenges description on splash
  ///
  /// In en, this message translates to:
  /// **'Take on challenges and earn points'**
  String get earnPointsAndChallenges;

  /// Onboarding first page description
  ///
  /// In en, this message translates to:
  /// **'Instantly discover the ecological impact of any object using artificial intelligence!'**
  String get discoverInstantlyEcologicalImpact;

  /// AI feature tag
  ///
  /// In en, this message translates to:
  /// **'Gemini AI'**
  String get geminiAI;

  /// Real time feature tag
  ///
  /// In en, this message translates to:
  /// **'Real time'**
  String get realTime;

  /// Alternatives feature tag
  ///
  /// In en, this message translates to:
  /// **'Alternatives'**
  String get alternatives;

  /// Onboarding second page description
  ///
  /// In en, this message translates to:
  /// **'Live captivating ecological adventures where every choice matters to save the planet!'**
  String get liveEcologicalAdventures;

  /// Onboarding third page title
  ///
  /// In en, this message translates to:
  /// **'Daily Green\nChallenges'**
  String get dailyGreenChallenges;

  /// Onboarding third page description
  ///
  /// In en, this message translates to:
  /// **'Transform your daily life with fun ecological challenges and become an environmental hero!'**
  String get transformDailyLife;

  /// Gamification feature tag
  ///
  /// In en, this message translates to:
  /// **'Gamification'**
  String get gamification;

  /// Rewards feature tag
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// Onboarding fourth page title
  ///
  /// In en, this message translates to:
  /// **'Eco-Warriors\nCommunity'**
  String get ecoWarriorsCommuntiy;

  /// Onboarding fourth page description
  ///
  /// In en, this message translates to:
  /// **'Join thousands of eco-warriors and participate in the largest global ecological movement!'**
  String get joinThousandsEcoWarriors;

  /// Previous button text
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Camera permission message
  ///
  /// In en, this message translates to:
  /// **'Camera permission required to use AR scanner'**
  String get cameraPermissionRequired;

  /// Camera error message
  ///
  /// In en, this message translates to:
  /// **'Camera error: {error}'**
  String cameraError(String error);

  /// Scanner error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String scannerError(String error);

  /// Scan with camera button text
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get scanWithCamera;

  /// Scan other button text
  ///
  /// In en, this message translates to:
  /// **'Scan other'**
  String get scanOther;

  /// Story generation status
  ///
  /// In en, this message translates to:
  /// **'Generating story...'**
  String get generatingStory;

  /// Story generation description
  ///
  /// In en, this message translates to:
  /// **'Creating a unique ecological adventure for you'**
  String get creatingUniqueEcologicalAdventure;

  /// Permission checking status
  ///
  /// In en, this message translates to:
  /// **'Checking permissions...'**
  String get checkingPermissions;

  /// Permission requirement message
  ///
  /// In en, this message translates to:
  /// **'This feature requires access to your {permissionName}.'**
  String thisFeatureRequires(String permissionName);

  /// Open settings button text
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// Camera permission name
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// AR scanner camera permission explanation
  ///
  /// In en, this message translates to:
  /// **'AR scanner requires camera access to detect objects in real time.'**
  String get arScannerRequiresCamera;

  /// Password strength: very weak
  ///
  /// In en, this message translates to:
  /// **'Very weak'**
  String get veryWeak;

  /// Password strength: very strong
  ///
  /// In en, this message translates to:
  /// **'Very strong'**
  String get veryStrong;

  /// Environmental recommendation
  ///
  /// In en, this message translates to:
  /// **'Use a reusable bottle'**
  String get useReusableBottle;

  /// Environmental recommendation
  ///
  /// In en, this message translates to:
  /// **'Prefer glass packaging'**
  String get preferGlassPackaging;

  /// Environmental recommendation
  ///
  /// In en, this message translates to:
  /// **'Choose biodegradable alternatives'**
  String get chooseBiodegradableAlternatives;

  /// Environmental recommendation
  ///
  /// In en, this message translates to:
  /// **'Recycle in the right stream'**
  String get recycleInRightStream;

  /// Environmental recommendation
  ///
  /// In en, this message translates to:
  /// **'Reuse as container'**
  String get reuseAsContainer;

  /// Environmental recommendation
  ///
  /// In en, this message translates to:
  /// **'Use a reusable bag'**
  String get useReusableBag;

  /// Environmental recommendation
  ///
  /// In en, this message translates to:
  /// **'Avoid plastic bags'**
  String get avoidPlasticBags;

  /// Environmental recommendation
  ///
  /// In en, this message translates to:
  /// **'Reuse if possible'**
  String get reuseIfPossible;

  /// Username validation error
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers and _ are allowed'**
  String get onlyLettersNumbersUnderscore;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailRequired;

  /// Password confirmation validation error
  ///
  /// In en, this message translates to:
  /// **'Confirmation required'**
  String get confirmationRequired;

  /// No description provided for @pointsSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Ecological Points System'**
  String get pointsSystemTitle;

  /// No description provided for @pointsInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Points information'**
  String get pointsInfoTooltip;

  /// No description provided for @excellentChoice.
  ///
  /// In en, this message translates to:
  /// **'Excellent ecological choice'**
  String get excellentChoice;

  /// No description provided for @excellentChoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Sustainable, innovative, and impactful'**
  String get excellentChoiceDesc;

  /// No description provided for @goodChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Good choice'**
  String get goodChoiceTitle;

  /// No description provided for @goodChoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Environmentally responsible'**
  String get goodChoiceDesc;

  /// No description provided for @averageChoice.
  ///
  /// In en, this message translates to:
  /// **'Average choice'**
  String get averageChoice;

  /// No description provided for @averageChoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Some environmental benefits'**
  String get averageChoiceDesc;

  /// No description provided for @suboptimalChoice.
  ///
  /// In en, this message translates to:
  /// **'Suboptimal choice'**
  String get suboptimalChoice;

  /// No description provided for @suboptimalChoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Limited impact'**
  String get suboptimalChoiceDesc;

  /// No description provided for @problematicChoice.
  ///
  /// In en, this message translates to:
  /// **'Problematic choice'**
  String get problematicChoice;

  /// No description provided for @problematicChoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Little or no ecological value'**
  String get problematicChoiceDesc;

  /// No description provided for @aiEvaluationNote.
  ///
  /// In en, this message translates to:
  /// **'AI evaluates your choices based on their real environmental impact.'**
  String get aiEvaluationNote;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// Title for user's story history
  ///
  /// In en, this message translates to:
  /// **'Your Stories'**
  String get yourStories;

  /// Message when user has no stories
  ///
  /// In en, this message translates to:
  /// **'No stories yet'**
  String get noStoriesYet;

  /// Encouragement to start first story
  ///
  /// In en, this message translates to:
  /// **'Start your first ecological adventure!'**
  String get startFirstEcoAdventure;

  /// Label for completed stories count
  ///
  /// In en, this message translates to:
  /// **'Stories Completed'**
  String get storiesCompleted;

  /// Label for total points earned
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPointsEarned;

  /// Title for story details screen
  ///
  /// In en, this message translates to:
  /// **'Story Details'**
  String get storyDetails;

  /// Label for number of chapters
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// Title for story summary section
  ///
  /// In en, this message translates to:
  /// **'Story Summary'**
  String get storySummary;

  /// Title for detailed information section
  ///
  /// In en, this message translates to:
  /// **'Detailed Information'**
  String get detailedInformation;

  /// Label for session ID
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get sessionId;

  /// Label for ecological theme
  ///
  /// In en, this message translates to:
  /// **'Ecological Theme'**
  String get ecologicalTheme;

  /// Label for completion date
  ///
  /// In en, this message translates to:
  /// **'Completion Date'**
  String get completionDate;

  /// Label for status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Button text to start new similar story
  ///
  /// In en, this message translates to:
  /// **'New Similar Story'**
  String get newSimilarStory;

  /// Button text to go back to story history
  ///
  /// In en, this message translates to:
  /// **'Back to History'**
  String get backToHistory;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
