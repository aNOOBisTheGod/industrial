import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/screens/welcome/crypto.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: double.infinity,
          child: Image.asset(
            "assets/images/welcome/about.jpg",
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          bottom: 200,
          left: 40,
          right: 80,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white.withOpacity(.3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What are we',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Idustrial is a brand new social network where you can communicate with people, respond to their professional activity, hire them and pay with crypto!",
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          bottom: 100,
          right: 40,
          child: Align(
            alignment: Alignment.bottomRight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: GestureDetector(
                  onTap: () =>
                      Get.to(CryptoPage(), transition: Transition.fadeIn),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    color: Colors.white.withOpacity(.3),
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      size: 50,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
