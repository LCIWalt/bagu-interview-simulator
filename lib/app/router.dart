import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design/design_demo_page.dart';
import '../features/bank/presentation/bank_page.dart';
import '../features/bank/presentation/edit/question_edit_page.dart';
import '../features/bank/presentation/question_detail_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/interview/presentation/config/mock_setup_page.dart';
import '../features/interview/presentation/drill/drill_page.dart';
import '../features/interview/presentation/live/mock_live_page.dart';
import '../features/review/presentation/mock_report_page.dart';
import '../features/review/presentation/review_page.dart';
import '../features/settings/presentation/settings_page.dart';
import 'app_shell.dart';

/// 路由表。设计演示页在 shell 之外，方便三端截图对比。
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell shell,
      ) => AppShell(shell: shell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              name: 'practice',
              builder: (BuildContext context, GoRouterState state) =>
                  const HomePage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'drill',
                  name: 'drill',
                  builder: (BuildContext context, GoRouterState state) =>
                      const DrillPage(),
                ),
                GoRoute(
                  path: 'drill/:id',
                  name: 'drill-question',
                  builder: (BuildContext context, GoRouterState state) =>
                      DrillPage(questionId: state.pathParameters['id']),
                ),
                GoRoute(
                  path: 'mock/setup',
                  name: 'mock-setup',
                  builder: (BuildContext context, GoRouterState state) =>
                      const MockSetupPage(),
                ),
                GoRoute(
                  path: 'mock/live/:id',
                  name: 'mock-live',
                  builder: (BuildContext context, GoRouterState state) =>
                      MockLivePage(sessionId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'mock/report/:id',
                  name: 'mock-report',
                  builder: (BuildContext context, GoRouterState state) =>
                      MockReportPage(sessionId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/bank',
              name: 'bank',
              builder: (BuildContext context, GoRouterState state) =>
                  const BankPage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'new',
                  name: 'bank-new',
                  builder: (BuildContext context, GoRouterState state) =>
                      const QuestionEditPage(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'bank-question',
                  builder: (BuildContext context, GoRouterState state) =>
                      QuestionDetailPage(
                        questionId: state.pathParameters['id']!,
                      ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/review',
              name: 'review',
              builder: (BuildContext context, GoRouterState state) =>
                  const ReviewPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (BuildContext context, GoRouterState state) =>
                  const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/design',
      name: 'design',
      builder: (BuildContext context, GoRouterState state) =>
          const DesignDemoPage(),
    ),
  ],
);
