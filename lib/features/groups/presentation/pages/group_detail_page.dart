import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../expenses/presentation/widgets/activity_feed_view.dart';
import '../../../expenses/presentation/widgets/expense_list_view.dart';
import '../../domain/models/group.dart';
import '../bloc/group_detail_bloc.dart';
import '../bloc/group_detail_event.dart';
import '../bloc/group_detail_state.dart';
import '../widgets/member_avatar.dart';
import '../../../../app/di.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupDetailBloc>(
      create: (_) => getIt<GroupDetailBloc>()..add(LoadGroupDetail(groupId)),
      child: _GroupDetailView(groupId: groupId),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailBloc, GroupDetailState>(
      builder: (context, state) => switch (state) {
        GroupDetailLoading() => Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(backgroundColor: AppColors.surface),
          body: const Center(child: CircularProgressIndicator()),
        ),
        GroupDetailNotFound() => Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(backgroundColor: AppColors.surface),
          body: Center(
            child: Text(
              'Group not found.',
              style: AppTypography.base(color: AppColors.textMuted),
            ),
          ),
        ),
        GroupDetailError(:final message) => Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(backgroundColor: AppColors.surface),
          body: Center(
            child: Text(
              message,
              style: AppTypography.base(color: AppColors.danger),
            ),
          ),
        ),
        GroupDetailLoaded(:final group) => _LoadedScaffold(
          group: group,
          groupId: groupId,
        ),
      },
    );
  }
}

class _LoadedScaffold extends StatelessWidget {
  const _LoadedScaffold({required this.group, required this.groupId});

  final Group group;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUid = authState is Authenticated ? authState.user.uid : '';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text(group.name, style: AppTypography.xl()),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Activity'),
              Tab(text: 'Members'),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BalanceStrip(group: group, currentUid: currentUid),
            Expanded(
              child: TabBarView(
                children: [
                  ExpenseListView(groupId: groupId),
                  ActivityFeedView(groupId: groupId),
                  _MembersTab(group: group),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/groups/$groupId/add-expense'),
          icon: const Icon(Icons.add),
          label: Text(
            'Add expense',
            style: AppTypography.base(weight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _BalanceStrip extends StatelessWidget {
  const _BalanceStrip({required this.group, required this.currentUid});

  final Group group;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    // Net balance is supplied by ExpenseBloc in M7.
    // For M6 the strip renders with zero balance (neutral state).
    return const _BalanceStripContent(netCents: 0);
  }
}

/// Extracted so widget tests can inject a net balance directly.
class BalanceStripContent extends StatelessWidget {
  const BalanceStripContent({super.key, required this.netCents});

  final int netCents;

  @override
  Widget build(BuildContext context) => _BalanceStripContent(netCents: netCents);
}

class _BalanceStripContent extends StatelessWidget {
  const _BalanceStripContent({required this.netCents});

  final int netCents;

  @override
  Widget build(BuildContext context) {
    final isNegative = netCents < 0;
    final color = isNegative ? AppColors.danger : AppColors.success;
    final label = _formatCents(netCents.abs());
    final sign = isNegative ? '– ' : '+ ';
    final displayText = netCents == 0 ? 'Settled' : '$sign\$$label';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s8,
        AppSpacing.s6,
        AppSpacing.s6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your balance',
            style: AppTypography.sm(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            displayText,
            style: AppTypography.xxl(
              color: netCents == 0 ? AppColors.textMuted : color,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCents(int cents) {
    final dollars = cents ~/ 100;
    final c = cents % 100;
    return '$dollars.${c.toString().padLeft(2, '0')}';
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final uids = group.memberUids;
    final names = group.memberDisplayNames;

    if (uids.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s6,
          vertical: AppSpacing.s10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Just you for now.', style: AppTypography.xl()),
            const SizedBox(height: AppSpacing.s3),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 68 * 8.0),
              child: Text(
                'Share the group code to invite people. You can find it in group settings.',
                style: AppTypography.base(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: uids.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(left: AppSpacing.s6),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
      itemBuilder: (context, index) {
        final uid = uids[index];
        final displayName = names[uid] ?? uid;
        return _MemberRow(uid: uid, displayName: displayName);
      },
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.uid, required this.displayName});

  final String uid;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s6,
        vertical: AppSpacing.s4,
      ),
      child: Row(
        children: [
          MemberAvatar(displayName: displayName, size: 48),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTypography.base(weight: FontWeight.w500),
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  uid,
                  style: AppTypography.sm(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
