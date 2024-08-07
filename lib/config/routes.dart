import 'package:discord_sender/features/discord_sender/presentation/pages/auth_page.dart';
import 'package:discord_sender/features/discord_sender/presentation/pages/home_page.dart';
import 'package:discord_sender/features/discord_sender/presentation/pages/navigation_page.dart';
import 'package:discord_sender/features/discord_sender/presentation/pages/settings_page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

import '../features/discord_sender/presentation/pages/logs_page.dart';

class AppRoutes {
  static GoRouter onGenerateRoutes(rootNavigatorKey) {
    final shellNavigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
        initialLocation: '/auth',
        navigatorKey: rootNavigatorKey,
        routes: [
          ShellRoute(
              navigatorKey: shellNavigatorKey,
              builder: (context, state, child) {
                return NavigationPage(
                  shellContext: shellNavigatorKey.currentContext,
                  child: child,
                );
              },
              routes: [
                /// Home
                GoRoute(
                    path: '/', builder: (context, state) => const HomePage()),
                GoRoute(
                    path: '/logs',
                    builder: (context, state) => const LogsPage()),

                /// Settings
                GoRoute(
                    path: '/settings',
                    builder: (context, state) => const Settings())
              ]),
          GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
        ]);
  }
}
