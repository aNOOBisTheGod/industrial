import 'package:flutter/material.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/user.dart';

class SearchPeoplePage extends StatefulWidget {
  const SearchPeoplePage({super.key});

  @override
  State<SearchPeoplePage> createState() => _SearchPeoplePageState();
}

class _SearchPeoplePageState extends State<SearchPeoplePage> {
  TextEditingController searchController = TextEditingController();
  List<User> users = [];
  List<User> shownUsers = [];

  void searchForUsers() {
    shownUsers = [];
    if (searchController.text == '') {
      return;
    }
    for (var element in users) {
      if (element.nickname.contains(searchController.text)) {
        if (Auth().currentUser != null) {
          if (element.id == Auth().currentUser!.uid) {
            continue;
          }
        }
        shownUsers.add(element);
      }
    }
    setState(() {});
  }

  void getData() {
    Database().getAllUsers().then((value) => users = value);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        SizedBox(
          height: 40,
        ),
        TextField(
          controller: searchController,
          // autofocus: true,
          onChanged: (value) => searchForUsers(),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Here are users we have found:",
          style: context.largeTextTheme(),
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: shownUsers.length,
            itemBuilder: (context, index) =>
                UserWidget(user: shownUsers[index]))
      ]),
    );
  }
}
