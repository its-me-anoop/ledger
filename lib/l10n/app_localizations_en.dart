// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ledger';

  @override
  String get groupsEmptyTitle => 'No groups yet.';

  @override
  String get groupsEmptyBody =>
      'Create one and share the code with your group — everyone joins in seconds.';

  @override
  String get groupsEmptyCta => 'Create your first group';

  @override
  String get expensesEmptyTitle => 'No expenses yet.';

  @override
  String get expensesEmptyBody =>
      'Tap + to add the first one. Ledger splits it evenly and updates everyone\'s balance.';

  @override
  String get activityEmptyTitle => 'Quiet so far.';

  @override
  String get activityEmptyBody =>
      'Expenses and settlements appear here as they happen.';

  @override
  String get membersEmptyTitle => 'Just you for now.';

  @override
  String get membersEmptyBody =>
      'Share the group code to invite people. You can find it in group settings.';

  @override
  String get membersEmptyShareCta => 'Share invite code';

  @override
  String get settleUpTitle => 'Settle up';

  @override
  String settleUpOwes(String name) {
    return 'owes $name';
  }

  @override
  String get settleUpDisclaimer =>
      'This will mark all shared expenses between you as settled. Record any outside payment separately.';

  @override
  String get markAsSettled => 'Mark as settled';

  @override
  String get addExpense => 'Add expense';

  @override
  String get yourBalance => 'Your balance';

  @override
  String get settled => 'Settled';

  @override
  String get signOut => 'Sign out';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get groups => 'Groups';

  @override
  String get tabExpenses => 'Expenses';

  @override
  String get tabActivity => 'Activity';

  @override
  String get tabMembers => 'Members';
}
