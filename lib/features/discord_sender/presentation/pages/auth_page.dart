import 'dart:io';
import 'package:discord_sender/features/discord_sender/presentation/bloc/auth/auth_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/auth/auth_event.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/auth/auth_state.dart';
import 'package:discord_sender/features/discord_sender/presentation/widgets/loader.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import '../bloc/theme/theme.dart';
import '../widgets/error_dialog.dart';
import '../widgets/window_buttons.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _controllerKey = TextEditingController();

  @override
  void dispose() {
    _controllerKey.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return _authbuilder(context);
  }

  Widget _authbuilder(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
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
        ),
        content: ScaffoldPage(
            content:
                BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
          if (state is NotValidLicense) {
            showErrorDialog(context, state.errorMessage!, 'Login error');
          } else if (state is ValidLicense) {
            context.go('/');
          }
        }, builder: (context, state) {
          if (state is StartLicenseState) {
            return const Loader();
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: kOneLineTileHeight,
                  child: ShaderMask(
                      shaderCallback: (rect) {
                        final color = appTheme.color.defaultBrushFor(
                          FluentTheme.of(context).brightness,
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
                        width: 600,
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Enter key',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 200),
                  child: TextBox(
                    controller: _controllerKey,
                  ),
                ),
                FilledButton(
                    child: const Text('login'),
                    onPressed: () async {
                      BlocProvider.of<AuthBloc>(context)
                          .add(CheckLicense(key: _controllerKey.text.trim()));
                    })
              ],
            ),
          );
        })));
  }
}
