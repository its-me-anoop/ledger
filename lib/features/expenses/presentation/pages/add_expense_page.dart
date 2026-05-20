import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../groups/domain/models/group.dart';
import '../../../groups/presentation/bloc/group_detail_bloc.dart';
import '../../../groups/presentation/bloc/group_detail_event.dart';
import '../../../groups/presentation/bloc/group_detail_state.dart';
import '../../domain/models/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';

class AddExpensePage extends StatelessWidget {
  const AddExpensePage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupDetailBloc>(
      create: (_) =>
          getIt<GroupDetailBloc>()..add(LoadGroupDetail(groupId)),
      child: _AddExpenseView(groupId: groupId),
    );
  }
}

class _AddExpenseView extends StatelessWidget {
  const _AddExpenseView({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailBloc, GroupDetailState>(
      builder: (context, state) {
        if (state is GroupDetailLoaded) {
          return _AddExpenseForm(group: state.group);
        }
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(backgroundColor: AppColors.surface),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _AddExpenseForm extends StatefulWidget {
  const _AddExpenseForm({required this.group});

  final Group group;

  @override
  State<_AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<_AddExpenseForm> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  late String _paidByUid;
  late Set<String> _selectedUids;
  bool _submitting = false;

  static final _currencyFmt = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    _paidByUid = auth is Authenticated
        ? auth.user.uid
        : widget.group.memberUids.first;
    _selectedUids = Set.from(widget.group.memberUids);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  int get _amountCents {
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(text) ?? 0;
  }

  String get _perPersonDisplay {
    final n = _selectedUids.length;
    if (n == 0 || _amountCents == 0) return '';
    final share = _amountCents ~/ n;
    return 'Each person pays ${_currencyFmt.format(share / 100)}';
  }

  void _submit() {
    if (_amountCents == 0 || _descController.text.trim().isEmpty) return;
    if (_selectedUids.isEmpty) return;

    setState(() => _submitting = true);

    final expense = Expense(
      id: '',
      groupId: widget.group.id,
      amount: _amountCents,
      description: _descController.text.trim(),
      paidByUid: _paidByUid,
      splitAmongUids: _selectedUids.toList(),
      createdAt: DateTime.now(),
    );

    context.read<ExpenseBloc>().add(AddExpense(expense));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.group.memberUids;
    final names = widget.group.memberDisplayNames;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Add expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s6,
          AppSpacing.s8,
          AppSpacing.s6,
          AppSpacing.s4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How much?', style: AppTypography.xl()),
            const SizedBox(height: AppSpacing.s4),
            _AmountField(controller: _amountController),
            const SizedBox(height: AppSpacing.s8),
            Text('What was it for?', style: AppTypography.sm(color: AppColors.textMuted)),
            const SizedBox(height: AppSpacing.s2),
            TextField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'e.g. Dinner at Karavalli'),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text('Paid by', style: AppTypography.sm(color: AppColors.textMuted)),
            const SizedBox(height: AppSpacing.s2),
            DropdownButtonFormField<String>(
              initialValue: _paidByUid,
              decoration: const InputDecoration(),
              items: members
                  .map(
                    (uid) => DropdownMenuItem(
                      value: uid,
                      child: Text(names[uid] ?? uid),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _paidByUid = v!),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text('Split among', style: AppTypography.sm(color: AppColors.textMuted)),
            const SizedBox(height: AppSpacing.s2),
            ...members.map(
              (uid) => _SplitToggleRow(
                name: names[uid] ?? uid,
                selected: _selectedUids.contains(uid),
                onChanged: (v) => setState(() {
                  if (v) {
                    _selectedUids.add(uid);
                  } else {
                    _selectedUids.remove(uid);
                  }
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            ListenableBuilder(
              listenable: _amountController,
              builder: (context, child) => Text(
                _perPersonDisplay,
                style: AppTypography.sm(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '\$',
          style: AppTypography.xl(color: AppColors.textMuted),
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.xxxl(),
            decoration: const InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class _SplitToggleRow extends StatelessWidget {
  const _SplitToggleRow({
    required this.name,
    required this.selected,
    required this.onChanged,
  });

  final String name;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!selected),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              color: selected ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.s3),
            Text(name, style: AppTypography.base()),
          ],
        ),
      ),
    );
  }
}
