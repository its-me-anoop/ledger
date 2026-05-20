import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/expenses/domain/models/expense.dart';
import 'package:ledger/features/expenses/domain/services/balance_calculator.dart';
import 'package:ledger/features/settlements/domain/models/settlement.dart';

Expense _expense({
  required String id,
  required String groupId,
  required int amount,
  required String paidBy,
  required List<String> splitAmong,
}) =>
    Expense(
      id: id,
      groupId: groupId,
      amount: amount,
      description: 'test',
      paidByUid: paidBy,
      splitAmongUids: splitAmong,
      createdAt: DateTime(2026),
    );

Settlement _settlement({
  required String id,
  required String groupId,
  required String from,
  required String to,
  required int amount,
}) =>
    Settlement(
      id: id,
      groupId: groupId,
      fromUid: from,
      toUid: to,
      amount: amount,
      createdAt: DateTime(2026),
    );

void main() {
  group('BalanceCalculator', () {
    test('empty inputs → all zeros', () {
      final result = BalanceCalculator.calculate(
        expenses: [],
        settlements: [],
        memberUids: ['a', 'b', 'c'],
      );
      expect(result, {'a': 0, 'b': 0, 'c': 0});
    });

    test('one expense, equal split among 3 — payer owed 2/3, others owe 1/3', () {
      // $1.00 = 100 cents split 3 ways.
      // share = 33, remainder = 1.
      // Payer ('a'): credited 100, debited 33, debited remainder 1 → net +66.
      // 'b': debited 33 → net -33.
      // 'c': debited 33 → net -33.
      // Sum = 66 - 33 - 33 = 0. ✓
      final expense = _expense(
        id: 'e1',
        groupId: 'g1',
        amount: 100,
        paidBy: 'a',
        splitAmong: ['a', 'b', 'c'],
      );
      final result = BalanceCalculator.calculate(
        expenses: [expense],
        settlements: [],
        memberUids: ['a', 'b', 'c'],
      );
      expect(result['a'], 66);  // payer is owed 66¢
      expect(result['b'], -33); // owes 33¢
      expect(result['c'], -33); // owes 33¢
      expect(result.values.fold(0, (s, v) => s + v), 0); // sum = 0
    });

    test('two expenses cancel out → all zeros', () {
      // 'a' pays 100 split among a,b. 'b' pays 100 split among a,b.
      // a: +100 -50 = +50 from first; -50 +100 = +50 from second → 0? No:
      // expense1: a pays 100, split [a,b]. share=50, rem=0. a: +100-50=+50. b: -50.
      // expense2: b pays 100, split [a,b]. share=50, rem=0. b: +100-50=+50. a: -50.
      // Net: a = +50-50 = 0. b = -50+50 = 0. ✓
      final e1 = _expense(
        id: 'e1',
        groupId: 'g1',
        amount: 100,
        paidBy: 'a',
        splitAmong: ['a', 'b'],
      );
      final e2 = _expense(
        id: 'e2',
        groupId: 'g1',
        amount: 100,
        paidBy: 'b',
        splitAmong: ['a', 'b'],
      );
      final result = BalanceCalculator.calculate(
        expenses: [e1, e2],
        settlements: [],
        memberUids: ['a', 'b'],
      );
      expect(result['a'], 0);
      expect(result['b'], 0);
    });

    test('settlement reduces debt to zero', () {
      // a pays 200 split [a,b]. a: +100. b: -100.
      // b settles 100 to a. b: +100. a: -100.
      // Net: a=0, b=0. ✓
      final expense = _expense(
        id: 'e1',
        groupId: 'g1',
        amount: 200,
        paidBy: 'a',
        splitAmong: ['a', 'b'],
      );
      final settlement = _settlement(
        id: 's1',
        groupId: 'g1',
        from: 'b',
        to: 'a',
        amount: 100,
      );
      final result = BalanceCalculator.calculate(
        expenses: [expense],
        settlements: [settlement],
        memberUids: ['a', 'b'],
      );
      expect(result['a'], 0);
      expect(result['b'], 0);
    });

    test('settlement overpayment flips sign', () {
      // a pays 200 split [a,b]. a: +100. b: -100.
      // b settles 150 to a (overpays by 50). b: +150. a: -150.
      // Net: a = +100-150 = -50. b = -100+150 = +50.
      final expense = _expense(
        id: 'e1',
        groupId: 'g1',
        amount: 200,
        paidBy: 'a',
        splitAmong: ['a', 'b'],
      );
      final settlement = _settlement(
        id: 's1',
        groupId: 'g1',
        from: 'b',
        to: 'a',
        amount: 150,
      );
      final result = BalanceCalculator.calculate(
        expenses: [expense],
        settlements: [settlement],
        memberUids: ['a', 'b'],
      );
      expect(result['a'], -50); // now owes 50
      expect(result['b'], 50);  // now owed 50
    });

    test('rounding: \$1.00 split 3 ways — sum is always zero', () {
      // 100 cents / 3 = 33 each, remainder 1 goes back to payer.
      // payer 'a': credited 100, debited 33 (share), debited 1 (remainder) → +66.
      // 'b': -33. 'c': -33. Sum = 66-33-33 = 0. ✓
      final expense = _expense(
        id: 'e1',
        groupId: 'g1',
        amount: 100,
        paidBy: 'a',
        splitAmong: ['a', 'b', 'c'],
      );
      final result = BalanceCalculator.calculate(
        expenses: [expense],
        settlements: [],
        memberUids: ['a', 'b', 'c'],
      );
      expect(result['a'], 66);
      expect(result['b'], -33);
      expect(result['c'], -33);
      final sum = result.values.fold(0, (s, v) => s + v);
      expect(sum, 0);
    });

    test('payer NOT in splitAmong with non-divisible amount — sum is zero', () {
      // alex pays 1000¢ ($10), splitAmong=['bob','carol','dave'] (n=3).
      // share=333, remainder=1.
      // alex: credited 1000, then debited remainder(1) → net +999.
      // bob: -333, carol: -333, dave: -333.
      // Sum = 999 - 333 - 333 - 333 = 0. ✓
      // Alex absorbs the rounding cent even though not in splitAmong;
      // this is the only way the ledger sums to zero.
      final expense = _expense(
        id: 'e1',
        groupId: 'g1',
        amount: 1000,
        paidBy: 'alex',
        splitAmong: ['bob', 'carol', 'dave'],
      );
      final result = BalanceCalculator.calculate(
        expenses: [expense],
        settlements: [],
        memberUids: ['alex', 'bob', 'carol', 'dave'],
      );
      expect(result['alex'], 999);
      expect(result['bob'], -333);
      expect(result['carol'], -333);
      expect(result['dave'], -333);
      expect(result.values.fold(0, (s, v) => s + v), 0);
    });

    test('members not in expense splitAmong are unaffected', () {
      // 'd' is a group member but not in the split.
      final expense = _expense(
        id: 'e1',
        groupId: 'g1',
        amount: 200,
        paidBy: 'a',
        splitAmong: ['a', 'b'],
      );
      final result = BalanceCalculator.calculate(
        expenses: [expense],
        settlements: [],
        memberUids: ['a', 'b', 'd'],
      );
      expect(result['d'], 0);
    });
  });
}
