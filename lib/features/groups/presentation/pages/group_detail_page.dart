import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_state.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: BlocBuilder<GroupBloc, GroupState>(
          builder: (_, state) {
            final name = switch (state) {
              GroupsLoaded(:final groups) =>
                groups.where((g) => g.id == groupId).firstOrNull?.name ?? '',
              GroupActionSuccess(:final groups) =>
                groups.where((g) => g.id == groupId).firstOrNull?.name ?? '',
              _ => '',
            };
            return Text(name, style: AppTypography.xl());
          },
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s6),
          child: Text(
            'Group detail — expenses coming in M6.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
