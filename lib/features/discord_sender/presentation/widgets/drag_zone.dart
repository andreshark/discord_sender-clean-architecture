import 'package:fluent_ui/fluent_ui.dart';

Widget dragZone(BuildContext context, double width, double height) {
  return SizedBox(
      width: width,
      height: height,
      child: Acrylic(
        luminosityAlpha: 0.4,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        elevation: 6,
        blurAmount: 3,
        tint: FluentTheme.of(context).accentColor,
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            FluentIcons.page_add,
            size: 50,
          ),
          Text(
            'Drag & drop your files',
            style: FluentTheme.of(context).typography.title,
          ),
        ])),
      ));
}
