// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/chat.dart';
import 'package:industrial/models/message.dart';
import 'package:industrial/models/user.dart';
import 'package:industrial/screens/job.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../backend/auth.dart';
import '../backend/database.dart';
import '../manager.dart';

class Job {
  int id;
  String creatorId;
  String description;
  String title;
  String? salary;
  List interests;

  Job({
    required this.id,
    required this.creatorId,
    required this.description,
    required this.title,
    required this.interests,
    this.salary,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'creatorId': creatorId,
        'title': title,
        'description': description,
        'salary': salary,
        'interests': interests
      };

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
        id: json['id'],
        creatorId: json['creatorId'],
        description: json['description'],
        title: json['title'],
        salary: json['salary'],
        interests: json['interests']);
  }
}

class JobWidget extends StatefulWidget {
  int jobId;
  String? uid;
  JobWidget({super.key, required this.jobId, this.uid});

  @override
  State<JobWidget> createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidget> {
  Job? job;
  User? creator;
  bool loading = true;
  bool deleted = false;

  Future<void> getData() async {
    job = await Database().getJobData(widget.jobId);
    creator = await Database().getUserData(job!.creatorId);
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return deleted
        ? Container()
        : loading
            ? Column(
                children: [
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.black12,
                    highlightColor: Colors.black38,
                    child: SizedBox(
                      width: context.getWidth() * .9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: Colors.white,
                          height: context.getHeight() * .3,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : StreamBuilder<Object>(
                stream: Database().getJobsStream(job!.id.toString()),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  }
                  return job != null
                      ? GestureDetector(
                          onTap: () {
                            Get.to(JobPage(job: job!));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(),
                                  GestureDetector(
                                    onTap: () {
                                      if (Auth().currentUser == null) {
                                        context.pushRoute(
                                            ManagerScreen(user: creator!));
                                        return;
                                      }
                                      if (Auth().currentUser!.uid !=
                                          creator!.id) {
                                        context.pushRoute(
                                            ManagerScreen(user: creator!));
                                      } else {
                                        Get.to(ManagerScreen(route: 3),
                                            transition: Transition.fadeIn,
                                            duration: const Duration(
                                                milliseconds: 200));
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            ClipOval(
                                              child: CircleAvatar(
                                                foregroundColor:
                                                    Colors.transparent,
                                                backgroundColor:
                                                    Colors.transparent,
                                                radius: 25,
                                                child: creator!.avatarUrl ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/no-avatar.png')
                                                    : Image.network(
                                                        creator!.avatarUrl!),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              creator!.nickname,
                                            ),
                                          ],
                                        ),
                                        PopupMenuButton(
                                            // add icon, by default "3 dot" icon
                                            // icon: Icon(Icons.book)
                                            itemBuilder: (context) {
                                          return [
                                            Auth().currentUser != null
                                                ? job!.creatorId ==
                                                        Auth().currentUser!.uid
                                                    ? PopupMenuItem<int>(
                                                        value: 0,
                                                        child:
                                                            Text("Delete".tr),
                                                      )
                                                    : PopupMenuItem<int>(
                                                        value: 1,
                                                        child:
                                                            Text("Report".tr),
                                                      )
                                                : PopupMenuItem<int>(
                                                    value: 1,
                                                    child: Text("Report".tr),
                                                  ),
                                            PopupMenuItem<int>(
                                              value: 2,
                                              child: Text("Share".tr),
                                            ),
                                          ];
                                        }, onSelected: (value) {
                                          if (value == 0) {
                                            Get.dialog(AlertDialog(
                                              title: Text(
                                                  "Are you sure you want to delete this job?"
                                                      .tr),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: Text("No".tr)),
                                                TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        deleted = true;
                                                      });
                                                      Get.back();
                                                      print('deleting job');
                                                      Database().deleteJob(
                                                          job!.id.toString(),
                                                          job!.creatorId);
                                                    },
                                                    child: Text("Yes".tr)),
                                              ],
                                            )).then((value) {
                                              Get.back(result: true);
                                            });
                                          } else if (value == 1) {
                                            print("reporting post");
                                          } else if (value == 2) {
                                            print("Sharing post");
                                          }
                                        }),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    job!.title,
                                    style: context.largeTextTheme(),
                                  ),
                                  LimitedBox(
                                    maxHeight: 100,
                                    child: Stack(
                                      children: [
                                        Markdown(
                                          onTapLink: (text, href, title) {
                                            if (href != null) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title: Text(
                                                            "Attention".tr),
                                                        content: Text(
                                                            "Do you really want to open link \"@link\" in external browser?"
                                                                .trParams({
                                                          'link': href
                                                        })),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  "No".tr)),
                                                          TextButton(
                                                              onPressed: () {
                                                                launchUrl(
                                                                    Uri.parse(
                                                                        href),
                                                                    mode: LaunchMode
                                                                        .externalApplication);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  "Yes".tr)),
                                                        ],
                                                      ));
                                            }
                                          },
                                          data: job!.description,
                                          shrinkWrap: true,
                                        ),
                                        // Container(
                                        //   constraints: const BoxConstraints(
                                        //     minHeight: 0,
                                        //     maxHeight: 60.0,
                                        //   ),

                                        //   // height: double.infinity,
                                        //   decoration: BoxDecoration(
                                        //       gradient: LinearGradient(
                                        //     begin: Alignment.topCenter,
                                        //     end: Alignment.bottomCenter,
                                        //     colors: [
                                        //       Colors.transparent,
                                        //       Colors.purple.withOpacity(.1),
                                        //     ],
                                        //   )),
                                        // )
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              TextEditingController
                                                  responseController =
                                                  TextEditingController();
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    top: 16,
                                                    left: 16,
                                                    right: 16,
                                                    bottom:
                                                        MediaQuery.of(context)
                                                                .viewInsets
                                                                .bottom +
                                                            20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Center(
                                                      child: Text(
                                                        "Your response".tr,
                                                        style: context
                                                            .largeTextTheme(),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 8.0,
                                                    ),
                                                    TextField(
                                                      controller:
                                                          responseController,
                                                      keyboardType:
                                                          TextInputType
                                                              .multiline,
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
                                                            if (Auth()
                                                                    .currentUser ==
                                                                null) {
                                                              context.fastSnackBar(SnackBar(
                                                                  content: Text(
                                                                      "You should be authorized to respond to jobs"
                                                                          .tr)));
                                                            }
                                                            if (Auth()
                                                                    .currentUser ==
                                                                null) {
                                                              return;
                                                            }
                                                            if (Auth()
                                                                    .currentUser!
                                                                    .uid ==
                                                                job!.creatorId) {
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
                                                                    job!.creatorId);

                                                            if (chat == null) {
                                                              Database().createChat(Chat(
                                                                  id: Random()
                                                                      .nextInt(
                                                                          4294967296),
                                                                  users: [
                                                                    Auth()
                                                                        .currentUser!
                                                                        .uid,
                                                                    job!.creatorId
                                                                  ],
                                                                  messages: [
                                                                    Message(
                                                                        id: Random().nextInt(
                                                                            4294967296),
                                                                        sender: Auth()
                                                                            .currentUser!
                                                                            .uid,
                                                                        content:
                                                                            responseController
                                                                                .text,
                                                                        jobId: job!
                                                                            .id)
                                                                  ]));
                                                            } else {
                                                              Database().postMessage(
                                                                  chat.id
                                                                      .toString(),
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
                                                                      jobId: job!
                                                                          .id));
                                                            }
                                                            context
                                                                .fastSnackBar(
                                                                    SnackBar(
                                                              content: Text(
                                                                "Successful response!"
                                                                    .tr,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
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
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          245,
                                                                          255,
                                                                          245)),
                                                          child: Text(
                                                            "Send".tr,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
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
                        )
                      : SizedBox(
                          height: context.getHeight() * .4,
                        );
                });
  }
}
