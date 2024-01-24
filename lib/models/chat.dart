// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/user.dart';
import 'package:industrial/screens/chat.dart';
import 'package:shimmer/shimmer.dart';

import 'message.dart';

class Chat {
  int id;
  List users;
  List messages;
  Chat({required this.id, required this.users, required this.messages});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'users': users,
      'messages': messages.map((e) => e.toJson()).toList()
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
        id: json['id'],
        users: json['users'],
        messages: json['messages'].map((e) => Message.fromJson(e)).toList());
  }
}

class ChatCard extends StatefulWidget {
  Chat chat;
  User messageTo;

  ChatCard({super.key, required this.chat, required this.messageTo});

  @override
  State<ChatCard> createState() => ChatCardState();
}

class ChatCardState extends State<ChatCard> {
  bool load = false;
  Future<void> getData() async {
    setState(() {
      load = true;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !load
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.black12,
                highlightColor: Colors.black38,
                child: SizedBox(
                  width: context.getWidth() * .2,
                  child: ClipOval(
                    child: Container(
                      color: Colors.white,
                      height: context.getHeight() * .1,
                    ),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.black12,
                highlightColor: Colors.black38,
                child: SizedBox(
                  width: context.getWidth() * .6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.white,
                      height: context.getHeight() * .1,
                    ),
                  ),
                ),
              ),
            ],
          )
        : GestureDetector(
            onTap: () {
              Get.to(
                  ChatScreen(
                    chatId: widget.chat.id,
                    receiver: widget.messageTo,
                  ),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 200));
            },
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        foregroundColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                        radius: 40,
                        child: widget.messageTo.avatarUrl == null
                            ? Image.asset('assets/images/no-avatar.png')
                            : ClipOval(
                                child:
                                    Image.network(widget.messageTo.avatarUrl!)),
                      ),
                      SizedBox(
                        width: context.getWidth() * .7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.messageTo.nickname,
                              style: context.largeTextTheme(),
                            ),
                            widget.chat.messages.length == 0
                                ? Text(
                                    "Start your conversation!".tr,
                                  )
                                : Text(widget.chat.messages.last.content)
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
