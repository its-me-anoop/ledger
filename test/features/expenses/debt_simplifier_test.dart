import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/expenses/domain/services/debt_simplifier.dart';

void main() {
  group('DebtSimplifier.simplify', () {
    test('empty balances → empty transfers', () {
      final result = DebtSimplifier.simplify({});
      expect(result, isEmpty);
    });

    test('all settled → empty transfers', () {
      final result = DebtSimplifier.simplify({'a': 0, 'b': 0, 'c': 0});
      expect(result, isEmpty);
    });

    test('one debtor, one creditor — single transfer', () {
      // b owes a 100¢.
      final result = DebtSimplifier.simplify({'a': 100, 'b': -100});
      expect(result.length, 1);
      expect(result.first.fromUid, 'b');
      expect(result.first.toUid, 'a');
      expect(result.first.amountCents, 100);
    });

    test('three-way: one creditor, two debtors', () {
      // a is owed 200, b owes 100, c owes 100.
      final transfers = DebtSimplifier.simplify({'a': 200, 'b': -100, 'c': -100});
      expect(transfers.length, 2);
      final total = transfers.fold(0, (s, t) => s + t.amountCents);
      expect(total, 200);
      for (final t in transfers) {
        expect(t.toUid, 'a');
        expect(t.amountCents, 100);
      }
    });

    test('two creditors, one debtor — two transfers', () {
      // a owed 60, b owed 40, c owes 100.
      final transfers = DebtSimplifier.simplify({'a': 60, 'b': 40, 'c': -100});
      expect(transfers.length, 2);
      final toA = transfers.where((t) => t.toUid == 'a').toList();
      final toB = transfers.where((t) => t.toUid == 'b').toList();
      expect(toA.length, 1);
      expect(toA.first.amountCents, 60);
      expect(toB.length, 1);
      expect(toB.first.amountCents, 40);
    });

    test('greedy minimises transfer count: 3 people circular → 2 transfers', () {
      // a owes 100, b owed 60, c owed 40.
      final balances = {'a': -100, 'b': 60, 'c': 40};
      final transfers = DebtSimplifier.simplify(balances);
      // Greedy: largest creditor (b=60) gets paid by largest debtor (a=100).
      // After: a=-40, b=0, c=40 → one more transfer.
      expect(transfers.length, 2);
      // Verify transfers resolve all balances to zero.
      final resolved = Map<String, int>.from(balances);
      for (final t in transfers) {
        resolved[t.fromUid] = (resolved[t.fromUid] ?? 0) + t.amountCents;
        resolved[t.toUid] = (resolved[t.toUid] ?? 0) - t.amountCents;
      }
      for (final v in resolved.values) {
        expect(v, 0);
      }
    });

    test('filters to pairs involving a specific uid', () {
      // a owes 100, b owed 60, c owed 40.
      final transfers = DebtSimplifier.simplify({'a': -100, 'b': 60, 'c': 40});
      final forB = transfers.where((t) => t.fromUid == 'b' || t.toUid == 'b').toList();
      // b is a creditor; should appear in exactly one transfer as toUid.
      expect(forB, isNotEmpty);
      for (final t in forB) {
        expect(t.toUid, 'b');
      }
    });
  });
}
