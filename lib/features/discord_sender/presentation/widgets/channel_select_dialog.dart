import 'dart:io';
import 'dart:typed_data';
import 'package:discord_sender/features/discord_sender/domain/entities/channel.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/edit_message/edit_message_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../../../core/resources/data_state.dart';

Future<ChannelEntity?> showChannelSelectDialog(
    BuildContext context,
    EditMessageCubit editMessageCubit,
    GlobalKey<TreeViewState> treeViewKey) async {
  ChannelEntity channel = editMessageCubit.channel;
  // ignore: unused_local_variable
  return await showDialog<ChannelEntity?>(
      context: context,
      builder: (context) => StatefulBuilder(
            builder: (context, StateSetter setState) {
              return ContentDialog(
                style: ContentDialogThemeData.standard(FluentThemeData(
                    brightness: FluentTheme.of(context).brightness)),
                title: const Text('Channel selection'),
                content: SizedBox(
                    width: 400,
                    height: 140,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                            'Select the server and channel you need through the buttons below'),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                            width: 400,
                            child: DropDownButton(
                                title: channel.guildId.isEmpty
                                    ? const Text('Choose server')
                                    : FutureBuilder(
                                        future: editMessageCubit.guildsInfo(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Row(
                                              children: [
                                                editMessageCubit
                                                            .guilds[channel
                                                                .guildId]!
                                                            .avatar ==
                                                        ''
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                4),
                                                        width: 30,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                            color: FluentTheme
                                                                    .of(context)
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
                                                    : Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100)),
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                            child: FutureBuilder<
                                                                DataState<
                                                                    Uint8List>>(
                                                              future: editMessageCubit.loadGuildIcon(
                                                                  channel
                                                                      .guildId,
                                                                  editMessageCubit
                                                                      .guilds[channel
                                                                          .guildId]!
                                                                      .avatar),
                                                              builder: (context,
                                                                      snapshot) =>
                                                                  snapshot.data
                                                                          is DataSuccess
                                                                      ? Image
                                                                          .memory(
                                                                          snapshot
                                                                              .data!
                                                                              .data!,
                                                                          width:
                                                                              25,
                                                                          height:
                                                                              25,
                                                                        )
                                                                      : const ProgressRing(),
                                                            )),
                                                      ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  editMessageCubit
                                                              .guilds[channel
                                                                  .guildId]!
                                                              .name
                                                              .length >
                                                          35
                                                      ? '${editMessageCubit.guilds[channel.guildId]!.name.substring(0, 35)}...'
                                                      : editMessageCubit
                                                          .guilds[
                                                              channel.guildId]!
                                                          .name,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16),
                                                )
                                              ],
                                            );
                                          } else {
                                            return const SizedBox(
                                              width: 35,
                                              height: 35,
                                              child:
                                                  Center(child: ProgressRing()),
                                            );
                                          }
                                        }),
                                items: [
                                  MenuFlyoutItem(
                                      text: FutureBuilder(
                                          future: editMessageCubit.guildsInfo(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Container(
                                                  width: 300,
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxHeight: 500),
                                                  child: ListView(
                                                    children:
                                                        List<ListTile>.generate(
                                                            editMessageCubit
                                                                .profile
                                                                .guilds
                                                                .length,
                                                            (int index) =>
                                                                ListTile(
                                                                    title: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        editMessageCubit.guilds[editMessageCubit.profile.guilds[index]]!.avatar ==
                                                                                ''
                                                                            ? Container(
                                                                                padding: const EdgeInsets.all(4),
                                                                                width: 40,
                                                                                height: 40,
                                                                                decoration: BoxDecoration(color: FluentTheme.of(context).accentColor, borderRadius: BorderRadius.circular(100)),
                                                                                child: Image.file(
                                                                                  File('assets/discord1.png'),
                                                                                  color: Colors.white,
                                                                                ))
                                                                            : Container(
                                                                                width: 40,
                                                                                height: 40,
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                                                                child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(18.0),
                                                                                    child: FutureBuilder<DataState<Uint8List>>(
                                                                                      future: editMessageCubit.loadGuildIcon(editMessageCubit.profile.guilds[index], editMessageCubit.guilds[editMessageCubit.profile.guilds[index]]!.avatar),
                                                                                      builder: (context, snapshot) => snapshot.hasData
                                                                                          ? snapshot.data is DataSuccess
                                                                                              ? Image.memory(
                                                                                                  snapshot.data!.data!,
                                                                                                  width: 25,
                                                                                                  height: 25,
                                                                                                )
                                                                                              : Image.file(File('assets/discord1.png'))
                                                                                          : const ProgressRing(),
                                                                                    )),
                                                                              ),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        Text(
                                                                          editMessageCubit.guilds[editMessageCubit.profile.guilds[index]]!.name.length > 45
                                                                              ? '${editMessageCubit.guilds[editMessageCubit.profile.guilds[index]]!.name.substring(0, 45)}...'
                                                                              : editMessageCubit.guilds[editMessageCubit.profile.guilds[index]]!.name,
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.w500),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      channel = ChannelEntity(
                                                                          name:
                                                                              '',
                                                                          id:
                                                                              '',
                                                                          guildId: editMessageCubit
                                                                              .profile
                                                                              .guilds[index],
                                                                          type: 0);
                                                                      setState(
                                                                          () {});
                                                                      Flyout.of(
                                                                              context)
                                                                          .close();
                                                                    })),
                                                  ));
                                            } else {
                                              return const SizedBox(
                                                width: 400,
                                                child: Center(
                                                    child: ProgressRing()),
                                              );
                                            }
                                          }),
                                      onPressed: null)
                                ])),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                            width: 400,
                            child: DropDownButton(
                                placement: FlyoutPlacementMode.topCenter,
                                title: channel.name.isEmpty
                                    ? const Text('Choose channel')
                                    : Text(
                                        channel.name.length > 25
                                            ? '${channel.name.substring(0, 25)}...'
                                            : channel.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                disabled:
                                    channel.guildId.isEmpty ? true : false,
                                items: [
                                  MenuFlyoutItem(
                                    text: FutureBuilder<List<TreeViewItem>>(
                                        future: editMessageCubit
                                            .channelsInfo(channel.guildId),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Container(
                                              width: 300,
                                              constraints: const BoxConstraints(
                                                  maxHeight: 600),
                                              child: TreeView(
                                                  key: treeViewKey,
                                                  selectionMode:
                                                      TreeViewSelectionMode
                                                          .none,
                                                  items: snapshot.data
                                                      as List<TreeViewItem>,
                                                  onItemInvoked:
                                                      (item, reason) async {
                                                    ChannelEntity itemChannel =
                                                        item.value;
                                                    if (item.parent != null ||
                                                        itemChannel.type == 0) {
                                                      channel = itemChannel;
                                                      setState(
                                                        () {},
                                                      );
                                                      Flyout.of(context)
                                                          .close();
                                                    }
                                                  }),
                                            );
                                          } else {
                                            return const SizedBox(
                                              width: 400,
                                              child:
                                                  Center(child: ProgressRing()),
                                            );
                                          }
                                        }),
                                    onPressed: () {},
                                  )
                                ]))
                      ],
                    )),
                actions: [
                  Button(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                      // Delete file here
                    },
                  ),
                  FilledButton(
                    child: const Text('Apply'),
                    onPressed: () {
                      Navigator.pop(context, channel);
                    },
                  ),
                ],
              );
            },
          ));
}
