// ignore_for_file: prefer_const_constructors_in_immutables, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/models/user.dart';
import 'package:industrial/screens/chats.dart';
import 'package:industrial/screens/feed.dart';
import 'package:industrial/screens/profile.dart';
import 'package:industrial/screens/search-manager.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'screens/account-manager.dart';

class ManagerScreen extends StatefulWidget {
  int? route;
  User? user;
  ManagerScreen({super.key, this.route, this.user});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  int _bodyIndex = 0;

  @override
  void initState() {
    if (widget.route != null) {
      _bodyIndex = widget.route!;
    }
    super.initState();
  }

  Widget returnBody() {
    if (widget.user != null) {
      var page = ProfilePage(user: widget.user!);

      widget.user = null;
      return page;
    } else if (_bodyIndex == 0) {
      return FeedPage(
        key: ValueKey(_bodyIndex),
      );
    } else if (_bodyIndex == 1) {
      return SearchManager(
        key: ValueKey(_bodyIndex),
      );
    } else if (_bodyIndex == 2) {
      return ChatsPage(
        key: ValueKey(_bodyIndex),
      );
    } else if (_bodyIndex == 3) {
      return AccountPageManager(
        key: ValueKey(_bodyIndex),
      );
    }
    return Container(
      key: ValueKey(_bodyIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: returnBody(),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _bodyIndex,
        onTap: (i) => setState(() => _bodyIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home".tr),
            selectedColor: Colors.purple,
          ),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Search".tr),
            selectedColor: Colors.orange,
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: Icon(Icons.message_rounded),
            title: Text("Chats".tr),
            selectedColor: Colors.pink,
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile".tr),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
