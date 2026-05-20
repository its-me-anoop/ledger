import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/groups/presentation/bloc/group_bloc.dart';
import 'di.dart';

class LedgerApp extends StatefulWidget {
  const LedgerApp({super.key});

  @override
  State<LedgerApp> createState() => _LedgerAppState();
}

class _LedgerAppState extends State<LedgerApp> {
  late final AuthBloc _authBloc;
  late final GroupBloc _groupBloc;
  late final ThemeCubit _themeCubit;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _groupBloc = getIt<GroupBloc>();
    _themeCubit = getIt<ThemeCubit>();
  }

  @override
  void dispose() {
    _authBloc.close();
    _groupBloc.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _groupBloc),
        BlocProvider.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (ctx, themeMode) {
          final router = buildRouter(ctx);
          return MaterialApp.router(
            title: 'Ledger',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
