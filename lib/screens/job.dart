import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:industrial/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../backend/auth.dart';
import '../backend/database.dart';
import '../models/chat.dart';
import '../models/job.dart';
import '../models/message.dart';

// ignore: must_be_immutable
class JobPage extends StatefulWidget {
  Job job;
  String? uid;
  JobPage({super.key, required this.job, this.uid});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: StreamBuilder<Object>(
            stream: Database().getJobsStream(widget.job.id.toString()),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container();
              }
              return Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.title,
                          style: context.largeTextTheme(),
                        ),
                        Markdown(
                          onTapLink: (text, href, title) {
                            if (href != null) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text("Attention"),
                                        content: Text(
                                            "Do you really want to open link \"@link\" in external browser?"
                                                .trParams({'link': href})),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("No".tr)),
                                          TextButton(
                                              onPressed: () {
                                                launchUrl(Uri.parse(href),
                                                    mode: LaunchMode
                                                        .externalApplication);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Yes".tr)),
                                        ],
                                      ));
                            }
                          },
                          data: widget.job.description,
                          shrinkWrap: true,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    TextEditingController responseController =
                                        TextEditingController();
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          top: 16,
                                          left: 16,
                                          right: 16,
                                          bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom +
                                              20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Center(
                                            child: Text(
                                              "Your response".tr,
                                              style: context.largeTextTheme(),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8.0,
                                          ),
                                          TextField(
                                            controller: responseController,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Write your response here'
                                                        .tr),
                                            autofocus: true,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                            child: ElevatedButton(
                                                onPressed: () async {
                                                  if (Auth().currentUser ==
                                                      null) {
                                                    return;
                                                  }
                                                  if (Auth().currentUser!.uid ==
                                                      widget.job.creatorId) {
                                                    context.pop();
                                                    context.fastSnackBar(SnackBar(
                                                        content: Text(
                                                            "You can't respond to your own jobs!"
                                                                .tr)));

                                                    return;
                                                  }
                                                  Chat? chat = await Database()
                                                      .searchForChat(
                                                          Auth()
                                                              .currentUser!
                                                              .uid,
                                                          widget.job.creatorId);

                                                  if (chat == null) {
                                                    Database().createChat(Chat(
                                                        id: Random().nextInt(
                                                            4294967296),
                                                        users: [],
                                                        messages: [
                                                          Message(
                                                              id: Random()
                                                                  .nextInt(
                                                                      4294967296),
                                                              sender: Auth()
                                                                  .currentUser!
                                                                  .uid,
                                                              content:
                                                                  responseController
                                                                      .text,
                                                              jobId:
                                                                  widget.job.id)
                                                        ]));
                                                  } else {
                                                    Database().postMessage(
                                                        chat.id.toString(),
                                                        Message(
                                                            id: Random()
                                                                .nextInt(
                                                                    4294967296),
                                                            sender: Auth()
                                                                .currentUser!
                                                                .uid,
                                                            content:
                                                                responseController
                                                                    .text,
                                                            jobId:
                                                                widget.job.id));
                                                  }
                                                  context.fastSnackBar(SnackBar(
                                                    content: Text(
                                                      "Successful response!".tr,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ));
                                                  context.pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.green,
                                                    backgroundColor:
                                                        Color.fromARGB(255, 245,
                                                            255, 245)),
                                                child: Text(
                                                  "Send".tr,
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                )),
                                          )
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Text("Respond to this job".tr))
                      ]),
                ),
              );
            }));
  }
}
