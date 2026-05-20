import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Settings'),
      ),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s6,
              vertical: AppSpacing.s4,
            ),
            children: [
              Text(
                'Appearance',
                style: AppTypography.sm(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.s3),
              _ThemeOption(
                label: 'System',
                selected: themeMode == ThemeMode.system,
                onTap: () =>
                    context.read<ThemeCubit>().setMode(ThemeMode.system),
              ),
              _ThemeOption(
                label: 'Light',
                selected: themeMode == ThemeMode.light,
                onTap: () =>
                    context.read<ThemeCubit>().setMode(ThemeMode.light),
              ),
              _ThemeOption(
                label: 'Dark',
                selected: themeMode == ThemeMode.dark,
                onTap: () =>
                    context.read<ThemeCubit>().setMode(ThemeMode.dark),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.s3),
            Text(label, style: AppTypography.base()),
          ],
        ),
      ),
    );
  }
}
