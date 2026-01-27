import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('vi'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'ErgoLife'**
  String get appTitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Moving'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to track your progress and compete.'**
  String get loginSubtitle;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get startYourJourney;

  /// No description provided for @buildBetterHabits.
  ///
  /// In en, this message translates to:
  /// **'Build better habits, achieve your goals'**
  String get buildBetterHabits;

  /// No description provided for @joinUsersWorldwide.
  ///
  /// In en, this message translates to:
  /// **'Join 10K+ users worldwide'**
  String get joinUsersWorldwide;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get continueWithApple;

  /// No description provided for @termsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms & Privacy Policy'**
  String get termsPrivacyPolicy;

  /// No description provided for @newToErgoLife.
  ///
  /// In en, this message translates to:
  /// **'New to ErgoLife? '**
  String get newToErgoLife;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout? You will need to sign in again to access your account.'**
  String get logoutConfirmation;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all associated data including activities, tasks, rewards, and house membership. This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning: This action is irreversible'**
  String get deleteAccountWarning;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @chooseYourAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose your avatar'**
  String get chooseYourAvatar;

  /// No description provided for @pickAvatarHint.
  ///
  /// In en, this message translates to:
  /// **'Pick one for the leaderboard (optional)'**
  String get pickAvatarHint;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'SELECTED'**
  String get selected;

  /// No description provided for @whatShouldWeCallYou.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get whatShouldWeCallYou;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name...'**
  String get enterYourName;

  /// No description provided for @pleaseEnterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your display name'**
  String get pleaseEnterDisplayName;

  /// No description provided for @stepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current}/{total}'**
  String stepCounter(int current, int total);

  /// No description provided for @chooseYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Journey'**
  String get chooseYourJourney;

  /// No description provided for @howDoYouWantErgoLife.
  ///
  /// In en, this message translates to:
  /// **'How do you want ErgoLife?'**
  String get howDoYouWantErgoLife;

  /// No description provided for @myPersonalSpace.
  ///
  /// In en, this message translates to:
  /// **'MY PERSONAL SPACE'**
  String get myPersonalSpace;

  /// No description provided for @focusOnYourself.
  ///
  /// In en, this message translates to:
  /// **'Focus on yourself'**
  String get focusOnYourself;

  /// No description provided for @trackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get trackYourProgress;

  /// No description provided for @buildHealthyHabits.
  ///
  /// In en, this message translates to:
  /// **'Build healthy habits'**
  String get buildHealthyHabits;

  /// No description provided for @continueSolo.
  ///
  /// In en, this message translates to:
  /// **'Continue Solo'**
  String get continueSolo;

  /// No description provided for @orCompeteWith.
  ///
  /// In en, this message translates to:
  /// **'or compete with'**
  String get orCompeteWith;

  /// No description provided for @familyArena.
  ///
  /// In en, this message translates to:
  /// **'Family Arena'**
  String get familyArena;

  /// No description provided for @createNewHouse.
  ///
  /// In en, this message translates to:
  /// **'Create New House'**
  String get createNewHouse;

  /// No description provided for @joinExistingHouse.
  ///
  /// In en, this message translates to:
  /// **'Join Existing House'**
  String get joinExistingHouse;

  /// No description provided for @alreadyHaveInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Already have an invite code?'**
  String get alreadyHaveInviteCode;

  /// No description provided for @enterHouseName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a house name'**
  String get enterHouseName;

  /// No description provided for @createArena.
  ///
  /// In en, this message translates to:
  /// **'Create Arena'**
  String get createArena;

  /// No description provided for @houseCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'House created successfully!'**
  String get houseCreatedSuccessfully;

  /// No description provided for @createYourExercise.
  ///
  /// In en, this message translates to:
  /// **'Create your\nexercise. 🏋️'**
  String get createYourExercise;

  /// No description provided for @turnDailyChoresToWorkout.
  ///
  /// In en, this message translates to:
  /// **'Turn your daily chores into a workout challenge.'**
  String get turnDailyChoresToWorkout;

  /// No description provided for @newCustomTask.
  ///
  /// In en, this message translates to:
  /// **'New Custom Task'**
  String get newCustomTask;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE NAME'**
  String get exerciseName;

  /// No description provided for @exerciseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vacuum Lunges'**
  String get exerciseNameHint;

  /// No description provided for @realLifeTask.
  ///
  /// In en, this message translates to:
  /// **'REAL LIFE TASK (Optional)'**
  String get realLifeTask;

  /// No description provided for @taskDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vacuuming living room'**
  String get taskDescriptionHint;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get duration;

  /// No description provided for @estReward.
  ///
  /// In en, this message translates to:
  /// **'EST. REWARD'**
  String get estReward;

  /// No description provided for @intensityLabel.
  ///
  /// In en, this message translates to:
  /// **'INTENSITY'**
  String get intensityLabel;

  /// No description provided for @intensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get intensityLight;

  /// No description provided for @intensityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get intensityModerate;

  /// No description provided for @intensityVigorous.
  ///
  /// In en, this message translates to:
  /// **'Vigorous'**
  String get intensityVigorous;

  /// No description provided for @intensityIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get intensityIntense;

  /// No description provided for @chooseIcon.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE ICON'**
  String get chooseIcon;

  /// No description provided for @createExercise.
  ///
  /// In en, this message translates to:
  /// **'Create Exercise'**
  String get createExercise;

  /// No description provided for @pleaseEnterExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Please enter exercise name'**
  String get pleaseEnterExerciseName;

  /// No description provided for @durationMustBe1To120.
  ///
  /// In en, this message translates to:
  /// **'Duration must be 1-120 minutes'**
  String get durationMustBe1To120;

  /// No description provided for @taskCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task created successfully!'**
  String get taskCreatedSuccessfully;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get durationMinutes;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE NAME'**
  String get exerciseNameLabel;

  /// No description provided for @realLifeTaskLabel.
  ///
  /// In en, this message translates to:
  /// **'REAL LIFE TASK (Optional)'**
  String get realLifeTaskLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get durationLabel;

  /// No description provided for @estRewardLabel.
  ///
  /// In en, this message translates to:
  /// **'EST. REWARD'**
  String get estRewardLabel;

  /// No description provided for @activeSession.
  ///
  /// In en, this message translates to:
  /// **'Active Session'**
  String get activeSession;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// No description provided for @pauseSession.
  ///
  /// In en, this message translates to:
  /// **'Pause Session'**
  String get pauseSession;

  /// No description provided for @resumeSession.
  ///
  /// In en, this message translates to:
  /// **'Resume Session'**
  String get resumeSession;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get endSession;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session Completed!'**
  String get sessionCompleted;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get pointsEarned;

  /// No description provided for @timeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time Spent'**
  String get timeSpent;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned'**
  String get caloriesBurned;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksYet;

  /// No description provided for @createYourFirstTask.
  ///
  /// In en, this message translates to:
  /// **'Create your first task to get started!'**
  String get createYourFirstTask;

  /// No description provided for @customTasks.
  ///
  /// In en, this message translates to:
  /// **'Custom Tasks'**
  String get customTasks;

  /// No description provided for @predefinedTasks.
  ///
  /// In en, this message translates to:
  /// **'Predefined Tasks'**
  String get predefinedTasks;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Shows how long the user has been a member
  ///
  /// In en, this message translates to:
  /// **'Member since {duration}'**
  String memberSince(String duration);

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @durationStat.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationStat;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your profile. Please try again.'**
  String get profileLoadError;

  /// No description provided for @refreshProfile.
  ///
  /// In en, this message translates to:
  /// **'Refresh Profile'**
  String get refreshProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get house;

  /// No description provided for @myHouse.
  ///
  /// In en, this message translates to:
  /// **'My House'**
  String get myHouse;

  /// No description provided for @joinHouse.
  ///
  /// In en, this message translates to:
  /// **'Join House'**
  String get joinHouse;

  /// No description provided for @leaveHouse.
  ///
  /// In en, this message translates to:
  /// **'Leave House'**
  String get leaveHouse;

  /// No description provided for @leaveHouseTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave House?'**
  String get leaveHouseTitle;

  /// No description provided for @leaveHouseContent.
  ///
  /// In en, this message translates to:
  /// **'You will lose all points and activity history in this house. Are you sure you want to leave?'**
  String get leaveHouseContent;

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get inviteMembers;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @enterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter an invite code'**
  String get enterInviteCode;

  /// No description provided for @askYourFriendForCode.
  ///
  /// In en, this message translates to:
  /// **'Ask your friend for the 6-digit code'**
  String get askYourFriendForCode;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get inviteCodeHint;

  /// Message shown when successfully joining a house
  ///
  /// In en, this message translates to:
  /// **'Joined {houseName}!'**
  String joinedHouse(String houseName);

  /// No description provided for @goodToKnow.
  ///
  /// In en, this message translates to:
  /// **'Good to know'**
  String get goodToKnow;

  /// No description provided for @houseRulesInfo.
  ///
  /// In en, this message translates to:
  /// **'• You can only be in one house at a time\n• Maximum 4 members per house\n• Compete with housemates on the leaderboard!'**
  String get houseRulesInfo;

  /// No description provided for @shareInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Code'**
  String get shareInviteCode;

  /// No description provided for @yourInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Your Invite Code'**
  String get yourInviteCode;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard!'**
  String get codeCopied;

  /// No description provided for @maxMembersReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum members reached'**
  String get maxMembersReached;

  /// No description provided for @houseNotFound.
  ///
  /// In en, this message translates to:
  /// **'House not found'**
  String get houseNotFound;

  /// No description provided for @invalidInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid invite code'**
  String get invalidInviteCode;

  /// No description provided for @houseDetails.
  ///
  /// In en, this message translates to:
  /// **'House Details'**
  String get houseDetails;

  /// No description provided for @houseName.
  ///
  /// In en, this message translates to:
  /// **'House Name'**
  String get houseName;

  /// No description provided for @houseMembers.
  ///
  /// In en, this message translates to:
  /// **'House Members'**
  String get houseMembers;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @rankings.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankings;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @yourRank.
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get yourRank;

  /// No description provided for @topPerformers.
  ///
  /// In en, this message translates to:
  /// **'Top Performers'**
  String get topPerformers;

  /// No description provided for @weeklyLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Weekly Leaderboard'**
  String get weeklyLeaderboard;

  /// No description provided for @monthlyLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Monthly Leaderboard'**
  String get monthlyLeaderboard;

  /// No description provided for @allTimeLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'All Time Leaderboard'**
  String get allTimeLeaderboard;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @firstPlace.
  ///
  /// In en, this message translates to:
  /// **'1st Place'**
  String get firstPlace;

  /// No description provided for @secondPlace.
  ///
  /// In en, this message translates to:
  /// **'2nd Place'**
  String get secondPlace;

  /// No description provided for @thirdPlace.
  ///
  /// In en, this message translates to:
  /// **'3rd Place'**
  String get thirdPlace;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @myRewards.
  ///
  /// In en, this message translates to:
  /// **'My Rewards'**
  String get myRewards;

  /// No description provided for @availableRewards.
  ///
  /// In en, this message translates to:
  /// **'Available Rewards'**
  String get availableRewards;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// No description provided for @redeemed.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get redeemed;

  /// No description provided for @pointsRequired.
  ///
  /// In en, this message translates to:
  /// **'Points Required'**
  String get pointsRequired;

  /// No description provided for @notEnoughPoints.
  ///
  /// In en, this message translates to:
  /// **'Not enough points'**
  String get notEnoughPoints;

  /// No description provided for @rewardRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Reward redeemed successfully!'**
  String get rewardRedeemed;

  /// No description provided for @viewRewards.
  ///
  /// In en, this message translates to:
  /// **'View Rewards'**
  String get viewRewards;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @todayActivity.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Activity'**
  String get todayActivity;

  /// No description provided for @weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoal;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Please check your input.'**
  String get validationError;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCode;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get pleaseTryAgainLater;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @checkYourConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again'**
  String get checkYourConnection;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please try again.'**
  String get timeoutError;

  /// No description provided for @unauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access.'**
  String get unauthorizedError;

  /// No description provided for @notFoundError.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get notFoundError;

  /// No description provided for @rewardsShop.
  ///
  /// In en, this message translates to:
  /// **'Rewards Shop'**
  String get rewardsShop;

  /// No description provided for @noRewardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rewards available'**
  String get noRewardsAvailable;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @houseDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'House Details'**
  String get houseDetailsTitle;

  /// No description provided for @notInHouse.
  ///
  /// In en, this message translates to:
  /// **'You are not in a house'**
  String get notInHouse;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// Message shown when code is copied
  ///
  /// In en, this message translates to:
  /// **'Code copied: {code}'**
  String codeCopiedWithCode(String code);

  /// No description provided for @houseCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'House created successfully!'**
  String get houseCreatedTitle;

  /// No description provided for @createYourHouseTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your House'**
  String get createYourHouseTitle;

  /// Message shown when a house is created
  ///
  /// In en, this message translates to:
  /// **'House \"{name}\" created!'**
  String houseCreatedWithName(String name);

  /// No description provided for @noLeaderboardData.
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data'**
  String get noLeaderboardData;

  /// No description provided for @inviteMyHouse.
  ///
  /// In en, this message translates to:
  /// **'Invite My House'**
  String get inviteMyHouse;

  /// No description provided for @joinHouseAction.
  ///
  /// In en, this message translates to:
  /// **'Join House'**
  String get joinHouseAction;

  /// No description provided for @manageTasks.
  ///
  /// In en, this message translates to:
  /// **'Manage Tasks'**
  String get manageTasks;

  /// No description provided for @deleteComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Delete functionality coming soon!'**
  String get deleteComingSoon;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get changesSaved;

  /// No description provided for @savingChanges.
  ///
  /// In en, this message translates to:
  /// **'Saving changes...'**
  String get savingChanges;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied!'**
  String get inviteCodeCopied;

  /// Welcome message for joining a house
  ///
  /// In en, this message translates to:
  /// **'Welcome to {name}! 🎉'**
  String welcomeToHouse(String name);

  /// No description provided for @globalLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get globalLeaderboard;

  /// No description provided for @houseLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get houseLeaderboard;

  /// No description provided for @joinAHouse.
  ///
  /// In en, this message translates to:
  /// **'Join a House'**
  String get joinAHouse;

  /// No description provided for @competeTogether.
  ///
  /// In en, this message translates to:
  /// **'Compete together!'**
  String get competeTogether;

  /// No description provided for @failedToLoadTasks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tasks'**
  String get failedToLoadTasks;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Task?'**
  String get deleteTaskTitle;

  /// Confirmation message for deleting a task
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{taskName}\"? This action cannot be undone.'**
  String deleteTaskConfirmation(String taskName);

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder, toggle to show/hide'**
  String get dragToReorder;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get unsavedChangesMessage;

  /// No description provided for @dailyMissions.
  ///
  /// In en, this message translates to:
  /// **'Daily Missions'**
  String get dailyMissions;

  /// No description provided for @activeTasks.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeTasks;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTasks;

  /// No description provided for @failedToLoadHomeData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load home data'**
  String get failedToLoadHomeData;

  /// No description provided for @failedToLoadInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to load invite code'**
  String get failedToLoadInviteCode;

  /// No description provided for @failedToUpdateName.
  ///
  /// In en, this message translates to:
  /// **'Failed to update name'**
  String get failedToUpdateName;

  /// No description provided for @joinMyHouseMessage.
  ///
  /// In en, this message translates to:
  /// **'Join my ErgoLife house! Use code: {code}\n\n{link}'**
  String joinMyHouseMessage(String code, String link);

  /// No description provided for @joinMyHouseSubject.
  ///
  /// In en, this message translates to:
  /// **'Join my ErgoLife house!'**
  String get joinMyHouseSubject;

  /// No description provided for @nameYourArena.
  ///
  /// In en, this message translates to:
  /// **'Name Your Arena'**
  String get nameYourArena;

  /// No description provided for @nameArenaDescription.
  ///
  /// In en, this message translates to:
  /// **'Give your house a cool name before inviting friends!'**
  String get nameArenaDescription;

  /// No description provided for @nameArenaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., \"The Warriors\" 💪'**
  String get nameArenaHint;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @inviteFriendsDescription.
  ///
  /// In en, this message translates to:
  /// **'Share this code with friends to join \"{name}\"'**
  String inviteFriendsDescription(String name);

  /// No description provided for @tapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get tapToCopy;

  /// No description provided for @shareInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get shareInviteLink;

  /// No description provided for @failedToLoadHouseInfo.
  ///
  /// In en, this message translates to:
  /// **'Failed to load house info'**
  String get failedToLoadHouseInfo;

  /// No description provided for @failedToJoinHouse.
  ///
  /// In en, this message translates to:
  /// **'Failed to join house'**
  String get failedToJoinHouse;

  /// No description provided for @leavePersonalSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Personal Space?'**
  String get leavePersonalSpaceTitle;

  /// No description provided for @leavePersonalSpaceMessage.
  ///
  /// In en, this message translates to:
  /// **'You will leave your current Personal Space to join \"{houseName}\". This action cannot be undone.'**
  String leavePersonalSpaceMessage(String houseName);

  /// No description provided for @enterInviteCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite code shared by your friend'**
  String get enterInviteCodeDescription;

  /// No description provided for @previewHouse.
  ///
  /// In en, this message translates to:
  /// **'Preview House'**
  String get previewHouse;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by {ownerName}'**
  String createdBy(String ownerName);

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String memberCount(int count);

  /// Greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Hello, {userName}!'**
  String helloUser(String userName);

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'YOUR PROGRESS'**
  String get yourProgress;

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Day'**
  String dayCount(int count);

  /// No description provided for @pointsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pts'**
  String pointsCount(String count);

  /// No description provided for @hoursCount.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String hoursCount(int count);

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String minutesCount(int count);

  /// No description provided for @quickTasks.
  ///
  /// In en, this message translates to:
  /// **'Quick Tasks'**
  String get quickTasks;

  /// No description provided for @activeTasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String activeTasksCount(int count);

  /// No description provided for @enterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a display name'**
  String get enterDisplayName;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose your avatar'**
  String get chooseAvatar;

  /// No description provided for @pickForLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Pick one for the leaderboard (optional)'**
  String get pickForLeaderboard;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to experience ErgoLife?'**
  String get onboardingSubtitle;

  /// No description provided for @personalSpace.
  ///
  /// In en, this message translates to:
  /// **'Personal Space'**
  String get personalSpace;

  /// No description provided for @soloJourney.
  ///
  /// In en, this message translates to:
  /// **'Solo journey'**
  String get soloJourney;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get trackProgress;

  /// No description provided for @challengeLovedOnes.
  ///
  /// In en, this message translates to:
  /// **'Challenge loved ones'**
  String get challengeLovedOnes;

  /// No description provided for @friendlyCompetition.
  ///
  /// In en, this message translates to:
  /// **'Friendly competition'**
  String get friendlyCompetition;

  /// No description provided for @climbLeaderboards.
  ///
  /// In en, this message translates to:
  /// **'Climb leaderboards'**
  String get climbLeaderboards;

  /// No description provided for @haveInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Have an invite code?'**
  String get haveInviteCode;

  /// No description provided for @createYourArena.
  ///
  /// In en, this message translates to:
  /// **'Create Your Arena'**
  String get createYourArena;

  /// No description provided for @giveArenaName.
  ///
  /// In en, this message translates to:
  /// **'Give your family competition a name!'**
  String get giveArenaName;

  /// No description provided for @arenaNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"The Warriors\" 💪'**
  String get arenaNameHint;

  /// No description provided for @enterJoinCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code shared by your house admin.'**
  String get enterJoinCodeMessage;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCodeLabel;

  /// No description provided for @joinBtn.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinBtn;

  /// No description provided for @personalHouse.
  ///
  /// In en, this message translates to:
  /// **'Personal House'**
  String get personalHouse;

  /// No description provided for @teamHouse.
  ///
  /// In en, this message translates to:
  /// **'Team House'**
  String get teamHouse;

  /// No description provided for @todayPts.
  ///
  /// In en, this message translates to:
  /// **'Today Pts'**
  String get todayPts;

  /// No description provided for @inviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite Member'**
  String get inviteMember;

  /// No description provided for @competeAndMotivate.
  ///
  /// In en, this message translates to:
  /// **'Compete with friends & stay motivated'**
  String get competeAndMotivate;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @enterDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get enterDisplayNameHint;

  /// No description provided for @displayNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Display name cannot be empty'**
  String get displayNameEmptyError;

  /// No description provided for @displayNameMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Display name must be at least 2 characters'**
  String get displayNameMinLengthError;

  /// No description provided for @displayNameMaxLengthError.
  ///
  /// In en, this message translates to:
  /// **'Display name must be at most 30 characters'**
  String get displayNameMaxLengthError;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotBeChanged;

  /// No description provided for @validationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validationErrorTitle;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
