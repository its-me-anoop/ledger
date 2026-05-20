import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../expenses/domain/services/debt_simplifier.dart';
import '../../../expenses/presentation/bloc/expense_bloc.dart';
import '../../../expenses/presentation/bloc/expense_event.dart';
import '../../../expenses/presentation/bloc/expense_state.dart';
import '../../../expenses/presentation/widgets/activity_feed_view.dart';
import '../../../expenses/presentation/widgets/expense_list_view.dart';
import '../../domain/models/group.dart';
import '../bloc/group_detail_bloc.dart';
import '../bloc/group_detail_event.dart';
import '../bloc/group_detail_state.dart';
import '../widgets/member_avatar.dart';

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
        GroupDetailLoaded(:final group) => BlocProvider<ExpenseBloc>(
          create: (_) => getIt<ExpenseBloc>()..add(LoadExpenses(groupId)),
          child: _LoadedScaffold(group: group, groupId: groupId),
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
            _DebtRows(group: group, currentUid: currentUid),
            Expanded(
              child: TabBarView(
                children: [
                  // ExpenseListView reads the ExpenseBloc already in context.
                  const ExpenseListView(),
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
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        final netCents = state is ExpensesLoaded
            ? (state.netBalances[currentUid] ?? 0)
            : 0;
        return _BalanceStripContent(netCents: netCents);
      },
    );
  }
}

/// Inline list of debt pairs involving [currentUid].
class _DebtRows extends StatelessWidget {
  const _DebtRows({required this.group, required this.currentUid});

  final Group group;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpensesLoaded) return const SizedBox.shrink();
        final transfers = DebtSimplifier.simplify(state.netBalances)
            .where((t) => t.fromUid == currentUid || t.toUid == currentUid)
            .toList();
        if (transfers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final t in transfers)
              _DebtRow(
                transfer: t,
                currentUid: currentUid,
                memberNames: group.memberDisplayNames,
              ),
            const SizedBox(height: AppSpacing.s2),
          ],
        );
      },
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({
    required this.transfer,
    required this.currentUid,
    required this.memberNames,
  });

  final Transfer transfer;
  final String currentUid;
  final Map<String, String> memberNames;

  @override
  Widget build(BuildContext context) {
    final iOwe = transfer.fromUid == currentUid;
    final otherUid = iOwe ? transfer.toUid : transfer.fromUid;
    final otherName = memberNames[otherUid] ?? otherUid;
    final label = iOwe
        ? 'You owe $otherName ${_fmt(transfer.amountCents)}'
        : '$otherName owes you ${_fmt(transfer.amountCents)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s1,
        AppSpacing.s6,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.sm(
                color: iOwe ? AppColors.danger : AppColors.success,
              ),
            ),
          ),
          if (iOwe)
            GestureDetector(
              onTap: () => context.push(
                // fromUid is intentionally omitted — SettleUpPage always
                // derives it from the authenticated session.
                '/groups/${_groupId(context)}/settle-up'
                '?toUid=${transfer.toUid}'
                '&fromName=You'
                '&toName=$otherName'
                '&amount=${transfer.amountCents}',
              ),
              child: Text(
                'Settle up',
                style: AppTypography.sm(color: AppColors.primary)
                    .copyWith(decoration: TextDecoration.underline),
              ),
            ),
        ],
      ),
    );
  }

  static String _fmt(int cents) {
    final dollars = cents ~/ 100;
    final c = cents % 100;
    return '\$$dollars.${c.toString().padLeft(2, '0')}';
  }

  String _groupId(BuildContext context) {
    // GoRouter gives us the groupId from the path.
    return GoRouterState.of(context).pathParameters['groupId'] ?? '';
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
