import 'package:flutter_acrylic/window_effect.dart';

const String discordAPIBaseURL = 'https://discord.com/api/v9';

const String discordAvatarBaseURL = 'https://cdn.discordapp.com';

const String keyauthAPIBaseURL = 'https://keyauth.win/api/1.2/';

const String dataPath = 'assets//data.json';

const List<String> accentColorNames = [
  'System',
  'Yellow',
  'Orange',
  'Red',
  'Magenta',
  'Purple',
  'Blue',
  'Teal',
  'Green',
];
// ignore: constant_identifier_names
const LinuxWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.transparent,
];

// ignore: constant_identifier_names
const WindowsWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.solid,
  WindowEffect.transparent,
  WindowEffect.aero,
  WindowEffect.acrylic,
  WindowEffect.mica,
  WindowEffect.tabbed,
];

// ignore: constant_identifier_names
const MacosWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.titlebar,
  WindowEffect.selection,
  WindowEffect.menu,
  WindowEffect.popover,
  WindowEffect.sidebar,
  WindowEffect.headerView,
  WindowEffect.sheet,
  WindowEffect.windowBackground,
  WindowEffect.hudWindow,
  WindowEffect.fullScreenUI,
  WindowEffect.toolTip,
  WindowEffect.contentBackground,
  WindowEffect.underWindowBackground,
  WindowEffect.underPageBackground,
];
