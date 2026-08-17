import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/approval/presentation/approval_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/dop/presentation/dop_list_page.dart';
import '../features/dop/presentation/dop_request_page.dart';
import '../features/master/presentation/master_page.dart';
import '../shared/widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) {
              return const DashboardPage();
            }
          ),
          GoRoute(
            path: '/dop-list',
            builder: (context, state) {
              return const DopListPage();
            }
          ),
          GoRoute(
            path: '/dop-request',
            builder: (context, state) {
              return const DopRequestPage();
            }
          ),
          GoRoute(
            path: '/approval',
            builder: (context, state) {
              return const ApprovalPage();
            }
          ),
          GoRoute(
            path: '/master',
            builder: (context, state) {
              return const MasterPage();
            }
          ),
        ],
      ),
    ],
  );
});