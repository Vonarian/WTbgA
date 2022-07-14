import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

import '../../data_receivers/chat.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      if (!mounted) timer.cancel();
      final data = await GameChat.getChat(id.value);
      id.value = data.id;
      list.add(data);
      list = list.toSet().toList();
      setState(() {});
    });
  }

  final id = ValueNotifier<int>(0);
  List<GameChat> list = [];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final data = list[i];
            Color color = data.enemy ? Colors.red : Colors.blue;
            return ListTile(
              subtitle: Text(list[i].message,
                  style: TextStyle(
                    color: color,
                  )),
              title: Text(list[i].sender, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            );
          }),
    );
  }
}
