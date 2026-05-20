import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/auth_failure.dart';

class AuthFailureMessage extends StatelessWidget {
  const AuthFailureMessage({super.key, required this.failure});

  final AuthFailure failure;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.dangerDim,
        borderRadius: BorderRadius.circular(AppSpacing.s2),
      ),
      child: Text(
        _message(failure),
        style: AppTypography.sm(color: AppColors.danger),
      ),
    );
  }

  String _message(AuthFailure failure) => switch (failure) {
    InvalidEmail() => 'That email address isn\'t valid.',
    WrongPassword() => 'Incorrect password. Try again.',
    UserNotFound() => 'No account found with that email.',
    EmailAlreadyInUse() => 'An account already exists with that email.',
    WeakPassword() => 'Choose a stronger password (at least 6 characters).',
    NetworkFailure() => 'Check your connection and try again.',
    UnknownAuthFailure(:final message) =>
      message ?? 'Something went wrong. Try again.',
  };
}
