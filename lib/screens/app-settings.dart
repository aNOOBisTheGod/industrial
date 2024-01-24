import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/extensions.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App settings".tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text(
            "Choose app language".tr,
            style: context.largeTextTheme().apply(fontSizeDelta: 4),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Get.updateLocale(Locale('ru', 'RU'));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Get.isDarkMode ? Colors.black : Colors.white,
                      boxShadow: [
                        Get.locale == Locale('ru', 'RU')
                            ? BoxShadow(blurRadius: 10, color: Colors.pink)
                            : BoxShadow(blurRadius: 0, color: Colors.pink)
                      ]),
                  child: Text(
                    "Русский",
                    style: context.largeTextTheme(),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.updateLocale(Locale('en', 'EN'));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Get.isDarkMode ? Colors.black : Colors.white,
                      boxShadow: [
                        Get.locale == Locale('en', 'EN')
                            ? BoxShadow(blurRadius: 10, color: Colors.pink)
                            : BoxShadow(blurRadius: 0, color: Colors.pink)
                      ]),
                  child: Text(
                    "English",
                    style: context.largeTextTheme(),
                  ),
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
