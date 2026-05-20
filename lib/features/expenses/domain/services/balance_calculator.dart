import '../models/expense.dart';
import '../../../settlements/domain/models/settlement.dart';

/// Pure Dart. No Flutter imports.
///
/// Sign convention (from the perspective of each uid):
///   positive → others owe this person money (they are owed)
///   negative → this person owes others money (they owe)
///
/// Algorithm:
///   For each expense, payer receives credit equal to the full amount.
///   Each member in splitAmong (including payer) is debited their share.
///   Share = amount ~/ splitAmongUids.length; remainder (amount % n) goes to
///   payer as an additional credit so total always sums to zero.
///   For each settlement, fromUid pays toUid: fromUid += amount, toUid -= amount.
abstract final class BalanceCalculator {
  /// Returns uid → net cents for every uid in [memberUids].
  /// Members not in [memberUids] that appear in expenses are included too.
  static Map<String, int> calculate({
    required List<Expense> expenses,
    required List<Settlement> settlements,
    required List<String> memberUids,
  }) {
    final balances = <String, int>{
      for (final uid in memberUids) uid: 0,
    };

    for (final expense in expenses) {
      final n = expense.splitAmongUids.length;
      if (n == 0) continue;

      final share = expense.amount ~/ n;
      final remainder = expense.amount % n;

      // Payer receives the full amount credited.
      balances[expense.paidByUid] =
          (balances[expense.paidByUid] ?? 0) + expense.amount;

      // Each split member is debited their share.
      for (final uid in expense.splitAmongUids) {
        balances[uid] = (balances[uid] ?? 0) - share;
      }

      // Remainder goes back to payer (net: payer gains remainder).
      // Since payer was credited full amount and debited their share,
      // the remainder is already accounted for. However, the split-among list
      // may or may not include the payer. Adjust so total is zero:
      // total debited = share * n + remainder but we only debited share * n,
      // so debit remainder from payer additionally.
      balances[expense.paidByUid] =
          (balances[expense.paidByUid] ?? 0) - remainder;
    }

    for (final settlement in settlements) {
      // fromUid paid toUid: fromUid's debt reduces (positive shift),
      // toUid's receivable reduces (negative shift).
      balances[settlement.fromUid] =
          (balances[settlement.fromUid] ?? 0) + settlement.amount;
      balances[settlement.toUid] =
          (balances[settlement.toUid] ?? 0) - settlement.amount;
    }

    return balances;
  }
}
