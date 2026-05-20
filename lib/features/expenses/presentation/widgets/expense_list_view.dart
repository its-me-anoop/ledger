import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseBloc>(
      // Per-tab instance; using factory so each group gets its own bloc.
      create: (_) => getIt<ExpenseBloc>()..add(LoadExpenses(groupId)),
      child: _ExpenseList(groupId: groupId),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) => switch (state) {
        ExpensesLoading() => const Center(child: CircularProgressIndicator()),
        ExpensesError(:final message) => Center(
          child: Text(message, style: AppTypography.base(color: AppColors.danger)),
        ),
        ExpensesLoaded(:final expenses) when expenses.isEmpty => _EmptyExpenses(),
        ExpensesLoaded(:final expenses) => _ExpenseRows(expenses: expenses),
      },
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
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
          Text('No expenses yet.', style: AppTypography.xl()),
          const SizedBox(height: AppSpacing.s3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 68 * 8.0),
            child: Text(
              "Tap + to add the first one. Ledger splits it evenly and updates everyone's balance.",
              style: AppTypography.base(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRows extends StatelessWidget {
  const _ExpenseRows({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: expenses.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(left: AppSpacing.s6),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
      itemBuilder: (context, index) => _ExpenseTile(expense: expenses[index]),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense});

  final Expense expense;

  static final _dayFmt = NumberFormat('00');
  static final _currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final month = _monthAbbr(expense.createdAt.month);
    final day = _dayFmt.format(expense.createdAt.day);
    final amount = _currencyFmt.format(expense.amount / 100);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s6,
        vertical: AppSpacing.s4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Text(day, style: AppTypography.lg()),
                Text(month, style: AppTypography.xs(color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: AppTypography.base(weight: FontWeight.w500),
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  'Paid by ${expense.paidByUid}',
                  style: AppTypography.sm(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Text(amount, style: AppTypography.lg()),
        ],
      ),
    );
  }

  static String _monthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}
