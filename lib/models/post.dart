// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/manager.dart';
import 'package:industrial/models/user.dart';
import 'package:industrial/screens/post.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'attachment.dart';

class Post {
  int id;
  String creator;
  DateTime postDate;
  String title;
  String description;
  List likes;
  int? community;
  List comments;
  List attachments;
  List? interests;

  Post(
      {required this.id,
      required this.creator,
      required this.postDate,
      required this.likes,
      required this.title,
      required this.description,
      required this.comments,
      required this.interests,
      this.community,
      required this.attachments});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator': creator,
      'postDate': postDate,
      'title': title,
      'description': description,
      'community': community,
      'likes': likes,
      'comments': comments,
      'interests': interests,
      'attachments': attachments.map((e) => e.toJson()),
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        creator: json['creator'],
        postDate: json['postDate'].toDate(),
        title: json['title'],
        description: json['description'],
        community: json['community'],
        likes: json['likes'],
        comments: json['comments'],
        interests: json['interests'],
        attachments:
            json['attachments'].map((e) => Attachment.fromJson(e)).toList());
  }
}

const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class PostWidget extends StatefulWidget {
  int postId;
  String? uid;
  PostWidget({super.key, required this.postId, this.uid});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  Post? post;
  User? creator;
  bool loading = true;
  bool deleted = false;
  late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);

  Future<void> getData() async {
    post = await Database().getPostData(widget.postId);
    creator = await Database().getUserData(post!.creator);
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
                          height: context.getHeight() * .5,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : StreamBuilder<Object>(
                stream: Database().getPostStream(post!.id.toString()),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  }
                  post!.likes = ((snapshot.data as DocumentSnapshot).data()
                      as Map<String, dynamic>)['likes'];
                  if (post != null) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      // decoration: BoxDecoration(
                      //     color: Colors.grey.withOpacity(.5),
                      //     borderRadius: BorderRadius.circular(20)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(),
                            GestureDetector(
                              onTap: () {
                                if (Auth().currentUser == null) {
                                  context
                                      .pushRoute(ManagerScreen(user: creator!));
                                  return;
                                }
                                if (Auth().currentUser!.uid != creator!.id) {
                                  context
                                      .pushRoute(ManagerScreen(user: creator!));
                                }
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        foregroundColor: Colors.transparent,
                                        backgroundColor: Colors.transparent,
                                        radius: 30,
                                        child: creator!.avatarUrl == null
                                            ? Image.asset(
                                                'assets/images/no-avatar.png')
                                            : CircleAvatar(
                                                radius: 25,
                                                child: ClipOval(
                                                    child: Image.network(
                                                        creator!.avatarUrl!)),
                                              ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        creator!.nickname,
                                      )
                                    ],
                                  ),
                                  PopupMenuButton(
                                      // add icon, by default "3 dot" icon
                                      // icon: Icon(Icons.book)
                                      itemBuilder: (context) {
                                    return [
                                      Auth().currentUser != null
                                          ? post!.creator ==
                                                  Auth().currentUser!.uid
                                              ? PopupMenuItem<int>(
                                                  value: 0,
                                                  child: Text("Delete".tr),
                                                )
                                              : PopupMenuItem<int>(
                                                  value: 1,
                                                  child: Text("Report".tr),
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
                                            "Are you sure you want to delete this post?"
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
                                                Database().deletePost(
                                                    post!.id.toString(),
                                                    post!.creator);
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
                            post!.interests != null
                                ? post!.interests!.isNotEmpty
                                    ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: post!.interests!
                                              .map((e) => Text(
                                                    e != post!.interests!.last
                                                        ? e + ', '
                                                        : e,
                                                    style: context
                                                        .smallTextTheme(),
                                                  ))
                                              .toList(),
                                        ),
                                      )
                                    : Container()
                                : Container(),
                            Text(
                              post!.title,
                              style: context.largeTextTheme(),
                            ),
                            post!.attachments.length != 1
                                ? SizedBox(
                                    height: context.getHeight() *
                                        .5 *
                                        post!.attachments.length /
                                        3,
                                    width: context.getWidth(),
                                    // child: MasonryGridView.count(
                                    //   itemCount: post!.attachments.length,
                                    //   crossAxisCount: 2,
                                    //   mainAxisSpacing: 4,
                                    //   crossAxisSpacing: 4,
                                    //   itemBuilder: (context, index) =>
                                    //       Image.network(post!.attachments[index].url),
                                    // ),
                                    child: Swiper(
                                      itemBuilder: (context, index) =>
                                          GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                    shadowColor:
                                                        Colors.transparent,
                                                    surfaceTintColor:
                                                        Colors.transparent,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: SizedBox(
                                                      width:
                                                          context.getWidth() *
                                                              .8,
                                                      child: Image.network(
                                                        post!.attachments[index]
                                                            .url,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            post!.attachments[index].url,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      itemWidth: context.getWidth() * .7,
                                      itemCount: post!.attachments.length,
                                      pagination: const SwiperPagination(),
                                      layout: SwiperLayout.STACK,
                                      // control: const SwiperControl(),
                                    ))
                                : SizedBox(
                                    width: context.getWidth(),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        post!.attachments[0].url,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
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
                                            builder: (context) => AlertDialog(
                                                  title: Text("Attention".tr),
                                                  content: Text(
                                                      "Do you really want to open link \"@link\" in external browser?"
                                                          .trParams(
                                                              {'link': href})),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("No".tr)),
                                                    TextButton(
                                                        onPressed: () {
                                                          launchUrl(
                                                              Uri.parse(href),
                                                              mode: LaunchMode
                                                                  .externalApplication);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("Yes".tr)),
                                                  ],
                                                ));
                                      }
                                    },
                                    data: post!.description,
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
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _controller
                                        .reverse()
                                        .then((value) => _controller.forward());
                                    if (widget.uid == null) {
                                      return;
                                    }
                                    if (post!.likes.contains(widget.uid)) {
                                      Database().unlikePost(post!, widget.uid!);
                                    } else {
                                      Database().likePost(post!, widget.uid!);
                                    }
                                  },
                                  child: ScaleTransition(
                                    scale: Tween(begin: 0.7, end: 1.0).animate(
                                        CurvedAnimation(
                                            parent: _controller,
                                            curve: Curves.easeOut)),
                                    child: post!.likes.contains(widget.uid)
                                        ? Icon(Icons.favorite,
                                            color: Colors.red)
                                        : Icon(Icons.favorite_outline,
                                            color: Colors.black),
                                  ),
                                ),
                                Text(post!.likes.length.toString()),
                                TextButton(
                                    onPressed: () {
                                      Get.to(
                                          PostPage(
                                            post: post!,
                                            uid: widget.uid,
                                          ),
                                          transition: Transition.fadeIn,
                                          duration: const Duration(
                                              milliseconds: 200));
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Icons.comment),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(post!.comments.length.toString()),
                                      ],
                                    )),
                                // IconButton(
                                //     onPressed: () {}, icon: Icon(Icons.share)),
                                // ElevatedButton(
                                //     onPressed: () {
                                //       Get.to(
                                //           PostPage(
                                //             post: post!,
                                //             uid: widget.uid,
                                //           ),
                                //           transition: Transition.fadeIn,
                                //           duration:
                                //               const Duration(milliseconds: 200));
                                //     },
                                //     child: Text("View post".tr))
                              ],
                            ),
                          ]),
                    );
                  } else {
                    return SizedBox(
                      height: context.getHeight() * .4,
                    );
                  }
                });
  }
}
