import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    context.read<GroupBloc>().add(
      CreateGroupRequested(
        name: _nameController.text.trim(),
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
        title: const Text('Create group'),
        backgroundColor: AppColors.surface,
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupActionSuccess) {
            context.pop();
          } else if (state is GroupsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not create group. Try again.')),
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
                  Text('Name your group.', style: AppTypography.xxl()),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    'You\'ll share a code with your group so they can join.',
                    style: AppTypography.sm(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(context),
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      hintText: 'e.g. Flatmates 2025',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length < 2) return 'At least 2 characters';
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
                        : const Text('Create group'),
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
