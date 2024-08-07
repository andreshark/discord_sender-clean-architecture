import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

void showErrorDialog(BuildContext _, String message, String title) async {
  // ignore: unused_local_variable
  final result = await showDialog<String>(
    context: _,
    builder: (context) => ContentDialog(
      title: Text(title),
      content: Linkify(
        onOpen: _onOpen,
        text: message,
      ),
      actions: [
        FilledButton(
          child: const Text('Okey'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

Future<void> _onOpen(LinkableElement link) async {
  if (!await launchUrl(Uri.parse(link.url))) {
    throw Exception('Could not launch ${link.url}');
  }
}
