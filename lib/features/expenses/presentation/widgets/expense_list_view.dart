import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Stub replaced in M7 with real expense rows.
/// Accepts groupId so the real impl can wire its Bloc.
class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key, required this.groupId});

  final String groupId;

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
              'Tap + to add the first one. Ledger splits it evenly and updates everyone\'s balance.',
              style: AppTypography.base(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
