import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Profile'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) return const SizedBox.shrink();
          final user = state.user;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s4),
                Text(user.displayName, style: AppTypography.xl()),
                const SizedBox(height: AppSpacing.s1),
                Text(user.email, style: AppTypography.sm(color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.s8),
                const Divider(),
                const SizedBox(height: AppSpacing.s4),
                TextButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const SignOutRequested());
                  },
                  icon: const Icon(Icons.logout, color: AppColors.danger),
                  label: Text(
                    'Sign out',
                    style: AppTypography.base(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
