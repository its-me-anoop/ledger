import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/models/settlement.dart';
import '../bloc/settlement_bloc.dart';
import '../bloc/settlement_event.dart';
import '../bloc/settlement_state.dart';

class SettleUpPage extends StatelessWidget {
  const SettleUpPage({
    super.key,
    required this.groupId,
    required this.toUid,
    required this.fromName,
    required this.toName,
    required this.amountCents,
  });

  final String groupId;
  // fromUid is intentionally absent: it is always derived from the
  // authenticated user inside _SettleUpView so it cannot be spoofed via
  // a manipulated route.
  final String toUid;
  final String fromName;
  final String toName;
  final int amountCents;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettlementBloc>(
      create: (_) => getIt<SettlementBloc>(),
      child: _SettleUpView(
        groupId: groupId,
        toUid: toUid,
        fromName: fromName,
        toName: toName,
        amountCents: amountCents,
      ),
    );
  }
}

class _SettleUpView extends StatefulWidget {
  const _SettleUpView({
    required this.groupId,
    required this.toUid,
    required this.fromName,
    required this.toName,
    required this.amountCents,
  });

  final String groupId;
  final String toUid;
  final String fromName;
  final String toName;
  final int amountCents;

  @override
  State<_SettleUpView> createState() => _SettleUpViewState();
}

class _SettleUpViewState extends State<_SettleUpView> {
  static final _currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  String _requireCurrentUid(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) return authState.user.uid;
    // Should never reach here — router guards unauthenticated access.
    throw StateError('SettleUpPage reached without an authenticated user');
  }

  @override
  Widget build(BuildContext context) {
    final amountDisplay = _currencyFmt.format(widget.amountCents / 100);

    return BlocListener<SettlementBloc, SettlementState>(
      listener: (context, state) {
        if (state is SettlementRecorded) {
          Future.delayed(const Duration(milliseconds: 400), () {
            if (context.mounted) context.pop();
          });
        }
        if (state is SettlementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => context.read<SettlementBloc>().add(
                  RecordSettlement(
                    Settlement(
                      id: '',
                      groupId: widget.groupId,
                      fromUid: _requireCurrentUid(context),
                      toUid: widget.toUid,
                      amount: widget.amountCents,
                      createdAt: DateTime.now(),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text('Settle up'),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s6,
            AppSpacing.s12,
            AppSpacing.s6,
            AppSpacing.s6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.fromName, style: AppTypography.xl()),
              const SizedBox(height: AppSpacing.s1),
              Text(
                'owes ${widget.toName}',
                style: AppTypography.base(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                amountDisplay,
                style: AppTypography.xxxl(color: AppColors.danger),
              ),
              const SizedBox(height: AppSpacing.s10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 65 * 8.0),
                child: Text(
                  'This will mark all shared expenses between you as settled. Record any outside payment separately.',
                  style: AppTypography.sm(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              BlocBuilder<SettlementBloc, SettlementState>(
                builder: (context, state) {
                  return _SettleButton(
                    state: state,
                    onPressed: () => context.read<SettlementBloc>().add(
                      RecordSettlement(
                        Settlement(
                          id: '',
                          groupId: widget.groupId,
                          fromUid: _requireCurrentUid(context),
                          toUid: widget.toUid,
                          amount: widget.amountCents,
                          createdAt: DateTime.now(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s3),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettleButton extends StatelessWidget {
  const _SettleButton({required this.state, required this.onPressed});

  final SettlementState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: state is SettlementRecording || state is SettlementRecorded
            ? null
            : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          child: switch (state) {
            SettlementRecorded() => const Icon(
              Icons.check,
              key: ValueKey('check'),
              color: Colors.white,
            ),
            SettlementRecording() => const SizedBox(
              key: ValueKey('loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            _ => const Text('Mark as settled', key: ValueKey('label')),
          },
        ),
      ),
    );
  }
}
