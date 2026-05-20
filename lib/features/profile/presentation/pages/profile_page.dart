import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../groups/presentation/widgets/member_avatar.dart';
import '../../domain/user_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _editing = false;
  late TextEditingController _nameController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    final name = auth is Authenticated ? auth.user.displayName : '';
    _nameController = TextEditingController(text: name);
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _commitName);
  }

  Future<void> _commitName() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;
    final name = _nameController.text.trim();
    if (name.isEmpty || name == auth.user.displayName) return;

    final repo = getIt<UserRepository>();
    await repo.updateDisplayName(auth.user.uid, name);
  }

  void _onDone() {
    _debounce?.cancel();
    _commitName();
    setState(() => _editing = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox.shrink();
        final user = state.user;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: const Text('Profile'),
            actions: [
              TextButton(
                onPressed: () => context.push('/settings'),
                child: Text(
                  'Settings',
                  style: AppTypography.sm(color: AppColors.primary),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s4),
                MemberAvatar(
                  displayName: user.displayName,
                  size: 64,
                  photoUrl: user.photoUrl,
                ),
                const SizedBox(height: AppSpacing.s6),
                _editing
                    ? _InlineNameField(
                        controller: _nameController,
                        onDone: _onDone,
                      )
                    : GestureDetector(
                        onTap: () => setState(() => _editing = true),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(user.displayName, style: AppTypography.xl()),
                            const SizedBox(width: AppSpacing.s2),
                            const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  user.email,
                  style: AppTypography.sm(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.s8),
                const Divider(),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const SignOutRequested());
                    },
                    icon: const Icon(Icons.logout, color: AppColors.danger),
                    label: Text(
                      'Sign out',
                      style: AppTypography.base(color: AppColors.danger),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InlineNameField extends StatelessWidget {
  const _InlineNameField({
    required this.controller,
    required this.onDone,
  });

  final TextEditingController controller;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            style: AppTypography.xl(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => onDone(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check, color: AppColors.primary),
          onPressed: onDone,
        ),
      ],
    );
  }
}
