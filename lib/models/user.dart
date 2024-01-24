// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/screens/profile.dart';

class User {
  String id;
  String nickname;
  String email;
  String? name;
  String? surname;
  String? avatarUrl;
  String? description;
  List posts;
  List chats;
  List postsLiked;
  List? jobs;
  String? walletAddress;

  User(
      {required this.id,
      required this.nickname,
      required this.email,
      this.name,
      this.avatarUrl,
      this.surname,
      required this.postsLiked,
      required this.posts,
      required this.chats,
      this.jobs,
      this.description,
      this.walletAddress});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'name': name,
      'surname': surname,
      'avatarUrl': avatarUrl,
      'email': email,
      'posts': posts,
      'chats': chats,
      'postsLiked': postsLiked,
      'description': description,
      'walletAddress': walletAddress,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        nickname: json['nickname'],
        email: json['email'],
        name: json['name'],
        surname: json['surname'],
        avatarUrl: json['avatarUrl'],
        posts: json['posts'],
        postsLiked: json['postsLiked'],
        chats: json['chats'],
        description: json['description'],
        walletAddress: json['walletAddress']);
  }

  toWidget() => UserWidget(user: this);
}

class UserPage extends StatefulWidget {
  User user;
  UserPage({super.key, required this.user});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class UserWidget extends StatelessWidget {
  User user;
  UserWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(ProfilePage(user: user),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 200));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(.1),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          SizedBox(
            width: 80,
            height: 80,
            child: ClipOval(
              child: user.avatarUrl == null
                  ? Image.asset('assets/images/no-avatar.png')
                  : Image.network(user.avatarUrl!),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.nickname),
              user.name != null
                  ? Row(
                      children: [
                        Text(
                          user.name!,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          user.surname!,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    )
                  : Container(),
              Text(
                user.id,
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )
            ],
          )
        ]),
      ),
    );
  }
}
