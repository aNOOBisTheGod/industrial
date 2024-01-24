// ignore_for_file: must_be_immutable

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/attachment.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

import '../models/user.dart';
import 'account.dart';

class Controller extends GetxController {
  Rx avatarConroller = Image.network('').obs;

  void setAvatar(Widget avatar) {
    avatarConroller.value = avatar;
    update();
  }
}

class EditProfile extends StatefulWidget {
  User user;
  EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  ImagePicker picker = ImagePicker();
  final Controller controller = Get.put(Controller());
  TextEditingController nickController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    nickController.text = widget.user.nickname;
    nameController.text = widget.user.name ?? '';
    surnameController.text = widget.user.surname ?? '';
    descriptionController.text = widget.user.description ?? '';
    controller.setAvatar(
      widget.user.avatarUrl == null
          ? Image.asset(
              'assets/images/no-avatar.png',
            )
          : Image.network(
              widget.user.avatarUrl!,
            ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    File? pickedFile = null;

    Future<Widget?> _cropImage(image) async {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image!.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
              ]
            : [
                CropAspectRatioPreset.square,
              ],
      );

      if (croppedFile != null) {
        pickedFile = File(croppedFile.path);
        return Image.file(
          File(croppedFile.path),
          fit: BoxFit.fill,
        );
      }
      return null;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                  width: context.getWidth(),
                  child: ClipPath(
                      clipper: DrawClip(1),
                      child: Obx(() => controller.avatarConroller.value))),
              ClipPath(
                clipper: DrawClip(1),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Text(
                    widget.user.nickname,
                    style: context.largeTextTheme().apply(fontSizeDelta: 15),
                  ),
                  Text(widget.user.name ?? ""),
                  Text(widget.user.surname ?? ""),
                  SizedBox(
                    height: 20,
                  ),
                  Obx(() {
                    return GestureDetector(
                        onTap: () async {
                          XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          Widget? croppedImage = await _cropImage(image);
                          if (croppedImage != null) {
                            controller.setAvatar(croppedImage);
                          }
                        },
                        child: CircleAvatar(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white,
                          radius: context.getWidth() * .2 + 10,
                          child: CircleAvatar(
                              radius: context.getWidth() * .2,
                              child: ClipOval(
                                  child: controller.avatarConroller.value)),
                        ));
                  }),
                ],
              ),
              Positioned.fill(
                  child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_left_rounded,
                      size: 30,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
              ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  controller: nickController,
                  decoration: InputDecoration(hintText: "Nickname".tr),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "Name".tr),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: surnameController,
                  decoration: InputDecoration(hintText: "Surname".tr),
                ),
                SizedBox(
                  height: 20,
                ),
                MarkdownAutoPreview(
                  controller: descriptionController,
                  emojiConvert: true,
                  onChanged: (value) => setState(() {}),
                ),
              ],
            ),
          ),
          descriptionController.text != ''
              ? Text(
                  "(Click to edit)".tr,
                  style: context.smallTextTheme(),
                )
              : Container(),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                widget.user.nickname = nickController.text;
                widget.user.name = nameController.text;
                widget.user.surname = surnameController.text;
                widget.user.description = descriptionController.text;
                if (pickedFile != null) {
                  print('setting new avatar up!');
                  Attachment avatar =
                      await Database().postAttachment(pickedFile!);
                  widget.user.avatarUrl = avatar.url;
                }
                Database().editUserData(widget.user);
                print(widget.user.toJson());
                Get.snackbar("Success".tr, "Personal data edited!".tr);
              },
              child: Text("Save".tr))
        ]),
      ),
    );
  }
}
