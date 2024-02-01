import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';

import '../../data_receivers/chat.dart';

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
      if (!mounted) timer.cancel();
      if (!ref.read(provider.inMatchProvider)) return;
      final data = await GameChat.getChat(id.value);
      id.value = data.id;
      _list.add(data);
      _list = _list.toSet().toList();
      setState(() {});
    });
  }

  final id = ValueNotifier<int>(0);
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
