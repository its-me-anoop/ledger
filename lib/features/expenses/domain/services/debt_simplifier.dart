/// Pure Dart. No Flutter imports.
///
/// Converts a uid→netCents map into a minimal set of pairwise transfers using
/// a greedy algorithm: largest debtor pays largest creditor until all balances
/// reach zero (within a 1-cent rounding tolerance).
///
/// Sign convention (matches BalanceCalculator):
///   positive → uid is owed money (creditor)
///   negative → uid owes money (debtor)
abstract final class DebtSimplifier {
  /// Returns the minimal transfer list for [netBalances].
  static List<Transfer> simplify(Map<String, int> netBalances) {
    // Separate into two sorted lists (descending absolute value).
    final creditors = <_Entry>[];
    final debtors = <_Entry>[];

    for (final entry in netBalances.entries) {
      if (entry.value > 0) {
        creditors.add(_Entry(entry.key, entry.value));
      } else if (entry.value < 0) {
        debtors.add(_Entry(entry.key, -entry.value)); // store as positive
      }
    }

    creditors.sort((a, b) => b.amount.compareTo(a.amount));
    debtors.sort((a, b) => b.amount.compareTo(a.amount));

    final transfers = <Transfer>[];
    int ci = 0;
    int di = 0;

    while (ci < creditors.length && di < debtors.length) {
      final credit = creditors[ci];
      final debt = debtors[di];

      final paid = credit.amount < debt.amount ? credit.amount : debt.amount;
      transfers.add(Transfer(
        fromUid: debt.uid,
        toUid: credit.uid,
        amountCents: paid,
      ));

      credit.amount -= paid;
      debt.amount -= paid;

      if (credit.amount == 0) ci++;
      if (debt.amount == 0) di++;
    }

    return transfers;
  }
}

final class Transfer {
  const Transfer({
    required this.fromUid,
    required this.toUid,
    required this.amountCents,
  });

  final String fromUid;
  final String toUid;
  final int amountCents;
}

final class _Entry {
  _Entry(this.uid, this.amount);
  final String uid;
  int amount;
}
