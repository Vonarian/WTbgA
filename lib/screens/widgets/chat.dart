import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtbgassistant/providers.dart';

class Chat extends ConsumerStatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends ConsumerState<Chat> {
  @override
  Widget build(BuildContext context) {
    var chatSender = ref.read(pullUpNotifProvider.notifier);
    var chatColorFirst = ref.read(chatColorFirstProvider.notifier);
    var chatColorSecond = ref.read(chatColorSecondProvider.notifier);
    var chatMsg = ref.read(chatMsgProvider.notifier);
    var chatPrefix = ref.read(chatPrefixProvider.notifier);

    return Column(
      children: [
        Container(
            alignment: Alignment.topCenter,
            height: 30,
            child: chatMsg.state != 'No Data'
                ? Text(
                    '${chatSender.state} says:',
                    style: TextStyle(color: chatColorFirst.state),
                  )
                : null),
        Container(
            alignment: Alignment.topLeft,
            height: 40,
            child: chatMsg.state != 'No Data'
                ? ListView(children: [
                    Text(
                      '$chatPrefix $chatMsg',
                      style: TextStyle(color: chatColorSecond.state),
                    )
                  ])
                : null),
      ],
    );
  }
}
