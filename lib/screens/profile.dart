import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/chat.dart';
import 'package:industrial/screens/add-post.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/post.dart';
import '../models/user.dart' as models;
import '../models/user.dart';
import 'account.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  User user;
  ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Widget> postWidgets = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(AddPostPage(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 200));
        },
        tooltip: "Create post".tr,
        child: Icon(Icons.add),
      ),
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<Object>(
          stream: Database().getUserStream(widget.user.id),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            models.User user = models.User.fromJson(
                (snapshot.data as DocumentSnapshot).data()
                    as Map<String, dynamic>);
            return Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: context.getWidth(),
                              child: ClipPath(
                                clipper: DrawClip(1),
                                child: user.avatarUrl != null
                                    ? Image.network(
                                        user.avatarUrl!,
                                      )
                                    : Image.asset(
                                        'assets/images/no-avatar.png',
                                      ),
                              ),
                            ),
                            ClipPath(
                              clipper: DrawClip(1),
                              child: BackdropFilter(
                                filter: new ImageFilter.blur(
                                    sigmaX: 100.0, sigmaY: 100.0),
                                child: Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                IconButton(
                                    onPressed: () async {
                                      if (Auth().currentUser == null) {
                                        context.fastSnackBar(SnackBar(
                                            content: Text(
                                                "You should sign in your account to message people!"
                                                    .tr)));
                                        return;
                                      }
                                      Chat? currentChat = await Database()
                                          .searchForChat(
                                              Auth().currentUser!.uid,
                                              widget.user.id);
                                      late Chat chat;
                                      if (currentChat == null) {
                                        chat = Chat(
                                            id: Random().nextInt(4294967296),
                                            users: [
                                              Auth().currentUser!.uid,
                                              widget.user.id
                                            ],
                                            messages: []);
                                        Database().createChat(chat);
                                      } else {
                                        chat = currentChat;
                                      }
                                      print(chat);
                                    },
                                    icon: Icon(Icons.chat)),
                                SizedBox(
                                  height: 50,
                                ),
                                Text(
                                  user.nickname,
                                  style: context
                                      .largeTextTheme()
                                      .apply(fontSizeDelta: 15),
                                ),
                                Text(user.name ?? ""),
                                Text(user.surname ?? ""),
                                SizedBox(
                                  height: 20,
                                ),
                                user.avatarUrl == null
                                    ? CircleAvatar(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.white,
                                        radius: context.getWidth() * .2 + 10,
                                        child: CircleAvatar(
                                          radius: context.getWidth() * .2,
                                          child: Image.asset(
                                            'assets/images/no-avatar.png',
                                          ),
                                        ),
                                      )
                                    : CircleAvatar(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.white,
                                        radius: context.getWidth() * .2 + 10,
                                        child: CircleAvatar(
                                          radius: context.getWidth() * .2,
                                          child: ClipOval(
                                            child: Image.network(
                                              user.avatarUrl!,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                        LimitedBox(
                          maxHeight: context.getHeight() * .5,
                          child: Markdown(
                            data: user.description ?? '',
                            shrinkWrap: true,
                          ),
                        ),
                        ...user.posts
                            .map((e) => PostWidget(
                                postId: e,
                                key: ObjectKey(Random().nextInt(1000000)),
                                uid: Auth().currentUser != null
                                    ? Auth().currentUser!.uid
                                    : null))
                            .toList()
                            .reversed,
                      ]),
                ),
              ),
            );
          }),
    );
  }
}
