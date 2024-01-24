import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:industrial/extensions.dart';

import '../backend/database.dart';
import '../models/interest.dart';

class FeedFilters extends StatefulWidget {
  FeedFilters({super.key});

  static String _displayStringForOption(Interest option) => option.name;

  @override
  State<FeedFilters> createState() => _FeedFiltersState();
}

class _FeedFiltersState extends State<FeedFilters> {
  List<Interest> interests = [];

  List<Interest> selectedInterests = [];

  TextEditingController interestController = TextEditingController();

  Future<void> getData() async {
    interests = await Database().getAllInterests();
    GetStorage box = GetStorage();
    List storageInterests = box.read('interests') ?? [];
    interests.forEach((element) {
      if (storageInterests.contains(element.id)) {
        selectedInterests.add(element);
      }
    });
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            GetStorage box = GetStorage();
            Get.dialog(AlertDialog(
              title: Text("Save filters?".tr),
              actions: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text("No".tr)),
                TextButton(
                    onPressed: () {
                      Get.back();
                      box.write('interests',
                          selectedInterests.map((e) => e.id).toList());
                    },
                    child: Text("Yes".tr)),
              ],
            )).then((value) {
              Get.back(result: true);
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(children: [
          SizedBox(
            height: 40,
          ),
          Text(
            "Filter your feed".tr,
            style: context.largeTextTheme(),
          ),
          SizedBox(
            height: 20,
          ),
          Autocomplete<Interest>(
            displayStringForOption: FeedFilters._displayStringForOption,
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
                decoration:
                    InputDecoration(hintText: "Insert post interests".tr),
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
                  content: Text("You have already added that interest!".tr),
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
                                    borderRadius: BorderRadius.circular(10),
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
                : Center(child: Text("Please add interests to your post!".tr)),
          ),
        ]),
      ),
    );
  }
}
