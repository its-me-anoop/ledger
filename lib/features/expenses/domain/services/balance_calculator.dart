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

      // Remainder: we distributed share*n cents but the expense is
      // share*n + remainder. The undistributed remainder is absorbed by the
      // payer so the ledger always sums to zero.
      //
      // Case A — payer IS in splitAmong: payer was already debited `share` in
      // the loop above. We additionally debit `remainder` so their net debit
      // equals (share + remainder) while every other member is debited exactly
      // `share`. Total debits = share*(n-1) + (share+remainder) = share*n +
      // remainder = amount = total credits. Sum = 0. ✓
      //
      // Case B — payer is NOT in splitAmong: payer was credited `amount` and
      // debited nothing. Total debits = share*n = amount - remainder. We debit
      // `remainder` from payer to balance: payer net = amount - remainder,
      // split members net = -share each. Sum = (amount - remainder) - share*n =
      // (amount - remainder) - (amount - remainder) = 0. ✓
      //
      // In both cases the remainder is always deducted from the payer. The only
      // difference is whether the payer also carried a `share` debit.
      if (remainder != 0) {
        balances[expense.paidByUid] =
            (balances[expense.paidByUid] ?? 0) - remainder;
      }
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
