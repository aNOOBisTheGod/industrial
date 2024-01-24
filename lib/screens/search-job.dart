import 'package:flutter/material.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/job.dart';

import '../models/post.dart';

class SearchJobPage extends StatefulWidget {
  const SearchJobPage({super.key});

  @override
  State<SearchJobPage> createState() => _SearchJobPageState();
}

class _SearchJobPageState extends State<SearchJobPage> {
  TextEditingController searchController = TextEditingController();
  List<Job> shownJobs = [];

  void searchForJobs() async {
    shownJobs = await Database().getJobWithName(searchController.text);
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
            onSubmitted: (value) => searchForJobs(),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Here are jobs we have found for you:",
            style: context.largeTextTheme(),
          ),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: shownJobs.length,
              itemBuilder: (context, index) =>
                  PostWidget(postId: shownJobs[index].id))
        ]),
      ),
    );
  }
}
