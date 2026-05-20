import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/group_repository.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    context.read<GroupBloc>().add(
      JoinGroupRequested(
        shareCode: _codeController.text.trim().toUpperCase(),
        uid: authState.user.uid,
        displayName: authState.user.displayName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Join a group'),
        backgroundColor: AppColors.surface,
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupActionSuccess) {
            context.pop();
          } else if (state is GroupsError) {
            final msg = switch (state.failure) {
              InvalidShareCode() => 'That code wasn\'t found. Check it and try again.',
              _ => 'Something went wrong. Try again.',
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is GroupActionLoading;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s4),
                  Text('Enter invite code.', style: AppTypography.xxl()),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    'Ask the group creator for their 6-character code.',
                    style: AppTypography.sm(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  TextFormField(
                    controller: _codeController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    maxLength: 6,
                    onFieldSubmitted: (_) => _submit(context),
                    style: AppTypography.xl(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Group code',
                      hintText: 'e.g. AB3X7K',
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length != 6) return 'Code must be 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _submit(context),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Join group'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
