import 'dart:io';

import 'package:discord_sender/features/discord_sender/presentation/bloc/edit_message/edit_message_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/edit_message/edit_message_state.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderables/reorderables.dart';

Widget filesBlocks(BuildContext context, EditMessageCubit cubit) {
  void onReorder(
    int oldIndex,
    int newIndex,
  ) {
    File file = cubit.files.removeAt(oldIndex);
    cubit.files = List.from(cubit.files)..insert(newIndex, file);
  }

  return BlocProvider<EditMessageCubit>.value(
      value: cubit,
      child: BlocBuilder<EditMessageCubit, EditMessageState>(
        builder: (context, state) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: 600,
                    child: ReorderableWrap(
                        needsLongPressDraggable: false,
                        spacing: 10,
                        runSpacing: 10,
                        onReorder: onReorder,
                        children: List.generate(state.files.length, (index) {
                          return Card(
                              padding: const EdgeInsets.all(0),
                              child: SizedBox(
                                width: 110,
                                height: 110,
                                child: Stack(children: [
                                  Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ([
                                        'jpeg',
                                        'png',
                                        'webp',
                                        'gif',
                                        'jpg'
                                      ].contains(state.files[index].path
                                              .split('.')
                                              .last))
                                          ? Image.file(
                                              state.files[index],
                                              width: 100,
                                              height: 100,
                                            )
                                          : const Icon(
                                              FluentIcons.page,
                                              size: 100,
                                            )),
                                  Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: [
                                        'jpeg',
                                        'png',
                                        'webp',
                                        'gif',
                                        'jpg'
                                      ].contains(state.files[index].path
                                              .split('.')
                                              .last)
                                          ? const SizedBox.shrink()
                                          : Align(
                                              alignment: Alignment.center,
                                              child: Text(state
                                                          .files[index].path
                                                          .split('\\')
                                                          .last
                                                          .length >
                                                      9
                                                  ? '${state.files[index].path.split('\\').last.substring(0, 7)}...'
                                                  : state.files[index].path
                                                      .split('\\')
                                                      .last))),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: const Icon(FluentIcons.cancel),
                                      onPressed: () {
                                        cubit.files = List.from(state.files)
                                          ..removeAt(index);
                                      },
                                    ),
                                  )
                                ]),
                              ));
                        }))),
                const SizedBox(
                  height: 20,
                ),
              ]);
        },
      ));
}
