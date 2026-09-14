import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/approval/presentation/approval_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/dop/presentation/dop_list_page.dart';
import '../features/dop/presentation/dop_request_page.dart';
import '../features/master/presentation/master_page.dart';
import '../shared/widgets/app_shell.dart';
import '../features/approval/domain/dop_approval_list_item.dart';
import '../features/approval/presentation/dop_approval_detail_page.dart';
import '../features/dop/presentation/dop_revision_list_page.dart';
import '../features/master/presentation/master_page.dart';
import '../features/master/presentation/master_approval_page.dart';

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
            path: '/dop-revisions',
            builder: (context, state) {
              return const DopRevisionListPage();
            },
          ),
          GoRoute(
            path: '/dop-request',
            builder: (context, state) {
              final extra = state.extra;

              String? revisionDopHeaderId;
              String? draftDopHeaderId;

              if (extra is String) {
                revisionDopHeaderId = extra;
              }

              if (extra is Map) {
                final draftId =
                extra['draftDopHeaderId'];

                if (draftId is String &&
                    draftId.trim().isNotEmpty) {
                  draftDopHeaderId =
                      draftId.trim();
                }
              }

              return DopRequestPage(
                revisionDopHeaderId:
                revisionDopHeaderId,
                draftDopHeaderId:
                draftDopHeaderId,
              );
            },
          ),
          GoRoute(
            path: '/approval',
            builder: (context, state) {
              return const ApprovalPage();
            }
          ),
          GoRoute(
            path: '/approval/review',
            builder: (context, state) {
              final approvalItem =
              state.extra as DopApprovalListItem?;

              if (approvalItem == null) {
                return const ApprovalPage();
              }

              return DopApprovalDetailPage(
                approvalItem: approvalItem,
              );
            },
          ),
          GoRoute(
            path: '/master-approval',
            builder: (context, state) {
              return const MasterApprovalPage();
            },
          ),
          GoRoute(
            path: '/master',
            builder: (context, state) {
              return const MasterPage();
            },
          ),
        ],
      ),
    ],
  );
});