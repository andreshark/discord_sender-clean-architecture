import 'package:equatable/equatable.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'theme.dart';

class ThemeState extends Equatable {
  const ThemeState(
      {this.displayMode = PaneDisplayMode.auto,
      this.indicator = NavigationIndicators.sticky,
      this.color,
      this.windowEffect = WindowEffect.disabled,
      this.textDirection = TextDirection.ltr,
      this.locale,
      this.themeMode = ThemeMode.system}); // Default theme = light theme

  final ThemeMode themeMode;
  final AccentColor? color;
  final PaneDisplayMode displayMode;
  final NavigationIndicators indicator;
  final WindowEffect windowEffect;
  final TextDirection textDirection;
  final Locale? locale;
  // `copyWith()` method allows us to emit brand new instance of ThemeState
  ThemeState copyWith({
    ThemeMode? themeMode,
    PaneDisplayMode? displayMode,
    NavigationIndicators? indicator,
    WindowEffect? windowEffect,
    TextDirection? textDirection,
    Locale? locale,
    AccentColor? color,
  }) =>
      ThemeState(
        themeMode: themeMode ?? this.themeMode,
        displayMode: displayMode ?? this.displayMode,
        indicator: indicator ?? this.indicator,
        windowEffect: windowEffect ?? this.windowEffect,
        textDirection: textDirection ?? this.textDirection,
        locale: locale ?? this.locale,
        color: color ?? this.color,
      );

  @override
  List<Object?> get props => [
        themeMode,
        displayMode,
        indicator,
        windowEffect,
        textDirection,
        locale,
        color
      ];
}
