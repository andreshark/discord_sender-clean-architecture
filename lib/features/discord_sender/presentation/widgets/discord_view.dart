import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DiscordView extends StatelessWidget {
  const DiscordView(
      {super.key,
      required this.width,
      required this.height,
      required this.text,
      required this.files,
      required this.images});

  final double width;
  final double height;
  final String text;
  final List<File> images;
  final List<File> files;

  Widget formatedText(double width) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
        width: width - 80,
        child: Markdown(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          softLineBreak: true,
          data: text,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: Colors.white, fontSize: 15),
            h1: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
            h2: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
            h3: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
            codeblockDecoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: const Color.fromARGB(255, 43, 45, 49),
              border: Border.all(color: const Color.fromARGB(255, 30, 31, 34)),
            ),
            code: const TextStyle(
                backgroundColor: Color.fromARGB(255, 43, 45, 49),
                color: Colors.white),
            blockquoteDecoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(
                        color: Color.fromARGB(255, 147, 152, 158), width: 3))),
          ),
        ));
  }

  Widget formatedFiles() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 55),
        child: Column(
          children: List<Widget>.generate(
              files.length,
              (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 80,
                      width: 430,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 43, 45, 49),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black, width: 0.2)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Image.file(
                            width: 40,
                            height: 40,
                            File('assets/discord_file.png')),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          files[i].path.split('\\').last.length > 40
                              ? '${files[i].path.split('\\').last.substring(0, 40)}...'
                              : files[i].path.split('\\').last,
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ]),
                    ),
                  )),
        ));
  }

  Widget formatedImages() {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    if (images.length == 1) {
      return SizedBox(
          height: 310,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(images.first),
          ));
    }

    if (images.length == 2) {
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        //padding: const EdgeInsets.all(2.0),
        children: images
            .map((file) => Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
                  ),
                ))
            .toList(),
      );
    }

    if (images.length == 3) {
      return SizedBox(
        child: Row(
          children: [
            SizedBox(
                height: 355,
                width: 355,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    images.first,
                    fit: BoxFit.cover,
                  ),
                )),
            Expanded(
                child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 1,
              //padding: const EdgeInsets.all(2.0),
              children: images
                  .sublist(1)
                  .map((file) => Padding(
                        padding: const EdgeInsets.all(3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ))
                  .toList(),
            )),
          ],
        ),
      );
    }

    int extended = images.length % 3;
    return Column(children: [
      extended != 0 && images.length != 4
          ? extended == 2
              ? GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  //padding: const EdgeInsets.all(2.0),
                  children: images
                      .sublist(0, extended)
                      .map((file) => Padding(
                            padding: const EdgeInsets.all(3),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                file,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ))
                      .toList(),
                )
              : FittedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      images.first,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
          : const SizedBox.shrink(),
      GridView.count(
        shrinkWrap: true,
        crossAxisCount: images.length != 4 ? 3 : 2,
        //padding: const EdgeInsets.all(2.0),
        children: images
            .sublist(images.length != 4 ? extended : 0)
            .map((file) => Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
                  ),
                ))
            .toList(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Container(
      width: width,
      height: height,
      color: const Color(0xff313338),
      child: ListView(
        reverse: true,
        padding: const EdgeInsets.all(15),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.all(4),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: FluentTheme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(100)),
                      child: Image.file(
                        File('assets/discord1.png'),
                        color: Colors.white,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                                text: 'User ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: ' Today, at ${now.hour}:${now.minute}',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 147, 152, 158),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      formatedText(width),
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 50),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  width: 540,
                  child: formatedImages(),
                ),
              ),
              files.isEmpty ? const SizedBox.shrink() : formatedFiles()
            ],
          ),
        ],
      ),
    );
  }
}
