// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:industrial/extensions.dart';
import 'package:get/get.dart';

class Interest {
  int id;
  String name;
  String description;

  Interest({
    required this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Interest.fromJson(json) {
    return Interest(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Widget toWidget() {
    return InterestWidget(interest: this);
  }
}

class InterestWidget extends StatelessWidget {
  Interest interest;
  InterestWidget({super.key, required this.interest});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(DetailedInterestScreen(interest: interest),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 200));
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: context.primaryColor(), width: 2),
            borderRadius: BorderRadius.circular(10)),
        child: Text(interest.name),
      ),
    );
  }
}

class DetailedInterestScreen extends StatelessWidget {
  Interest interest;
  DetailedInterestScreen({super.key, required this.interest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            interest.name,
            style: context.largeTextTheme(),
          ),
          const SizedBox(
            height: 40,
          ),
          Text(interest.description)
        ]),
      ),
    );
  }
}
