import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import '../bloc/theme/theme.dart';
import '../../../../main.dart';
import '../bloc/local_data/local_data_bloc.dart';
import '../bloc/local_data/local_data_event.dart';
import '../widgets/window_buttons.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({
    super.key,
    required this.child,
    required this.shellContext,
  });

  final Widget child;
  final BuildContext? shellContext;
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> with WindowListener {
  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  late final List<NavigationPaneItem> originalItems = [
    PaneItem(
      key: const ValueKey('/'),
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/logs'),
      icon: const Icon(FluentIcons.edit_note),
      title: const Text('Logs'),
      body: const SizedBox.shrink(),
    ),

    // TODO: Scrollbar, RatingBar
  ].map<NavigationPaneItem>((e) {
    PaneItem buildPaneItem(PaneItem item) {
      return PaneItem(
        key: item.key,
        icon: item.icon,
        title: item.title,
        body: item.body,
        onTap: () {
          final path = (item.key as ValueKey).value;
          if (GoRouterState.of(context).uri.toString() != path) {
            context.go(path);
          }
          item.onTap?.call();
        },
      );
    }

    if (e is PaneItemExpander) {
      return PaneItemExpander(
        key: e.key,
        icon: e.icon,
        title: e.title,
        body: e.body,
        items: e.items.map((item) {
          if (item is PaneItem) return buildPaneItem(item);
          return item;
        }).toList(),
      );
    }
    // ignore: unnecessary_type_check
    if (e is PaneItem) return buildPaneItem(e);
    return e;
  }).toList();
  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey('/settings'),
      icon: const Icon(FluentIcons.settings),
      title: const Text('Settings'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != '/settings') {
          context.go('/settings');
        }
      },
    )
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int indexOriginal = originalItems
        .where((item) => item.key != null)
        .toList()
        .indexWhere((item) => item.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = footerItems
          .where((element) => element.key != null)
          .toList()
          .indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
      }
      return originalItems
              .where((element) => element.key != null)
              .toList()
              .length +
          indexFooter;
    } else {
      return indexOriginal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = FluentLocalizations.of(context);
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);

    if (Navigator.canPop(context) == false) {
      setState(() {});
    }

    return Directionality(
        textDirection: appTheme.textDirection,
        child: Container(
            color: FluentTheme.of(context).micaBackgroundColor.withOpacity(0.5),
            child: Container(
              color: FluentTheme.of(context).brightness.isLight
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8),
              child: NavigationPaneTheme(
                  data: const NavigationPaneThemeData(
                    backgroundColor: Colors.transparent,
                  ),
                  child: NavigationView(
                    key: viewKey,
                    appBar: NavigationAppBar(
                      automaticallyImplyLeading: false,
                      leading: () {
                        final enabled = Navigator.canPop(context);

                        final onPressed = enabled
                            ? () {
                                if (Navigator.canPop(context)) {
                                  Navigator.canPop(context);
                                  setState(() {});
                                }
                              }
                            : null;
                        return NavigationPaneTheme(
                          data: NavigationPaneTheme.of(context)
                              .merge(NavigationPaneThemeData(
                            unselectedIconColor:
                                ButtonState.resolveWith((states) {
                              if (states.isDisabled) {
                                return ButtonThemeData.buttonColor(
                                    context, states);
                              }
                              return ButtonThemeData.uncheckedInputColor(
                                FluentTheme.of(context),
                                states,
                              ).basedOnLuminance();
                            }),
                          )),
                          child: Builder(builder: (context) {
                            return PaneItem(
                              icon: const Center(
                                  child: Icon(FluentIcons.back, size: 12.0)),
                              title: Text(localizations.backButtonTooltip),
                              body: const SizedBox.shrink(),
                              enabled: enabled,
                            ).build(
                              context,
                              false,
                              onPressed,
                              displayMode: PaneDisplayMode.compact,
                            );
                          }),
                        );
                      }(),
                      title: () {
                        if (kIsWeb) {
                          return const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(appTitle),
                          );
                        }
                        return const DragToMoveArea(
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(appTitle),
                          ),
                        );
                      }(),
                      actions: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 8.0),
                                child: ToggleSwitch(
                                  content: const Text('Dark Mode'),
                                  checked:
                                      FluentTheme.of(context).brightness.isDark,
                                  onChanged: (v) {
                                    if (v) {
                                      appTheme.mode = ThemeMode.dark;
                                    } else {
                                      appTheme.mode = ThemeMode.light;
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (!kIsWeb) const WindowButtons(),
                          ]),
                    ),
                    paneBodyBuilder: (item, child) {
                      // ignore: unused_local_variable
                      final name = item?.key is ValueKey
                          ? (item!.key as ValueKey).value
                          : null;
                      return widget.child;
                    },
                    pane: NavigationPane(
                      displayMode: PaneDisplayMode.compact,
                      selected: _calculateSelectedIndex(context),
                      header: SizedBox(
                        height: kOneLineTileHeight,
                        child: ShaderMask(
                            shaderCallback: (rect) {
                              final color = appTheme.color.defaultBrushFor(
                                theme.brightness,
                              );
                              return LinearGradient(
                                colors: [
                                  color,
                                  color,
                                ],
                              ).createShader(rect);
                            },
                            child: Image.file(
                              File('assets/discord_sender.png'),
                              width: 200,
                            )),
                      ),
                      indicator: () {
                        switch (appTheme.indicator) {
                          case NavigationIndicators.end:
                            return const EndNavigationIndicator();
                          case NavigationIndicators.sticky:
                          default:
                            return const StickyNavigationIndicator();
                        }
                      }(),
                      items: originalItems,
                      footerItems: footerItems,
                    ),
                    onOpenSearch: searchFocusNode.requestFocus,
                  )),
            )));
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            style: ContentDialogThemeData.standard(FluentThemeData(
                brightness: FluentTheme.of(context).brightness)),
            title: const Text('Confirm close'),
            content: const Text('Are you sure you want to close this window?'),
            actions: [
              FilledButton(
                child: const Text('Yes'),
                onPressed: () async {
                  BlocProvider.of<LocalDataBloc>(context).add(const CloseApp());
                  Navigator.pop(context);
                },
              ),
              Button(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}
