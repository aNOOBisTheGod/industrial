import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/job.dart';
import 'package:industrial/models/post.dart';
import 'package:industrial/screens/feed-filters.dart';

import '../backend/auth.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Post> posts = [];
  List<Job> jobs = [];
  bool load = false;
  bool postsState = true;

  Future<void> getData() async {
    GetStorage box = GetStorage();
    List storageInterests = box.read('interests') ?? [];
    if (storageInterests.isNotEmpty) {
      print(storageInterests);
      posts = await Database().getPostsWithFilters(storageInterests);
    } else {
      posts = await Database().getAllPosts();
    }
    jobs = await Database().getAllJobs();
    print(jobs);
    setState(() {
      load = true;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  List<Widget> feedHistory() {
    if (postsState) {
      return posts
          .map((e) => PostWidget(
              postId: e.id,
              key: ObjectKey(Random().nextInt(1000000)),
              uid: Auth().currentUser != null ? Auth().currentUser!.uid : null))
          .toList()
          .reversed
          .toList();
    } else {
      return jobs
          .map((e) => JobWidget(
              jobId: e.id,
              key: ObjectKey(Random().nextInt(1000000)),
              uid: Auth().currentUser != null ? Auth().currentUser!.uid : null))
          .toList()
          .reversed
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !load
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your feed".tr,
                            style: context.largeTextTheme(),
                          ),
                          IconButton(
                              onPressed: () async {
                                Get.to(FeedFilters(),
                                        transition: Transition.fadeIn)!
                                    .then((value) {
                                  setState(() {
                                    load = true;
                                  });
                                  getData();
                                });
                              },
                              icon: Icon(Icons.settings))
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                              style: postsState
                                  ? ElevatedButton.styleFrom(
                                      backgroundColor: context.primaryColor(),
                                    )
                                  : null,
                              onPressed: () {
                                setState(() {
                                  postsState = true;
                                });
                              },
                              child: Text(
                                "Posts".tr,
                                style: postsState
                                    ? TextStyle(color: Colors.white)
                                    : null,
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              style: !postsState
                                  ? ElevatedButton.styleFrom(
                                      backgroundColor: context.primaryColor())
                                  : null,
                              onPressed: () {
                                setState(() {
                                  postsState = false;
                                });
                              },
                              child: Text(
                                "Jobs".tr,
                                style: !postsState
                                    ? TextStyle(color: Colors.white)
                                    : null,
                              )),
                        ],
                      )
                    ],
                  ),
                ),
                ...feedHistory()
              ]),
            ),
    );
  }
}
