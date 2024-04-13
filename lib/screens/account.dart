import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/screens/add-post.dart';
import 'package:industrial/widgets/profile-drawer.dart';

import '../backend/auth.dart';
import '../models/post.dart';
import '../models/user.dart' as models;

class DrawClip extends CustomClipper<Path> {
  double move = 0;
  double slice = pi;
  DrawClip(this.move);
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8);
    double xCenter =
        size.width * 0.5 + (size.width * 0.6 + 1) * sin(move * slice);
    double yCenter = size.height * 0.8 + 69 * cos(move * slice);
    path.quadraticBezierTo(xCenter, yCenter, size.width, size.height * 0.8);

    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<Widget> postWidgets = [];
  models.User? user;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: ProfileDrawer(
        userId: Auth().currentUser!.uid,
      ),
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
          stream: Database().getUserStream(Auth().currentUser!.uid),
          builder: (context, snapshot) {
            print(snapshot.data);
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            models.User user = models.User.fromJson(
                (snapshot.data as DocumentSnapshot).data()
                    as Map<String, dynamic>);

            return SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipPath(
                          clipper: DrawClip(1),
                          child: user.avatarUrl == null
                              ? Image.asset(
                                  'assets/images/no-avatar.png',
                                )
                              : Image.network(user.avatarUrl!),
                        ),
                        ClipPath(
                          clipper: DrawClip(1),
                          child: BackdropFilter(
                            filter: new ImageFilter.blur(
                                sigmaX: 100.0, sigmaY: 100.0),
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.5,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 100,
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
                        Positioned.fill(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: IconButton(
                                    onPressed: () {
                                      _key.currentState!.openDrawer();
                                    },
                                    icon: Icon(Icons.menu)),
                              )),
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
                            uid: user.id))
                        .toList()
                        .reversed,
                  ]),
            );
          }),
    );
  }
}
