import 'package:fluent_ui/fluent_ui.dart';

class CardHighlight extends StatelessWidget {
  const CardHighlight(
      {super.key,
      this.backgroundColor,
      required this.title,
      required this.description,
      this.leading,
      this.trailing,
      this.onPressed});

  final Widget title;
  final Widget description;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        backgroundColor: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        padding: const EdgeInsets.only(bottom: 5, top: 5),
        margin: const EdgeInsets.only(right: 30),
        child: SizedBox(
          width: double.infinity,
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: leading,
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: trailing,
            ),
            title: title,
            subtitle: description,
          ),
        ),
      ),
    );
  }
}
