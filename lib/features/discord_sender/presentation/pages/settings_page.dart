// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/theme/theme.dart';
import '../../../../core/constants.dart';

bool get kIsWindowEffectsSupported {
  return !kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);
}

List<WindowEffect> get currentWindowEffects {
  if (kIsWeb) return [];

  if (defaultTargetPlatform == TargetPlatform.windows) {
    return WindowsWindowEffects;
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    return LinuxWindowEffects;
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    return MacosWindowEffects;
  }

  return [];
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final appTheme = context.watch<AppTheme>();
    const spacer = SizedBox(height: 10.0);
    const biggerSpacer = SizedBox(height: 40.0);

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Settings')),
      children: [
        Text('Theme mode', style: FluentTheme.of(context).typography.subtitle),
        spacer,
        ...List.generate(ThemeMode.values.length, (index) {
          final mode = ThemeMode.values[index];
          return Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8.0),
            child: RadioButton(
              checked: appTheme.mode == mode,
              onChanged: (value) {
                if (value) {
                  appTheme.mode = mode;

                  if (kIsWindowEffectsSupported) {
                    // some window effects require on [dark] to look good.
                    // appTheme.setEffect(WindowEffect.disabled, context);
                    appTheme.setEffect(appTheme.windowEffect, context);
                  }
                }
              },
              content: Text('$mode'.replaceAll('ThemeMode.', '')),
            ),
          );
        }),
        biggerSpacer,
        Text('Accent Color',
            style: FluentTheme.of(context).typography.subtitle),
        spacer,
        Wrap(children: [
          Tooltip(
            message: accentColorNames[0],
            child: _buildColorBlock(appTheme, systemAccentColor),
          ),
          ...List.generate(Colors.accentColors.length, (index) {
            final color = Colors.accentColors[index];
            return Tooltip(
              message: accentColorNames[index + 1],
              child: _buildColorBlock(appTheme, color),
            );
          }),
        ]),
      ],
    );
  }
}

Widget _buildColorBlock(AppTheme appTheme, AccentColor color) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Button(
      onPressed: () {
        appTheme.color = color;
      },
      style: ButtonStyle(
        padding: ButtonState.all(EdgeInsets.zero),
        backgroundColor: ButtonState.resolveWith((states) {
          if (states.isPressing) {
            return color.light;
          } else if (states.isHovering) {
            return color.lighter;
          }
          return color;
        }),
      ),
      child: Container(
        height: 40,
        width: 40,
        alignment: AlignmentDirectional.center,
        child: appTheme.color == color
            ? Icon(
                FluentIcons.check_mark,
                color: color.basedOnLuminance(),
                size: 22.0,
              )
            : null,
      ),
    ),
  );
}
