import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/groups/presentation/pages/create_group_page.dart';
import '../../features/groups/presentation/pages/group_detail_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/groups/presentation/pages/join_group_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/settlements/presentation/pages/settle_up_page.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const register = '/register';
  static const groups = '/groups';
  static const createGroup = '/groups/create';
  static const joinGroup = '/groups/join';
  static const groupDetail = '/groups/:groupId';
  static const addExpense = '/groups/:groupId/add-expense';
  static const settleUp = '/groups/:groupId/settle-up';
  static const profile = '/profile';
  static const settings = '/profile/settings';
}

GoRouter buildRouter(BuildContext rootContext) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final authState = rootContext.read<AuthBloc>().state;
      final isAuthenticated = authState is Authenticated;
      final isOnAuthPath = state.matchedLocation == AppRoutes.signIn ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.splash;

      if (!isAuthenticated && !isOnAuthPath) {
        return AppRoutes.signIn;
      }
      if (isAuthenticated && isOnAuthPath && state.matchedLocation != AppRoutes.splash) {
        return AppRoutes.groups;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (ctx, st) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (ctx, st) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (ctx, st) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.groups,
                builder: (ctx, st) => const GroupsPage(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (ctx, st) => const CreateGroupPage(),
                  ),
                  GoRoute(
                    path: 'join',
                    builder: (ctx, st) => const JoinGroupPage(),
                  ),
                  GoRoute(
                    path: ':groupId',
                    builder: (_, state) => GroupDetailPage(
                      groupId: state.pathParameters['groupId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'add-expense',
                        builder: (_, state) => AddExpensePage(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'settle-up',
                        builder: (_, state) {
                          final p = state.pathParameters;
                          final q = state.uri.queryParameters;
                          return SettleUpPage(
                            groupId: p['groupId']!,
                            fromUid: q['fromUid'] ?? '',
                            toUid: q['toUid'] ?? '',
                            fromName: q['fromName'] ?? '',
                            toName: q['toName'] ?? '',
                            amountCents:
                                int.tryParse(q['amount'] ?? '0') ?? 0,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (ctx, st) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (ctx, st) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
