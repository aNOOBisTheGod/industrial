import 'package:flutter/material.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';

import '../models/post.dart';

class SearchPostPage extends StatefulWidget {
  const SearchPostPage({super.key});

  @override
  State<SearchPostPage> createState() => _SearchPostPageState();
}

class _SearchPostPageState extends State<SearchPostPage> {
  TextEditingController searchController = TextEditingController();
  List<Post> shownPosts = [];

  void searchForPosts() async {
    shownPosts = await Database().getPostWithName(searchController.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 40,
          ),
          TextField(
            controller: searchController,
            // autofocus: true,
            onSubmitted: (value) => searchForPosts(),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Here are posts we have found:",
            style: context.largeTextTheme(),
          ),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: shownPosts.length,
              itemBuilder: (context, index) =>
                  PostWidget(postId: shownPosts[index].id))
        ]),
      ),
    );
  }
}
