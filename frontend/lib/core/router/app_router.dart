import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/contacts/contacts_list_screen.dart';
import '../../features/contacts/contact_detail_screen.dart';
import '../../features/companies/companies_list_screen.dart';
import '../../features/companies/company_detail_screen.dart';
import '../../features/leads/leads_screen.dart';
import '../../features/deals/deals_pipeline_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/settings/settings_screen.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated ||
          previous?.initializing != next.initializing) {
        notifyListeners();
      }
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/register';

      if (auth.initializing) {
        return loc == '/splash' ? null : '/splash';
      }
      if (loc == '/splash') {
        return auth.isAuthenticated ? '/dashboard' : '/login';
      }
      if (!auth.isAuthenticated && !loggingIn) return '/login';
      if (auth.isAuthenticated && loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/contacts',
            builder: (context, state) => const ContactsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    ContactDetailScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/companies',
            builder: (context, state) => const CompaniesListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    CompanyDetailScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(path: '/leads', builder: (context, state) => const LeadsScreen()),
          GoRoute(
              path: '/deals', builder: (context, state) => const DealsPipelineScreen()),
          GoRoute(path: '/tasks', builder: (context, state) => const TasksScreen()),
          GoRoute(
              path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
