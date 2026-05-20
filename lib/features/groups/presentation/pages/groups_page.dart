import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/models/group.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import '../widgets/member_avatar.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  bool _fabExpanded = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<GroupBloc>().add(LoadGroups(uid: authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Ledger'),
        centerTitle: true,
        leading: BlocBuilder<AuthBloc, AuthState>(
          builder: (_, state) {
            if (state is Authenticated) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.s2),
                child: MemberAvatar(
                  displayName: state.user.displayName,
                  size: 36,
                  photoUrl: state.user.photoUrl,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_fabExpanded) setState(() => _fabExpanded = false);
        },
        child: Stack(
          children: [
            BlocBuilder<GroupBloc, GroupState>(
              builder: (context, state) {
                return switch (state) {
                  GroupsLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  GroupsLoaded(:final groups) when groups.isEmpty =>
                    _EmptyState(),
                  GroupsLoaded(:final groups) => _GroupList(groups: groups),
                  GroupActionLoading(:final groups) when groups.isEmpty =>
                    _EmptyState(),
                  GroupActionLoading(:final groups) => _GroupList(groups: groups),
                  GroupActionSuccess(:final groups) => _GroupList(groups: groups),
                  GroupsError(:final groups) when groups.isEmpty => _EmptyState(),
                  GroupsError(:final groups) => _GroupList(groups: groups),
                  _ => _EmptyState(),
                };
              },
            ),
            if (_fabExpanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _fabExpanded = false),
                  behavior: HitTestBehavior.opaque,
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
            Positioned(
              right: AppSpacing.s4,
              bottom: AppSpacing.s4,
              child: _ExpandableFab(
                expanded: _fabExpanded,
                onToggle: () => setState(() => _fabExpanded = !_fabExpanded),
                onCreate: () {
                  setState(() => _fabExpanded = false);
                  context.push(AppRoutes.createGroup);
                },
                onJoin: () {
                  setState(() => _fabExpanded = false);
                  context.push(AppRoutes.joinGroup);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupList extends StatelessWidget {
  const _GroupList({required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (_, authState) {
        final uid = authState is Authenticated ? authState.user.uid : '';
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s6,
                  AppSpacing.s6,
                  AppSpacing.s6,
                  AppSpacing.s8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning.',
                      style: AppTypography.xl(),
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      '${groups.length} ${groups.length == 1 ? 'group' : 'groups'}',
                      style: AppTypography.sm(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final group = groups[index];
                  return _GroupRow(
                    group: group,
                    currentUid: uid,
                    isLast: index == groups.length - 1,
                  );
                },
                childCount: groups.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.s16),
            ),
          ],
        );
      },
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.group,
    required this.currentUid,
    required this.isLast,
  });

  final Group group;
  final String currentUid;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/groups/${group.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s6,
              vertical: AppSpacing.s4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: AppTypography.base(weight: FontWeight.w500),
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        '${group.memberUids.length} members',
                        style: AppTypography.sm(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                // Balance chip placeholder — actual balance comes from M7 (ExpenseBloc)
                const _BalanceChipPlaceholder(),
                const SizedBox(width: AppSpacing.s2),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          if (!isLast)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.s6),
              child: Divider(height: 1, thickness: 1, color: AppColors.border),
            ),
        ],
      ),
    );
  }
}

class _BalanceChipPlaceholder extends StatelessWidget {
  const _BalanceChipPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceRecessed,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        'Settled',
        style: AppTypography.sm(color: AppColors.textMuted)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s10),
          _ThreeDotIllustration(),
          const SizedBox(height: AppSpacing.s8),
          Text('No groups yet.', style: AppTypography.xl()),
          const SizedBox(height: AppSpacing.s3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 68 * 8.0),
            child: Text(
              'Create one and share the code with your group — everyone joins in seconds.',
              style: AppTypography.base(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.createGroup),
              child: const Text('Create your first group'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeDotIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: CustomPaint(painter: _OverlapCirclesPainter()),
    );
  }
}

class _OverlapCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDim
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const r = 30.0;
    final y = size.height * 0.5;
    final positions = [r, r + r * 1.4, r + r * 2.8];

    for (final cx in positions) {
      canvas.drawCircle(Offset(cx, y), r, paint);
      canvas.drawCircle(Offset(cx, y), r, stroke);
    }
  }

  @override
  bool shouldRepaint(_OverlapCirclesPainter old) => false;
}

class _ExpandableFab extends StatelessWidget {
  const _ExpandableFab({
    required this.expanded,
    required this.onToggle,
    required this.onCreate,
    required this.onJoin,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          opacity: expanded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 160),
          child: AnimatedSlide(
            offset: expanded ? Offset.zero : const Offset(0, 0.3),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: IgnorePointer(
              ignoring: !expanded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _FabOption(
                    label: 'Create a group',
                    icon: Icons.add_circle_outline,
                    onTap: onCreate,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  _FabOption(
                    label: 'Join with code',
                    icon: Icons.link,
                    onTap: onJoin,
                  ),
                  const SizedBox(height: AppSpacing.s3),
                ],
              ),
            ),
          ),
        ),
        FloatingActionButton.extended(
          onPressed: onToggle,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: AnimatedRotation(
            turns: expanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: const Icon(Icons.add),
          ),
          label: Text(
            'Add group',
            style: AppTypography.base(
              weight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ],
    );
  }
}

class _FabOption extends StatelessWidget {
  const _FabOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s2),
              Text(label, style: AppTypography.sm()),
            ],
          ),
        ),
      ),
    );
  }
}
