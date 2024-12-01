import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data_receivers/chat.dart';
import '../../main.dart';

class Chat extends ConsumerStatefulWidget {
  const Chat({super.key});

  @override
  ChatState createState() => ChatState();
}

class ChatState extends ConsumerState<Chat> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!ref.read(provider.inMatchProvider)) return;
      final data = await GameChat.getChat(id);
      if (data != null) {
        id = data.id;
        _list.add(data);
        _list = _list.toSet().toList();
        setState(() {});
      }
    });
  }

  int id = 0;
  List<GameChat> _list = [];

  @override
  Widget build(BuildContext context) {
    return _list.isNotEmpty
        ? ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, i) {
              final data = _list[i];
              Color color = data.enemy ? Colors.red : Colors.blue;
              return ListTile(
                subtitle: Text(_list[i].message,
                    style: TextStyle(
                      color: color,
                    )),
                title: Text(
                  _list[i].sender,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            })
        : const Center(
            child: Text(
              'No Chat to Show!',
            ),
          );
  }
}
