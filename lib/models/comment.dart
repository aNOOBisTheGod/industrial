// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/manager.dart';
import 'package:industrial/models/user.dart';
import 'package:industrial/screens/profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

class Comment {
  int id;
  String content;
  String creator;
  DateTime postDate;
  List likes;
  List replies;

  Comment(
      {required this.id,
      required this.content,
      required this.creator,
      required this.likes,
      required this.postDate,
      required this.replies});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'creator': creator,
      'likes': likes,
      'postDate': postDate.toString(),
      'replies': replies.map((e) => e.toJson()).toList()
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        id: json['id'],
        content: json['content'],
        creator: json['creator'],
        likes: json['likes'],
        postDate: DateTime.parse(json['postDate']),
        replies: json['replies'].map((e) => Comment.fromJson(e)).toList());
  }
}

class CommentWidget extends StatefulWidget {
  String commentId;
  CommentWidget({super.key, required this.commentId});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  Comment? comment;
  User? author;

  Future<void> getData() async {
    comment = await Database().getCommentData(widget.commentId);

    author = await Database().getUserData(comment!.creator);
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return comment == null
        ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                ClipOval(
                  child: Shimmer.fromColors(
                    baseColor: Colors.black12,
                    highlightColor: Colors.black38,
                    child: SizedBox(
                      width: context.getWidth() * .2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: Colors.white,
                          height: context.getHeight() * .1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
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
            ),
          )
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  GestureDetector(
                    onTap: () {
                      if (Auth().currentUser != null) {
                        if (Auth().currentUser!.uid == author!.id) {
                          context.replaceRoute(ManagerScreen(
                            route: 3,
                          ));
                          return;
                        }
                      }
                      Get.to(ProfilePage(user: author!),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 200));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        author!.avatarUrl != null
                            ? CircleAvatar(
                                radius: 30,
                                child: ClipOval(
                                    child: Image.network(author!.avatarUrl!)))
                            : CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                    child: Image.asset(
                                        'assets/images/no-avatar.png'))),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    width: context.getWidth() * .6,
                    child: Text(
                      comment!.content,
                    ),
                  )
                ]),
              ),
              Container(
                color: Colors.grey,
                height: 1,
                width: context.getWidth() * .8,
              ),
            ],
          );
  }
}
