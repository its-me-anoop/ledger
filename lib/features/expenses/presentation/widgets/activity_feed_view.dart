import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Stub replaced in M9 with real activity rows.
class ActivityFeedView extends StatelessWidget {
  const ActivityFeedView({super.key, required this.groupId});

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
