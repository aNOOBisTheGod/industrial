import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/attachment.dart';
import 'package:industrial/models/interest.dart';
import 'package:industrial/models/job.dart';
import 'package:industrial/models/post.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController _salaryController = TextEditingController();

  List<File> imageFiles = [];
  List<Interest> interests = [];
  List<Interest> selectedInterests = [];
  TextEditingController interestController = TextEditingController();
  bool postsState = true;
  RegExp badWords = RegExp(
      """(?<=^|[^а-я])(([уyu]|[нзnz3][аa]|(хитро|не)?[вvwb][зz3]?[ыьъi]|[сsc][ьъ']|(и|[рpr][аa4])[зсzs]ъ?|([оo0][тбtb6]|[пp][оo0][дd9])[ьъ']?|(.\B)+?[оаеиeo])?-?([еёe][бb6](?!о[рй])|и[пб][ае][тц]).*?|([нn][иеаaie]|([дпdp]|[вv][еe3][рpr][тt])[оo0]|[рpr][аa][зсzc3]|[з3z]?[аa]|с(ме)?|[оo0]([тt]|дно)?|апч)?-?[хxh][уuy]([яйиеёюuie]|ли(?!ган)).*?|([вvw][зы3z]|(три|два|четыре)жды|(н|[сc][уuy][кk])[аa])?-?[бb6][лl]([яy](?!(х|ш[кн]|мб)[ауеыио]).*?|[еэe][дтdt][ь']?)|([рp][аa][сзc3z]|[знzn][аa]|[соsc]|[вv][ыi]?|[пp]([еe][рpr][еe]|[рrp][оиioеe]|[оo0][дd])|и[зс]ъ?|[аоao][тt])?[пpn][иеёieu][зz3][дd9].*?|([зz3][аa])?[пp][иеieu][дd][аоеaoe]?[рrp](ну.*?|[оаoa][мm]|([аa][сcs])?([иiu]([лl][иiu])?[нщктлtlsn]ь?)?|([оo](ч[еиei])?|[аa][сcs])?[кk]([оo]й)?|[юu][гg])[ауеыauyei]?|[мm][аa][нnh][дd]([ауеыayueiи]([лl]([иi][сзc3щ])?[ауеыauyei])?|[оo][йi]|[аоao][вvwb][оo](ш|sh)[ь']?([e]?[кk][ауеayue])?|юк(ов|[ауи])?)|[мm][уuy][дd6]([яyаиоaiuo0].*?|[еe]?[нhn]([ьюия'uiya]|ей))|мля([тд]ь)?|лять|([нз]а|по)х|м[ао]л[ао]фь([яию]|[её]й))(?=(\$|[^а-я]))""");

  static String _displayStringForOption(Interest option) => option.name;

  _getFromGallery() async {
    ImagePicker picker = ImagePicker();
    List<XFile> pickedFiles = await picker.pickMultiImage();

    setState(() {
      imageFiles = pickedFiles.map((image) => File(image.path)).toList();
    });
  }

  Future<void> getData() async {
    interests = await Database().getAllInterests();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: postsState
          ? FloatingActionButton(
              onPressed: _getFromGallery,
              child: Icon(Icons.add_a_photo),
            )
          : null,
      appBar: AppBar(
        title: Text("Post...".tr),
      ),
      body: SingleChildScrollView(
        child: postsState
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
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
                                "Post".tr,
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
                                "Job".tr,
                                style: !postsState
                                    ? TextStyle(color: Colors.white)
                                    : null,
                              )),
                        ],
                      ),
                      TextField(
                        controller: _titleController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "Insert post title".tr,
                          // errorText: _titleController.text.length < 3
                          //     ? "Your title length must be at least 1 symbol"
                          //     : null
                        ),
                      ),
                      SizedBox(
                        height: imageFiles.length * context.getHeight() * .3,
                        child: ListView.builder(
                            itemCount: imageFiles.length,
                            itemBuilder: (context, index) => Center(
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        imageFiles[index],
                                        width: context.getWidth() * .8,
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              imageFiles.removeAt(index);
                                            });
                                          },
                                          icon: const Icon(Icons.delete))
                                    ],
                                  ),
                                )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // TextField(
                      //   controller: _descriptionController,
                      // ),

                      // Markdown(
                      //   data: _descriptionController.text,
                      //   shrinkWrap: true,
                      // ),

                      MarkdownAutoPreview(
                        hintText: "Insert description".tr,
                        controller: _descriptionController,
                        emojiConvert: true,
                        onChanged: (value) => setState(() {}),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Autocomplete<Interest>(
                        displayStringForOption: _displayStringForOption,
                        optionsMaxHeight: 300,
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted) {
                          interestController = fieldTextEditingController;
                          return TextField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                                hintText: "Insert post interests".tr),
                          );
                        },
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<Interest>.empty();
                          }
                          return interests.where((Interest option) {
                            return option.name
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (Interest selectedInterest) {
                          if (selectedInterests.contains(selectedInterest)) {
                            context.fastSnackBar(SnackBar(
                              content: Text(
                                  "You have already added that interest!".tr),
                              backgroundColor: Colors.red,
                            ));
                          } else {
                            setState(() {
                              selectedInterests.add(selectedInterest);
                            });
                            interestController.text = '';
                          }
                        },
                      ),
                      SizedBox(
                        width: context.getWidth(),
                        height: context.getHeight() * .2,
                        child: selectedInterests.isNotEmpty
                            ? GridView.count(
                                childAspectRatio: 2,
                                padding: const EdgeInsets.all(16),
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                children: selectedInterests
                                    .map((e) => GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedInterests.remove(e);
                                            });
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Get.isDarkMode
                                                    ? Colors.black
                                                    : Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        context.primaryColor(),
                                                    blurRadius: 5,
                                                    offset: const Offset(0,
                                                        0), // Shadow position
                                                  ),
                                                ],
                                              ),
                                              child:
                                                  Center(child: Text(e.name))),
                                        ))
                                    .toList(),
                              )
                            : Center(
                                child: Text(
                                    "Please add interests to your post!".tr)),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (selectedInterests.isNotEmpty &&
                                (imageFiles.isNotEmpty ||
                                    (_titleController.text != '' ||
                                        _descriptionController.text != ''))) {
                              List<Attachment> attachments = [];

                              for (var file in imageFiles) {
                                attachments
                                    .add(await Database().postAttachment(file));
                              }
                              int id = Random().nextInt(4294967296);
                              Post post = Post(
                                  id: id,
                                  creator: Auth().currentUser!.uid,
                                  postDate: DateTime.now(),
                                  likes: [],
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  comments: [],
                                  interests: selectedInterests
                                      .map((e) => e.name)
                                      .toList(),
                                  attachments: attachments);
                              if (badWords.hasMatch(post.title) ||
                                  badWords.hasMatch(post.description)) {
                                Get.snackbar(
                                    "Attention".tr,
                                    "Your post contains bad words that are prohibited in social network!"
                                        .tr,
                                    backgroundColor:
                                        Colors.red.withOpacity(.7));
                                return;
                              }
                              Database()
                                  .addPostToUser(Auth().currentUser!.uid, id);
                              Database().makePost(post);
                              context.pop();
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text("Attention".tr),
                                        content: Text(
                                            "Your post should have at least 1 interest and image or title and description"
                                                .tr),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                context.pop();
                                              },
                                              child: const Text("Ok"))
                                        ],
                                      ));
                            }
                          },
                          child: Text("Post".tr))
                    ]),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
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
                            "Post".tr,
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
                            "Job".tr,
                            style: !postsState
                                ? TextStyle(color: Colors.white)
                                : null,
                          )),
                    ],
                  ),
                  TextField(
                    controller: _titleController,
                    decoration:
                        InputDecoration(hintText: "Insert job title".tr),
                  ),
                  // Markdown(
                  //   data: _descriptionController.text,
                  //   shrinkWrap: true,
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  MarkdownAutoPreview(
                    hintText: "Insert description".tr,
                    controller: _descriptionController,
                    emojiConvert: true,
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: context.getWidth() * .4,
                    child: TextField(
                      controller: _salaryController,
                      decoration: InputDecoration(hintText: "Insert salary".tr),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Autocomplete<Interest>(
                    displayStringForOption: _displayStringForOption,
                    optionsMaxHeight: 300,
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      interestController = fieldTextEditingController;
                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                            hintText: "Insert job interests".tr),
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<Interest>.empty();
                      }
                      return interests.where((Interest option) {
                        return option.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (Interest selectedInterest) {
                      if (selectedInterests.contains(selectedInterest)) {
                        context.fastSnackBar(SnackBar(
                          content:
                              Text("You have already added that interest!".tr),
                          backgroundColor: Colors.red,
                        ));
                      } else {
                        setState(() {
                          selectedInterests.add(selectedInterest);
                        });
                        interestController.text = '';
                      }
                    },
                  ),
                  SizedBox(
                    width: context.getWidth(),
                    height: context.getHeight() * .2,
                    child: selectedInterests.isNotEmpty
                        ? GridView.count(
                            childAspectRatio: 2,
                            padding: const EdgeInsets.all(16),
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: selectedInterests
                                .map((e) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedInterests.remove(e);
                                        });
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Get.isDarkMode
                                                ? Colors.black
                                                : Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: context.primaryColor(),
                                                blurRadius: 5,
                                                offset: const Offset(
                                                    0, 0), // Shadow position
                                              ),
                                            ],
                                          ),
                                          child: Center(child: Text(e.name))),
                                    ))
                                .toList(),
                          )
                        : Center(
                            child:
                                Text("Please add interests to your post!".tr)),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        // List<Attachment> attachments = [];
                        // for (var file in imageFiles) {
                        //   attachments.add(await Database().postAttachment(file));
                        // }
                        int id = Random().nextInt(4294967296);
                        Job job = Job(
                          id: id,
                          creatorId: Auth().currentUser!.uid,
                          description: _descriptionController.text,
                          title: _titleController.text,
                          salary: _salaryController.text,
                          interests:
                              selectedInterests.map((e) => e.id).toList(),
                        );
                        if (badWords.hasMatch(job.title) ||
                            badWords.hasMatch(job.description) ||
                            badWords.hasMatch(job.salary ?? '')) {
                          Get.snackbar(
                              "Attention".tr,
                              "Your job contains bad words that are prohibited in social network!"
                                  .tr,
                              backgroundColor: Colors.red.withOpacity(.7));
                          return;
                        }
                        Database().addJobToUser(Auth().currentUser!.uid, id);
                        Database().makeJob(job);
                        context.pop();
                      },
                      child: Text("Post".tr))
                ]),
              ),
      ),
    );
  }
}
