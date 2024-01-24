import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/comment.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../backend/database.dart';
import '../models/post.dart';

// ignore: must_be_immutable
class PostPage extends StatefulWidget {
  Post post;
  String? uid;
  PostPage({super.key, required this.post, this.uid});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>
    with SingleTickerProviderStateMixin {
  TextEditingController commentController = TextEditingController();
  RegExp badWords = RegExp(
      """(?<=^|[^а-я])(([уyu]|[нзnz3][аa]|(хитро|не)?[вvwb][зz3]?[ыьъi]|[сsc][ьъ']|(и|[рpr][аa4])[зсzs]ъ?|([оo0][тбtb6]|[пp][оo0][дd9])[ьъ']?|(.\B)+?[оаеиeo])?-?([еёe][бb6](?!о[рй])|и[пб][ае][тц]).*?|([нn][иеаaie]|([дпdp]|[вv][еe3][рpr][тt])[оo0]|[рpr][аa][зсzc3]|[з3z]?[аa]|с(ме)?|[оo0]([тt]|дно)?|апч)?-?[хxh][уuy]([яйиеёюuie]|ли(?!ган)).*?|([вvw][зы3z]|(три|два|четыре)жды|(н|[сc][уuy][кk])[аa])?-?[бb6][лl]([яy](?!(х|ш[кн]|мб)[ауеыио]).*?|[еэe][дтdt][ь']?)|([рp][аa][сзc3z]|[знzn][аa]|[соsc]|[вv][ыi]?|[пp]([еe][рpr][еe]|[рrp][оиioеe]|[оo0][дd])|и[зс]ъ?|[аоao][тt])?[пpn][иеёieu][зz3][дd9].*?|([зz3][аa])?[пp][иеieu][дd][аоеaoe]?[рrp](ну.*?|[оаoa][мm]|([аa][сcs])?([иiu]([лl][иiu])?[нщктлtlsn]ь?)?|([оo](ч[еиei])?|[аa][сcs])?[кk]([оo]й)?|[юu][гg])[ауеыauyei]?|[мm][аa][нnh][дd]([ауеыayueiи]([лl]([иi][сзc3щ])?[ауеыauyei])?|[оo][йi]|[аоao][вvwb][оo](ш|sh)[ь']?([e]?[кk][ауеayue])?|юк(ов|[ауи])?)|[мm][уuy][дd6]([яyаиоaiuo0].*?|[еe]?[нhn]([ьюия'uiya]|ей))|мля([тд]ь)?|лять|([нз]а|по)х|м[ао]л[ао]фь([яию]|[её]й))(?=(\$|[^а-я]))""");
  late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: StreamBuilder<Object>(
            stream: Database().getPostStream(widget.post.id.toString()),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container();
              }
              widget.post.likes = ((snapshot.data as DocumentSnapshot).data()
                  as Map<String, dynamic>)['likes'];
              widget.post.comments = ((snapshot.data as DocumentSnapshot).data()
                  as Map<String, dynamic>)['comments'];
              return Container(
                padding: const EdgeInsets.all(16),
                // decoration: BoxDecoration(
                //     color: Colors.grey.withOpacity(.5),
                //     borderRadius: BorderRadius.circular(20)),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.title,
                          style: context.largeTextTheme(),
                        ),
                        widget.post.attachments.length != 1
                            ? SizedBox(
                                height: context.getHeight() *
                                    .5 *
                                    widget.post.attachments.length /
                                    3,
                                width: context.getWidth(),
                                // child: MasonryGridView.count(
                                //   itemCount: widget.post.attachments.length,
                                //   crossAxisCount: 2,
                                //   mainAxisSpacing: 4,
                                //   crossAxisSpacing: 4,
                                //   itemBuilder: (context, index) =>
                                //       Image.network(widget.post.attachments[index].url),
                                // ),
                                child: Swiper(
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                                shadowColor: Colors.transparent,
                                                surfaceTintColor:
                                                    Colors.transparent,
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: SizedBox(
                                                  width:
                                                      context.getWidth() * .8,
                                                  child: Image.network(
                                                    widget.post
                                                        .attachments[index].url,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ));
                                    },
                                    child: Image.network(
                                      widget.post.attachments[index].url,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  itemWidth: context.getWidth() * .7,
                                  itemCount: widget.post.attachments.length,
                                  pagination: const SwiperPagination(),
                                  layout: SwiperLayout.STACK,
                                  // control: const SwiperControl(),
                                ))
                            : SizedBox(
                                width: context.getWidth(),
                                child: Image.network(
                                  widget.post.attachments[0].url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        Markdown(
                          physics: NeverScrollableScrollPhysics(),
                          onTapLink: (text, href, title) {
                            if (href != null) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text("Attention".tr),
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
                          data: widget.post.description,
                          shrinkWrap: true,
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
                                if (widget.post.likes.contains(widget.uid)) {
                                  Database()
                                      .unlikePost(widget.post, widget.uid!);
                                } else {
                                  Database().likePost(widget.post, widget.uid!);
                                }
                              },
                              child: ScaleTransition(
                                scale: Tween(begin: 0.7, end: 1.0).animate(
                                    CurvedAnimation(
                                        parent: _controller,
                                        curve: Curves.easeOut)),
                                child: widget.post.likes.contains(widget.uid)
                                    ? Icon(Icons.favorite, color: Colors.red)
                                    : Icon(Icons.favorite_outline,
                                        color: Colors.black),
                              ),
                            ),
                            Text(widget.post.likes.length.toString()),
                          ],
                        ),
                        widget.uid != null
                            ? TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                    icon: IconButton(
                                        onPressed: () {
                                          Comment comment = Comment(
                                              id: Random().nextInt(10000000),
                                              content: commentController.text,
                                              creator: widget.uid!,
                                              likes: [],
                                              postDate: DateTime.now(),
                                              replies: []);
                                          if (badWords.hasMatch(
                                              commentController.text)) {
                                            Get.snackbar(
                                                "Attention".tr,
                                                "Your message contains bad words that are prohibited in social network!"
                                                    .tr,
                                                backgroundColor:
                                                    Colors.red.withOpacity(.7));
                                            return;
                                          }

                                          Database().postComment(comment);
                                          Database().addCommentToPost(
                                              widget.post, comment);
                                          commentController.text = '';
                                        },
                                        icon: const Icon(Icons.send)),
                                    hintText: "Write your comment".tr),
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Comments:".tr,
                            style: context.largeTextTheme(),
                          ),
                        ),
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: widget.post.comments.length,
                            itemBuilder: (context, index) {
                              return CommentWidget(
                                  commentId:
                                      widget.post.comments[index].toString());
                            })
                      ]),
                ),
              );
            }));
  }
}
