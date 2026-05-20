import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/expense.dart';
import '../../../settlements/domain/models/settlement.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';

/// Reads the [ExpenseBloc] already in context (provided by GroupDetailPage).
class ActivityFeedView extends StatelessWidget {
  const ActivityFeedView({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) => _ActivityFeed(groupId: groupId);
}

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) => switch (state) {
        ExpensesLoading() => const Center(child: CircularProgressIndicator()),
        ExpensesError(:final message) => Center(
          child: Text(message, style: AppTypography.base(color: AppColors.danger)),
        ),
        ExpensesLoaded(:final expenses, :final settlements)
            when expenses.isEmpty && settlements.isEmpty =>
          _EmptyActivity(),
        ExpensesLoaded(:final expenses, :final settlements) =>
          _ActivityRows(expenses: expenses, settlements: settlements),
      },
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s6,
        vertical: AppSpacing.s10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Quiet so far.', style: AppTypography.xl()),
          const SizedBox(height: AppSpacing.s3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 68 * 8.0),
            child: Text(
              'Expenses and settlements appear here as they happen.',
              style: AppTypography.base(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// Unified activity item merges expenses + settlements sorted by date.
sealed class _ActivityItem {
  DateTime get date;
}

class _ExpenseItem extends _ActivityItem {
  _ExpenseItem(this.expense);
  final Expense expense;
  @override
  DateTime get date => expense.createdAt;
}

class _SettlementItem extends _ActivityItem {
  _SettlementItem(this.settlement);
  final Settlement settlement;
  @override
  DateTime get date => settlement.createdAt;
}

class _ActivityRows extends StatelessWidget {
  const _ActivityRows({required this.expenses, required this.settlements});

  final List<Expense> expenses;
  final List<Settlement> settlements;

  static final _dateFmt = DateFormat('d MMM');

  @override
  Widget build(BuildContext context) {
    final items = <_ActivityItem>[
      for (final e in expenses) _ExpenseItem(e),
      for (final s in settlements) _SettlementItem(s),
    ]..sort((a, b) => b.date.compareTo(a.date));

    // Group by day
    final grouped = <String, List<_ActivityItem>>{};
    for (final item in items) {
      final key = _dateFmt.format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final entry in grouped.entries) ...[
          _DayHeader(label: entry.key),
          for (final item in entry.value) ...[
            _ActivityTile(item: item),
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.s6),
              child: Divider(height: 1, thickness: 1, color: AppColors.border),
            ),
          ],
        ],
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s5,
        AppSpacing.s6,
        AppSpacing.s2,
      ),
      child: Text(
        label,
        style: AppTypography.xs(color: AppColors.textMuted),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});

  final _ActivityItem item;

  static final _currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final (icon, label, amount) = switch (item) {
      _ExpenseItem(:final expense) => (
        Icons.receipt_long_outlined,
        '${expense.paidByUid} paid ${expense.description}',
        _currencyFmt.format(expense.amount / 100),
      ),
      _SettlementItem(:final settlement) => (
        Icons.handshake_outlined,
        '${settlement.fromUid} settled with ${settlement.toUid}',
        _currencyFmt.format(settlement.amount / 100),
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s6,
        vertical: AppSpacing.s4,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(label, style: AppTypography.base()),
          ),
          Text(amount, style: AppTypography.base(weight: FontWeight.w500)),
        ],
      ),
    );
  }
}
