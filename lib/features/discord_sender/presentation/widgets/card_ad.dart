import 'package:discord_sender/features/discord_sender/presentation/bloc/local_data/local_data_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/local_data/local_data_event.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/message/message_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/message/message_state.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../injection_container.dart';
import '../../../../main.dart';
import '../pages/message_page.dart';

class AdCard extends StatefulWidget {
  const AdCard({
    super.key,
    required this.intKey,
    required this.messageBloc,
    required this.currentTabIndex,
  });

  final int currentTabIndex;
  final int intKey;
  final MessageBloc messageBloc;

  @override
  State<AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> with SingleTickerProviderStateMixin {
  final contextController = FlyoutController();
  final contextAttachKey = GlobalKey();
  late AnimationController controller;
  late Animation<Color?> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      }
    });
    animation = ColorTween(end: null).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    sl<Logger>().d('card close');

    super.dispose();
    // context
    //         .read<LocalDataBloc>()
    //         .state
    //         .messageBlocs![context.read<MessageBloc>().state.message.key] =
    //     MessageBloc(context.read<MessageBloc>().state.message, sl());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
        builder: (BuildContext context, state) {
      if (state is MessageSuccess) {
        BlocProvider.of<LocalDataBloc>(context)
            .add(UpdateRepeats(message: state.message));
      }
      if (state is MessageSuccess || state is MessageFailed) {
        animation =
            ColorTween(end: state is MessageSuccess ? Colors.green : Colors.red)
                .animate(controller);
        controller.forward();
      }
      return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: GestureDetector(
              onSecondaryTapUp: (d) {
                // This calculates the position of the flyout according to the parent navigator
                final targetContext = contextAttachKey.currentContext;
                if (targetContext == null) return;
                final box = targetContext.findRenderObject() as RenderBox;
                final position = box.localToGlobal(
                  d.localPosition,
                  ancestor: Navigator.of(context).context.findRenderObject(),
                );

                contextController.showFlyout(
                    barrierColor: Colors.black.withOpacity(0.0),
                    position: position,
                    navigatorKey: rootNavigatorKey.currentState,
                    builder: (context) {
                      return MenuFlyout(items: [
                        MenuFlyoutSubItem(
                            showHoverDelay: const Duration(microseconds: 250),
                            text: const Text('Add to group'),
                            items: (_) => List<MenuFlyoutItem>.generate(
                                  BlocProvider.of<LocalDataBloc>(context)
                                          .state
                                          .groups!
                                          .length -
                                      1,
                                  (int index) => MenuFlyoutItem(
                                      onPressed: () {
                                        BlocProvider.of<LocalDataBloc>(context)
                                            .add(UpdateGroup(
                                                index: index,
                                                message: state.message));
                                      },
                                      leading: Checkbox(
                                          checked:
                                              BlocProvider.of<LocalDataBloc>(
                                                      context)
                                                  .state
                                                  .groups![index + 1]
                                                  .items
                                                  .contains(state.message.key),
                                          onChanged: (selected) {
                                            BlocProvider.of<LocalDataBloc>(
                                                    context)
                                                .add(UpdateGroup(
                                                    index: index,
                                                    message: state.message));

                                            Flyout.of(_).setState(() {});

                                            if (widget.currentTabIndex ==
                                                index + 1) {
                                              Flyout.of(context).close();
                                            }
                                          }),
                                      text: Text(BlocProvider.of<LocalDataBloc>(
                                              context)
                                          .state
                                          .groups![index + 1]
                                          .name)),
                                ))
                      ]);
                    });
              },
              onTap: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).push(FluentPageRoute(builder: (context) {
                  return MessagePage(
                    message: state.message,
                  );
                }));
              },
              child: FlyoutTarget(
                  key: contextAttachKey,
                  controller: contextController,
                  child: mat.ReorderableDragStartListener(
                      index: widget.intKey,
                      child: AnimatedBuilder(
                          animation: animation,
                          builder: (_, child) {
                            return Card(
                                backgroundColor: animation.value,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(19)),
                                child: SizedBox(
                                    height: 40,
                                    child: Row(
                                      children: [
                                        mat.IconButton(
                                            icon: state is MessageDontWork
                                                ? const Icon(FluentIcons.play)
                                                : const Icon(FluentIcons.pause),
                                            onPressed: () {
                                              changeMessageState(state);
                                            }),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(state.message.name),
                                            Text(state.toString())
                                          ],
                                        ),
                                        Expanded(
                                            child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                              mat.IconButton(
                                                  icon: const Icon(FluentIcons
                                                      .status_circle_error_x),
                                                  onPressed: () {
                                                    removeMessage(state);
                                                  })
                                            ])),
                                      ],
                                    )));
                          })))));
    });
  }

  void changeMessageState(MessageState state) {
    state is MessageDontWork
        ? context.read<MessageBloc>().add(const StartMessage())
        : context.read<MessageBloc>().add(const StopMessage());
  }

  void removeMessage(MessageState state) {
    BlocProvider.of<LocalDataBloc>(context)
        .add(RemoveMessage(message: state.message));
    context.read<MessageBloc>().add(const DeleteMessage());
  }
}
