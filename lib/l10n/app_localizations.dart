import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get appName;

  /// Empty state title for groups list
  ///
  /// In en, this message translates to:
  /// **'No groups yet.'**
  String get groupsEmptyTitle;

  /// Empty state body for groups list
  ///
  /// In en, this message translates to:
  /// **'Create one and share the code with your group — everyone joins in seconds.'**
  String get groupsEmptyBody;

  /// CTA on groups empty state
  ///
  /// In en, this message translates to:
  /// **'Create your first group'**
  String get groupsEmptyCta;

  /// Empty state title for expenses tab
  ///
  /// In en, this message translates to:
  /// **'No expenses yet.'**
  String get expensesEmptyTitle;

  /// Empty state body for expenses tab
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first one. Ledger splits it evenly and updates everyone\'s balance.'**
  String get expensesEmptyBody;

  /// Empty state title for activity tab
  ///
  /// In en, this message translates to:
  /// **'Quiet so far.'**
  String get activityEmptyTitle;

  /// Empty state body for activity tab
  ///
  /// In en, this message translates to:
  /// **'Expenses and settlements appear here as they happen.'**
  String get activityEmptyBody;

  /// Empty state title for members tab with one member
  ///
  /// In en, this message translates to:
  /// **'Just you for now.'**
  String get membersEmptyTitle;

  /// Empty state body for members tab
  ///
  /// In en, this message translates to:
  /// **'Share the group code to invite people. You can find it in group settings.'**
  String get membersEmptyBody;

  /// CTA to share invite code
  ///
  /// In en, this message translates to:
  /// **'Share invite code'**
  String get membersEmptyShareCta;

  /// Title for settle up page
  ///
  /// In en, this message translates to:
  /// **'Settle up'**
  String get settleUpTitle;

  /// Who owes whom on settle up page
  ///
  /// In en, this message translates to:
  /// **'owes {name}'**
  String settleUpOwes(String name);

  /// Disclaimer text on settle up page
  ///
  /// In en, this message translates to:
  /// **'This will mark all shared expenses between you as settled. Record any outside payment separately.'**
  String get settleUpDisclaimer;

  /// Primary button on settle up page
  ///
  /// In en, this message translates to:
  /// **'Mark as settled'**
  String get markAsSettled;

  /// FAB and page title for adding expense
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// Label above balance amount on group detail
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get yourBalance;

  /// Balance chip label when fully settled
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// Sign out button label
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Profile page title and nav label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings page title and nav label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Groups nav label
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Tab label for expenses
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get tabExpenses;

  /// Tab label for activity feed
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tabActivity;

  /// Tab label for members list
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get tabMembers;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
