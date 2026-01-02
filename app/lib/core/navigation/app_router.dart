import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/ui/screens/home/home_screen.dart';
import 'package:ergo_life_app/ui/screens/profile/profile_screen.dart';
import 'package:ergo_life_app/ui/screens/tasks/tasks_screen.dart';
import 'package:ergo_life_app/ui/screens/tasks/create_task_screen.dart';
import 'package:ergo_life_app/ui/screens/tasks/active_session_screen.dart';
import 'package:ergo_life_app/ui/screens/main/main_shell_screen.dart';
import 'package:ergo_life_app/ui/screens/splash/splash_screen.dart';
import 'package:ergo_life_app/ui/screens/onboarding/onboarding_screen.dart';
import 'package:ergo_life_app/ui/screens/auth/login_screen.dart';
import 'package:ergo_life_app/ui/screens/rewards/rewards_screen.dart';
import 'package:ergo_life_app/data/models/task_model.dart';

// DI
import 'package:ergo_life_app/core/di/service_locator.dart';

// BLoCs
import 'package:ergo_life_app/blocs/auth/auth_bloc.dart';
import 'package:ergo_life_app/blocs/home/home_bloc.dart';
import 'package:ergo_life_app/blocs/tasks/tasks_bloc.dart';
import 'package:ergo_life_app/blocs/task/task_bloc.dart';
import 'package:ergo_life_app/blocs/rewards/rewards_bloc.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_bloc.dart';
import 'package:ergo_life_app/blocs/house/house_bloc.dart';

// House screens
import 'package:ergo_life_app/ui/screens/house/invite_members_screen.dart';
import 'package:ergo_life_app/ui/screens/house/join_house_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/';
  static const String rank = '/rank';
  static const String tasks = '/tasks';
  static const String profile = '/profile';
  static const String createTask = '/create-task';

  static const String activeSession = '/active-session';
  static const String rewards = '/rewards';

  // House routes
  static const String inviteMembers = '/house/invite';
  static const String joinHouse = '/house/join';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Home (Arena) Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                name: 'home',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: HomeScreen(homeBloc: sl<HomeBloc>()),
                ),
              ),
            ],
          ),
          // Rewards Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: rewards,
                name: 'rewards',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: RewardsScreen(rewardsBloc: sl<RewardsBloc>()),
                ),
              ),
            ],
          ),
          // Tasks Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: tasks,
                name: 'tasks',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: TasksScreen(tasksBloc: sl<TasksBloc>()),
                ),
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                name: 'profile',
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      // Top-level routes (outside shell)
      GoRoute(
        path: createTask,
        name: 'createTask',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: CreateTaskScreen(taskBloc: sl<TaskBloc>()),
        ),
      ),
      GoRoute(
        path: activeSession,
        name: 'activeSession',
        pageBuilder: (context, state) {
          final task = state.extra as TaskModel?;
          if (task == null) {
            // Fallback to a default task if no task provided
            return MaterialPage(
              fullscreenDialog: true,
              child: ActiveSessionScreen(
                task: PredefinedTasks.quickTasks.first,
              ),
            );
          }
          return MaterialPage(
            fullscreenDialog: true,
            child: ActiveSessionScreen(task: task),
          );
        },
      ),
      GoRoute(
        path: splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            NoTransitionPage(child: SplashScreen(authBloc: sl<AuthBloc>())),
      ),

      GoRoute(
        path: onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => NoTransitionPage(
          child: OnboardingScreen(onboardingBloc: sl<OnboardingBloc>()),
        ),
      ),
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) =>
            NoTransitionPage(child: LoginScreen(authBloc: sl<AuthBloc>())),
      ),

      // House Management Routes
      GoRoute(
        path: inviteMembers,
        name: 'inviteMembers',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: InviteMembersScreen(houseBloc: sl<HouseBloc>()),
        ),
      ),
      GoRoute(
        path: joinHouse,
        name: 'joinHouse',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: JoinHouseScreen(houseBloc: sl<HouseBloc>()),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(home),
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
