import 'dart:async';
import 'dart:developer';

import 'package:discord_sender/features/discord_sender/presentation/bloc/auth/auth_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/local_data/local_data_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/local_data/local_data_event.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/logs/logs_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:go_router/go_router.dart';
import 'core/app_bloc_observer.dart';
import 'features/discord_sender/presentation/bloc/theme/theme.dart';
import 'features/discord_sender/presentation/bloc/auth/auth_event.dart';
import 'injection_container.dart';

const String appTitle = 'Discord Sender';
String failMes = '';
final rootNavigatorKey = GlobalKey<NavigatorState>();

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

// пофиксить closesession
void main() async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // if it's not on the web, windows or android, load the accent color
      if (!kIsWeb &&
          [
            TargetPlatform.windows,
            TargetPlatform.android,
          ].contains(defaultTargetPlatform)) {
        SystemTheme.accentColor.load();
      }

      if (isDesktop) {
        await flutter_acrylic.Window.initialize();
        if (defaultTargetPlatform == TargetPlatform.windows) {
          await flutter_acrylic.Window.hideWindowControls();
          Window.setEffect(
            effect: WindowEffect.aero,
            //color: FluentTheme.of(context).micaBackgroundColor.withOpacity(0.8),
            //dark: FluentTheme.of(context).brightness.isDark,
          );
        }
        await WindowManager.instance.ensureInitialized();
        await initializeDependencies(rootNavigatorKey);

        windowManager.waitUntilReadyToShow().then((_) async {
          await windowManager.setTitleBarStyle(
            TitleBarStyle.hidden,
            windowButtonVisibility: false,
          );
          await windowManager.setMinimumSize(const Size(800, 600));
          await windowManager.setSize(const Size(1400, 800));
          await windowManager.show();
          await windowManager.setPreventClose(true);
          await windowManager.setSkipTaskbar(false);
        });
      }

      return runApp(MultiBlocProvider(providers: [
        BlocProvider<LocalDataBloc>(
            lazy: false, create: (context) => sl()..add(const ReadData())),
        BlocProvider<LogsCubit>(create: (context) => sl()),
        BlocProvider<AuthBloc>(
            create: (context) => sl()..add(const CheckLicense())),
        BlocProvider<AppTheme>(create: (context) => sl()),
      ], child: const MyApp()));
    },
    (error, stackTrace) {
      log(error.toString(), stackTrace: stackTrace);
      sl<Logger>().e('$error', error: error);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return FluentApp.router(
      title: 'Discord sender',
      themeMode: appTheme.mode,
      debugShowCheckedModeBanner: false,
      color: appTheme.color,
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 40, 40, 40),
        micaBackgroundColor: Colors.white,
        accentColor: appTheme.color,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
      ),
      theme: FluentThemeData(
        accentColor: appTheme.color,
        scaffoldBackgroundColor: const Color.fromARGB(255, 246, 246, 246),
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
      ),
      locale: appTheme.locale,
      routeInformationParser: sl<GoRouter>().routeInformationParser,
      routerDelegate: sl<GoRouter>().routerDelegate,
      routeInformationProvider: sl<GoRouter>().routeInformationProvider,
    );
  }
}
