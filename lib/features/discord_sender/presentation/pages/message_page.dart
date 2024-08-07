import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/message.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/edit_message/edit_message_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/edit_message/edit_message_state.dart';
import 'package:discord_sender/features/discord_sender/presentation/widgets/error_dialog.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import '../../../../injection_container.dart';
import '../bloc/local_data/local_data_bloc.dart';
import '../bloc/local_data/local_data_event.dart';
import '../widgets/channel_select_dialog.dart';
import '../widgets/discord_view.dart';
import '../widgets/drag_zone.dart';
import '../widgets/file_blocks.dart';
import '../widgets/window_buttons.dart';

// ignore: must_be_immutable
class MessagePage extends StatefulWidget {
  const MessagePage({super.key, this.name, this.message});

  final MessageEntity? message;
  final String? name;
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _controllerToken = TextEditingController();
  final _controllerText = TextEditingController();
  final _controllerChannel = TextEditingController();
  final treeViewKey = GlobalKey<TreeViewState>(debugLabel: 'TreeView key');
  final contextController = FlyoutController();
  late EditMessageCubit editMessageCubit;

  @override
  void initState() {
    super.initState();

    _controllerChannel.addListener(
        () => editMessageCubit.onChangeChannel(_controllerChannel.text));

    _controllerToken.addListener(
        () => editMessageCubit.onChangeToken(_controllerToken.text));
    _controllerText.addListener(() {
      editMessageCubit.text = _controllerText.text;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _controllerText.dispose();
    _controllerToken.dispose();
    _controllerChannel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return BlocProvider(
        create: (context) {
          editMessageCubit = EditMessageCubit(
              sl(), sl(), sl(), sl(), sl(), sl(), widget.message, widget.name)
            ..init();
          _controllerChannel.text = editMessageCubit.channel.id;
          _controllerToken.text = editMessageCubit.token;
          _controllerText.text = editMessageCubit.text;
          return editMessageCubit;
        },
        child: BlocConsumer<EditMessageCubit, EditMessageState>(
          listener: (context, state) {
            if (state is ErrorMessageState) {
              showErrorDialog(context, state.errorMessage, 'Discord api error');
            }
            if (state is SaveMessageState) {
              if (state.snackMessage) {
                BlocProvider.of<LocalDataBloc>(context)
                    .add(AddMessage(message: state.message!));
                displayInfoBar(context, builder: (context, close) {
                  return InfoBar(
                    title: const Text('Message saved'),
                    action: IconButton(
                      icon: const Icon(FluentIcons.clear),
                      onPressed: close,
                    ),
                    severity: InfoBarSeverity.success,
                  );
                });
              } else {
                displayInfoBar(context, builder: (context, close) {
                  return InfoBar(
                    title: const Text('Message not saved'),
                    action: IconButton(
                      icon: const Icon(FluentIcons.clear),
                      onPressed: close,
                    ),
                    severity: InfoBarSeverity.error,
                  );
                });
              }
            }
          },
          builder: (context, state) {
            return Container(
                color: FluentTheme.of(context)
                    .micaBackgroundColor
                    .withOpacity(0.5),
                child: Container(
                    color: FluentTheme.of(context).brightness.isLight
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.8),
                    child: NavigationPaneTheme(
                        data: const NavigationPaneThemeData(
                          backgroundColor: Colors.transparent,
                        ),
                        child: NavigationView(
                            appBar: NavigationAppBar(
                              title: () {
                                const title = Text('Discord Sender');

                                return const DragToMoveArea(
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: title,
                                  ),
                                );
                              }(),
                              actions: const WindowButtons(),
                              leading: IconButton(
                                icon: const Icon(FluentIcons.back),
                                onPressed: () => context.pop(),
                              ),
                            ),
                            content: ScaffoldPage(
                                header: PageHeader(
                                    title: Text(editMessageCubit.name)),
                                content: DropTarget(
                                    onDragDone: (url) {
                                      editMessageCubit.dragFileEvent(url);
                                    },
                                    onDragEntered: (details) {
                                      editMessageCubit.isDragging = true;
                                    },
                                    onDragExited: (details) {
                                      editMessageCubit.isDragging = false;
                                    },
                                    child: Container(
                                        color: FluentTheme.of(context)
                                                .brightness
                                                .isDark
                                            ? FluentTheme.of(context)
                                                .scaffoldBackgroundColor
                                            : FluentTheme.of(context)
                                                .scaffoldBackgroundColor
                                                .withAlpha(255),
                                        child: Center(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Stack(children: [
                                                  LayoutBuilder(builder:
                                                      (BuildContext context,
                                                          BoxConstraints
                                                              constraints) {
                                                    if (constraints.maxWidth <
                                                        1300) {
                                                      return _inputBody(
                                                          editMessageCubit);
                                                    } else {
                                                      return Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            _inputBody(
                                                                editMessageCubit),
                                                            DiscordView(
                                                                width: MediaQuery.of(context).size.width *
                                                                            0.45 <
                                                                        630
                                                                    ? 630
                                                                    : MediaQuery.of(context).size.width * 0.45 <
                                                                            780
                                                                        ? MediaQuery.of(context).size.width *
                                                                            0.45
                                                                        : MediaQuery.of(context).size.width *
                                                                            0.6,
                                                                height: 900,
                                                                text: _controllerText
                                                                    .text,
                                                                files: editMessageCubit
                                                                    .files
                                                                    .where((file) =>
                                                                        ![
                                                                          'jpeg',
                                                                          'png',
                                                                          'webp',
                                                                          'gif',
                                                                          'jpg'
                                                                        ].contains(file
                                                                            .path
                                                                            .split('.')
                                                                            .last))
                                                                    .toList(),
                                                                images: editMessageCubit.files
                                                                    .where(
                                                                      (file) => [
                                                                        'jpeg',
                                                                        'png',
                                                                        'webp',
                                                                        'gif',
                                                                        'jpg'
                                                                      ].contains(file
                                                                          .path
                                                                          .split(
                                                                              '.')
                                                                          .last),
                                                                    )
                                                                    .toList())
                                                          ]);
                                                    }
                                                  }),
                                                  editMessageCubit.isDragging
                                                      ? dragZone(
                                                          context,
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height)
                                                      : const SizedBox.shrink()
                                                ]))))))))));
          },
        ));
  }

  Widget _inputBody(EditMessageCubit editMessageCubit) {
    return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView(
          children: [
            InfoLabel(
              label: 'Token',
              child: SizedBox(
                width: 600,
                child: TextBox(
                  obscureText: editMessageCubit.seeToken ? false : true,
                  suffix: editMessageCubit.errorToken
                      ? Text(
                          'Input your token',
                          style: TextStyle(color: Colors.red),
                        )
                      : editMessageCubit.profile.name.isEmpty
                          ? null
                          : Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: FluentTheme.of(context)
                                                    .accentColor),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(16))),
                                        child: Row(children: [
                                          Text(
                                            editMessageCubit.profile.name,
                                            style: editMessageCubit
                                                        .profile.name ==
                                                    'invalid token'
                                                ? TextStyle(color: Colors.red)
                                                : TextStyle(
                                                    color:
                                                        FluentTheme.of(context)
                                                                .brightness
                                                                .isDark
                                                            ? Colors.white
                                                            : Colors.black),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          editMessageCubit.profile.name ==
                                                  'invalid token'
                                              ? const SizedBox.shrink()
                                              : editMessageCubit
                                                      .profile.avatarId.isEmpty
                                                  ? Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                          color: FluentTheme.of(
                                                                  context)
                                                              .accentColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100)),
                                                      child: Image.file(
                                                        File(
                                                            'assets/discord1.png'),
                                                        color: Colors.white,
                                                      ))
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18.0),
                                                      child: FutureBuilder<
                                                          Uint8List>(
                                                        future: editMessageCubit
                                                            .loadAvatar(),
                                                        builder: (context,
                                                                snapshot) =>
                                                            snapshot.hasData
                                                                ? snapshot.data!
                                                                            .length !=
                                                                        1
                                                                    ? Image
                                                                        .memory(
                                                                        snapshot
                                                                            .data!,
                                                                        width:
                                                                            25,
                                                                        height:
                                                                            25,
                                                                      )
                                                                    : const Icon(
                                                                        FluentIcons
                                                                            .warning)
                                                                : const SizedBox(
                                                                    width: 25,
                                                                    height: 25,
                                                                    child:
                                                                        ProgressRing(
                                                                      strokeWidth:
                                                                          3,
                                                                    ),
                                                                  ),
                                                      )),
                                        ]))),
                                IconButton(
                                    icon: Icon(
                                      color:
                                          FluentTheme.of(context).accentColor,
                                      editMessageCubit.seeToken
                                          ? mat.Icons.visibility
                                          : mat.Icons.visibility_off,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      editMessageCubit.seeToken =
                                          !editMessageCubit.seeToken;
                                    })
                              ],
                            ),
                  controller: _controllerToken,
                  expands: false,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InfoLabel(
              label: 'Channel',
              child: SizedBox(
                width: 600,
                child: TextBox(
                  suffix: editMessageCubit.errorChannel
                      ? Text(
                          'Input channel, where you want send message',
                          style: TextStyle(color: Colors.red),
                        )
                      : (editMessageCubit.channel.name.isNotEmpty ||
                              editMessageCubit.channel.id.isEmpty)
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: FlyoutTarget(
                                controller: contextController,
                                child: Button(
                                  style: ButtonStyle(
                                      shape: ButtonState.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              side: BorderSide(
                                                  color: FluentTheme.of(context)
                                                      .accentColor)))),
                                  onPressed: () async {
                                    if (editMessageCubit.profile.name ==
                                        'invalid token') {
                                      null;
                                    } else {
                                      final channel =
                                          await showChannelSelectDialog(context,
                                              editMessageCubit, treeViewKey);
                                      if (channel != null) {
                                        _controllerChannel.text = channel.id;
                                      }
                                    }
                                  },
                                  child: Text(
                                      editMessageCubit.channel.id.isEmpty
                                          ? 'choose channel'
                                          : editMessageCubit.channel.name),
                                ),
                              ))
                          : const SizedBox.shrink(),
                  controller: _controllerChannel,
                  expands: false,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InfoLabel(
              label: 'Text',
              child: SizedBox(
                  width: 600,
                  child: Column(
                    children: [
                      CommandBarCard(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: CommandBar(
                          overflowBehavior: CommandBarOverflowBehavior.clip,
                          isCompact: true,
                          primaryItems: [
                            CommandBarBuilderItem(
                              builder: (context, mode, w) => Tooltip(
                                message: "Bold",
                                child: w,
                              ),
                              wrappedItem: CommandBarButton(
                                icon: const Icon(FluentIcons.bold),
                                onPressed: () => formatText(symbol: "**"),
                              ),
                            ),
                            CommandBarBuilderItem(
                              builder: (context, mode, w) => Tooltip(
                                message: "Italic",
                                child: w,
                              ),
                              wrappedItem: CommandBarButton(
                                icon: const Icon(FluentIcons.italic),
                                onPressed: () => formatText(symbol: "*"),
                              ),
                            ),
                            CommandBarBuilderItem(
                              builder: (context, mode, w) => Tooltip(
                                message: "Code",
                                child: w,
                              ),
                              wrappedItem: CommandBarButton(
                                icon: const Icon(FluentIcons.code),
                                onPressed: () => formatText(symbol: "```"),
                              ),
                            ),
                            CommandBarBuilderItem(
                              builder: (context, mode, w) => Tooltip(
                                message: "Underline",
                                child: w,
                              ),
                              wrappedItem: CommandBarButton(
                                icon: const Icon(FluentIcons.underline_a),
                                onPressed: () => formatText(symbol: "__"),
                              ),
                            ),
                            CommandBarBuilderItem(
                                builder: (context, mode, w) => Tooltip(
                                      message: "Strikethrough",
                                      child: w,
                                    ),
                                wrappedItem: CommandBarButton(
                                  icon: const Icon(FluentIcons.strikethrough),
                                  onPressed: () => formatText(symbol: "~~"),
                                )),
                            CommandBarBuilderItem(
                              builder: (context, mode, w) => Tooltip(
                                message:
                                    "The line at the beginning of the text",
                                child: w,
                              ),
                              wrappedItem: CommandBarButton(
                                icon:
                                    const Icon(FluentIcons.right_double_quote),
                                onPressed: () =>
                                    formatText(symbol: ">", double: false),
                              ),
                            ),
                            const CommandBarSeparator(),
                            CommandBarBuilderItem(
                                builder: (context, mode, w) => Tooltip(
                                      message: "Spoiler",
                                      child: w,
                                    ),
                                wrappedItem: CommandBarButton(
                                  icon: const Icon(FluentIcons.red_eye),
                                  onPressed: () => formatText(symbol: "||"),
                                )),
                            const CommandBarSeparator(),
                            CommandBarBuilderItem(
                                builder: (context, mode, w) => Tooltip(
                                      message: "Header1",
                                      child: w,
                                    ),
                                wrappedItem: CommandBarButton(
                                  icon: const Icon(FluentIcons.header1),
                                  onPressed: () =>
                                      formatText(symbol: "# ", double: false),
                                )),
                            CommandBarBuilderItem(
                                builder: (context, mode, w) => Tooltip(
                                      message: "Header2",
                                      child: w,
                                    ),
                                wrappedItem: CommandBarButton(
                                  icon: const Icon(FluentIcons.header2),
                                  onPressed: () =>
                                      formatText(symbol: "## ", double: false),
                                )),
                            CommandBarBuilderItem(
                                builder: (context, mode, w) => Tooltip(
                                      message: "Header3",
                                      child: w,
                                    ),
                                wrappedItem: CommandBarButton(
                                  icon: const Icon(FluentIcons.header3),
                                  onPressed: () =>
                                      formatText(symbol: "### ", double: false),
                                )),
                          ],
                        ),
                      ),
                      TextBox(
                        suffix: FlyoutTarget(
                            controller: contextController,
                            child: IconButton(
                              icon: Icon(
                                FluentIcons.emoji,
                                color: FluentTheme.of(context).accentColor,
                                size: 20,
                              ),
                              onPressed: () {
                                contextController.showFlyout(
                                    autoModeConfiguration:
                                        FlyoutAutoConfiguration(
                                      preferredMode:
                                          FlyoutPlacementMode.topCenter,
                                    ),
                                    barrierDismissible: false,
                                    dismissOnPointerMoveAway: true,
                                    dismissWithEsc: true,
                                    builder: (context) {
                                      return FlyoutContent(
                                          color: FluentTheme.of(context)
                                              .scaffoldBackgroundColor,
                                          child: SizedBox(
                                            height: 400,
                                            width: 400,
                                            child: EmojiPicker(
                                              textEditingController:
                                                  _controllerText, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                                              config: Config(
                                                height: 256,
                                                checkPlatformCompatibility:
                                                    true,
                                                emojiViewConfig: EmojiViewConfig(
                                                    backgroundColor:
                                                        FluentTheme.of(context)
                                                                .brightness
                                                                .isLight
                                                            ? Colors.white
                                                            : Colors.grey
                                                                .withAlpha(250)
                                                    // Issue: https://github.com/flutter/flutter/issues/28894
                                                    ),
                                                swapCategoryAndBottomBar: false,
                                                categoryViewConfig: CategoryViewConfig(
                                                    indicatorColor:
                                                        FluentTheme.of(context)
                                                            .accentColor
                                                            .withAlpha(100),
                                                    backspaceColor:
                                                        FluentTheme.of(context)
                                                            .accentColor,
                                                    iconColorSelected:
                                                        FluentTheme.of(context)
                                                            .accentColor,
                                                    dividerColor: FluentTheme
                                                            .of(context)
                                                        .scaffoldBackgroundColor,
                                                    backgroundColor: FluentTheme
                                                            .of(context)
                                                        .scaffoldBackgroundColor),
                                                bottomActionBarConfig:
                                                    BottomActionBarConfig(
                                                        enabled: false),
                                              ),
                                            ),
                                          ));
                                    });
                              },
                            )),
                        controller: _controllerText,
                        expands: false,
                        minLines: 1,
                        maxLines: 16,
                        maxLengthEnforcement:
                            MaxLengthEnforcement.truncateAfterCompositionEnds,
                        maxLength: 2000,
                      )
                    ],
                  )),
            ),

            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                InfoLabel(
                  label: 'Repeats',
                  child: SizedBox(
                    width: 290,
                    child: NumberBox(
                      min: 1,
                      max: 999999,
                      mode: SpinButtonPlacementMode.inline,
                      value:
                          widget.message?.repeats ?? editMessageCubit.repeats,
                      onChanged: (value) {
                        editMessageCubit.repeats = value ?? 0;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                InfoLabel(
                  label: 'Timeout',
                  child: SizedBox(
                    width: 290,
                    child: NumberBox(
                      min: 1,
                      max: 999999,
                      mode: SpinButtonPlacementMode.inline,
                      value:
                          widget.message?.timeout ?? editMessageCubit.timeout,
                      placeholder: 'in seconds',
                      onChanged: (value) {
                        editMessageCubit.timeout = value ?? 0;
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                InfoLabel(
                  label: 'Typing imitation',
                  child: SizedBox(
                    width: 290,
                    child: NumberBox(
                      mode: SpinButtonPlacementMode.inline,
                      min: 0,
                      max: 999999,
                      value: widget.message?.typingDelay ??
                          editMessageCubit.typingDelay,
                      onChanged: (value) {
                        editMessageCubit.typingDelay = value ?? 0;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                InfoLabel(
                  label: 'Random delay',
                  child: SizedBox(
                    width: 290,
                    child: NumberBox(
                      mode: SpinButtonPlacementMode.inline,
                      min: 0,
                      max: 999999,
                      value: widget.message?.randomDelay ??
                          editMessageCubit.randomDelay,
                      placeholder: 'in seconds',
                      onChanged: (value) {
                        editMessageCubit.randomDelay = value ?? 0;
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 25,
                  height: 25,
                  child: Checkbox(
                      checked: editMessageCubit.firstTimeout,
                      onChanged: (selected) {
                        editMessageCubit.firstTimeout =
                            !editMessageCubit.firstTimeout;
                      }),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text('send the first message with a delay')
              ],
            ),

            editMessageCubit.files.isNotEmpty
                ? filesBlocks(context, editMessageCubit)
                : const SizedBox(
                    height: 20,
                  ),

            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Button(
                  child: const Text('Add file'),
                  onPressed: () async {
                    await editMessageCubit.addFileEvent();
                  }),
              editMessageCubit.errorLenFiles
                  ? Text(
                      '   You cannot add more than 10 files',
                      style: TextStyle(color: Colors.red),
                    )
                  : const SizedBox.shrink(),
            ]),
            const SizedBox(
              height: 20,
            ),
            MediaQuery.of(context).size.width > 1300
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Expander(
                        header: const Text(
                          'preview of message',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: DiscordView(
                            width: 590,
                            height: 600,
                            text: editMessageCubit.text,
                            files: editMessageCubit.files
                                .where((file) => ![
                                      'jpeg',
                                      'png',
                                      'webp',
                                      'gif',
                                      'jpg'
                                    ].contains(file.path.split('.').last))
                                .toList(),
                            images: editMessageCubit.files
                                .where(
                                  (file) => [
                                    'jpeg',
                                    'png',
                                    'webp',
                                    'gif',
                                    'jpg'
                                  ].contains(file.path.split('.').last),
                                )
                                .toList()))),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilledButton(
                    child: const Text('Save'),
                    onPressed: () async {
                      await editMessageCubit.saveEvent(
                          BlocProvider.of<LocalDataBloc>(context)
                              .state
                              .groups![0]
                              .items);
                    }),
                editMessageCubit.errorSizeFile
                    ? Text(
                        '   The file is too large. The maximum file size is 25MB',
                        style: TextStyle(color: Colors.red),
                      )
                    : editMessageCubit.errorEmptyData
                        ? Text(
                            '   Input text or add files',
                            style: TextStyle(color: Colors.red),
                          )
                        : const SizedBox.shrink(),
              ],
            ),
            //constraints.maxWidth < 600 ? _discordview() : _discordview(),
          ],
        ));
  }

  void formatText({required String symbol, bool double = true}) {
    int min = _controllerText.selection.baseOffset <
            _controllerText.selection.extentOffset
        ? _controllerText.selection.baseOffset
        : _controllerText.selection.extentOffset;
    int max = _controllerText.selection.baseOffset == min
        ? _controllerText.selection.extentOffset
        : _controllerText.selection.baseOffset;
    // debugPrint(_controllerText.selection.toString());
    _controllerText.text = _controllerText.text.replaceRange(
        min,
        max,
        symbol +
            _controllerText.text.substring(min, max) +
            (double ? symbol : ''));
  }
}
