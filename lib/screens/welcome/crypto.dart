import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:industrial/manager.dart';

class CryptoPage extends StatelessWidget {
  const CryptoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: double.infinity,
          child: Image.asset(
            "assets/images/welcome/crypto.jpg",
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
                        'Cryptocurrency',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Yes, our social network provides built-in crypto wallet where you can store your ETH coin and pay another users with crypto!",
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
                  onTap: () {
                    final box = GetStorage();
                    box.write('welcome', false);
                    Get.to(ManagerScreen(), transition: Transition.fadeIn);
                  },
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
