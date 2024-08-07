// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:discord_sender/features/discord_sender/domain/entities/group.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/local_data/local_data_state.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/message/message_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/theme/theme.dart';
import 'package:discord_sender/features/discord_sender/presentation/pages/message_page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/local_data/local_data_bloc.dart';
import '../bloc/local_data/local_data_event.dart';
import '../widgets/card_ad.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool selected = true;
  bool tabsInit = false;
  late String result;
  String? comboboxValue;
  int currentIndex = 0;
  List<Tab> tabs = [];

  @override
  Widget build(BuildContext context) {
    context.watch<AppTheme>();
    FluentTheme.of(context);

    return BlocConsumer<LocalDataBloc, LocalDataState>(
        listener: (context, state) {
      if (state is LocalDataError) {
        showErrorDialog(context, state.errorMessage!, 'Data error');
      }
    }, builder: (context, state) {
      if (state is LocalDataLoading) {
        return const Loader();
      }

      return _buildbody(context);
    });
  }

  Widget _buildbody(BuildContext context) {
    return ScaffoldPage(
      content: TabView(
        tabs: createTabs(),
        currentIndex: currentIndex,
        onChanged: (index) => setState(() => currentIndex = index),
        tabWidthBehavior: TabWidthBehavior.equal,
        closeButtonVisibility: CloseButtonVisibilityMode.onHover,
        showScrollButtons: true,
        onNewPressed: () async {
          await _createGroup(context);
        },
        onReorder: (oldIndex, newIndex) {
          _reorderTabs(context, oldIndex, newIndex);
        },
      ),
    );
  }

  void _reorderTabs(BuildContext context, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = tabs.removeAt(oldIndex);
    tabs.insert(newIndex, item);
    final group = BlocProvider.of<LocalDataBloc>(context)
        .state
        .groups!
        .removeAt(oldIndex);

    if (currentIndex == newIndex) {
      currentIndex = oldIndex;
    } else if (currentIndex == oldIndex) {
      currentIndex = newIndex;
    }

    BlocProvider.of<LocalDataBloc>(context)
        .add(AddGroup(index: newIndex, group: group));
  }

  Future<void> _createGroup(BuildContext context) async {
    String? name = await _showCreateGroupDialog(context);
    if (name != null) {
      final tab = newTab(name, []);
      tabs.add(tab);
      BlocProvider.of<LocalDataBloc>(context)
          // ignore: prefer_const_literals_to_create_immutables
          .add(AddGroup(group: GroupEntity(name: name, items: [])));
    }
  }

  Widget messsagesList(List<int> items) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Button(
              child: const Text('new item'),
              onPressed: () async {
                await _createMessagePage(context);
              },
            ),
          ],
        ),
      ),
      Expanded(
          child: ReorderableListView.builder(
        proxyDecorator: (child, index, animation) {
          return mat.Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: animation.drive(
                Tween<double>(begin: 1, end: 1.03).chain(
                  CurveTween(curve: Curves.linear),
                ),
              ),
              child: child,
            ),
          );
        },
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return BlocProvider.value(
              key: Key('${items[index]}'),
              value: BlocProvider.of<LocalDataBloc>(context)
                  .state
                  .messageBlocs![items[index]]!,
              child: AdCard(
                key: Key('$index'),
                intKey: index,
                messageBloc: BlocProvider.of<LocalDataBloc>(context)
                    .state
                    .messageBlocs![items[index]] as MessageBloc,
                currentTabIndex: currentIndex,
              ));
        },
        onReorder: (int oldIndex, int newIndex) {
          _reorderCards(context, items, oldIndex, newIndex);
        },
      ))
    ]);
  }

  void _reorderCards(
      BuildContext context, List<int> items, int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final int item = items.removeAt(oldIndex);
      items.insert(newIndex, item); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      BlocProvider.of<LocalDataBloc>(context).add(const WriteData());
    });
  }

  Future<void> _createMessagePage(BuildContext context) async {
    await _showCreateMessageDialog(context) == true
        ? Navigator.of(
            context,
            rootNavigator: true,
          ).push(FluentPageRoute(builder: (context) {
            return MessagePage(
              name: result,
            );
          }))
        : null;
  }

  Tab newTab(String name, List<int> items) {
    late Tab tab;

    tab = Tab(
      icon: name == 'All messages'
          ? const Icon(FluentIcons.folder_list)
          : const Icon(FluentIcons.fabric_folder),
      text: Text(name),
      body: messsagesList(items),
      closeIcon:
          name == 'All messages' ? null : const Icon(FluentIcons.chrome_close),
      onClosed: () {
        if (BlocProvider.of<LocalDataBloc>(context)
                .state
                .groups![tabs.indexOf(tab)]
                .name !=
            'All messages') {
          if (currentIndex > 0) currentIndex--;
          BlocProvider.of<LocalDataBloc>(context)
              .add(RemoveGroup(index: tabs.indexOf(tab)));
          tabs.remove(tab);
        }
      },
    );
    return tab;
  }

  List<Tab> createTabs() {
    late Tab tab;
    tabs = [];
    if (BlocProvider.of<LocalDataBloc>(context).state.groups!.isEmpty) {
      tab = newTab('All messages', []);
      tabs.add(tab);
      const allMessagesGroup = GroupEntity(name: 'All messages', items: []);
      BlocProvider.of<LocalDataBloc>(context)
          .add(const AddGroup(group: allMessagesGroup));
      // BlocProvider.of<LocalDataBloc>(context)
      //     .state
      //     .groups!
      //     .add(allMessagesGroup);
    } else {
      for (int i = 0;
          i < BlocProvider.of<LocalDataBloc>(context).state.groups!.length;
          i++) {
        tab = newTab(
            BlocProvider.of<LocalDataBloc>(context).state.groups![i].name,
            BlocProvider.of<LocalDataBloc>(context).state.groups![i].items);
        tabs.add(tab);
      }
    }

    return tabs;
  }

  Future<String?> _showCreateGroupDialog(BuildContext context) async {
    String name = '`';
    bool emptyName = true;
    return await showDialog<String>(
        context: context,
        builder: (context) => ContentDialog(
              style: ContentDialogThemeData.standard(FluentThemeData(
                  brightness: FluentTheme.of(context).brightness)),
              //title: const Text('Write name'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                    width: 800,
                    height: 52,
                    child: Column(
                      children: [
                        TextBox(
                          placeholder: 'Write name of group',
                          onChanged: (text) {
                            name = text;
                            setState(() {
                              if (text.isEmpty) {
                                emptyName = true;
                              } else {
                                emptyName = false;
                              }
                            });
                          },
                        ),
                        emptyName && name != '`'
                            ? Text(
                                'Name can not be empty',
                                style: TextStyle(color: Colors.red),
                              )
                            : const SizedBox.shrink()
                      ],
                    ));
              }),
              actions: [
                FilledButton(
                  child: const Text('Create'),
                  onPressed: () {
                    emptyName ? null : Navigator.pop(context, name);
                  },
                ),
                Button(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, null),
                ),
              ],
            ));
  }

  Future<bool?> _showCreateMessageDialog(BuildContext context) async {
    result = '';
    return await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        style: ContentDialogThemeData.standard(
            FluentThemeData(brightness: FluentTheme.of(context).brightness)),
        //title: const Text('Write name'),
        content: SizedBox(
            width: 800,
            height: 50,
            child: TextBox(
              placeholder: 'Write name of message',
              onChanged: (text) {
                result = text;
              },
            )),
        actions: [
          FilledButton(
            child: const Text('Create'),
            onPressed: () {
              if (result == '') {
                int num = 1;
                List<int> nums = BlocProvider.of<LocalDataBloc>(context)
                    .state
                    .messages!
                    .values
                    .map((e) => e.name)
                    .where((e) => e.contains('New message'))
                    .map((e) => int.parse(e.replaceFirst('New message №', '')))
                    .toList();
                nums.sort();

                for (int i = 0; i < nums.length; i++) {
                  if (i + 1 != nums[i]) {
                    break;
                  }
                  num += 1;
                }
                result = 'New message №$num';
              }
              Navigator.pop(context, true);
            },
          ),
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}
