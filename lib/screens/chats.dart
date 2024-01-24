import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/chat.dart';
import 'package:industrial/models/user.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<Widget> chats = [];

  Future<void> getData() async {
    if (Auth().currentUser == null) {
      return;
    }
    User user = await Database().getUserData(Auth().currentUser!.uid);
    for (var element in user.chats) {
      print(element);
      chats.add(ChatCard(
        chat: await Database().getChatData(element['id'].toString()),
        messageTo: await Database().getUserData(element['users'][0]),
      ));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your chats".tr,
                  style: context.largeTextTheme(),
                ),
                // IconButton(onPressed: () {}, icon: Icon(Icons.settings))
              ],
            ),
          ),
          ...chats
        ],
      ),
    );
  }
}
