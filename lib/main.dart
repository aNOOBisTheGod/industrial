import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/manager.dart';
import 'package:industrial/screens/welcome/hello.dart';
import 'package:industrial/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  if (Auth().currentUser == null) {
    Auth().signInAnonymously();
  }

  runApp(const Indusrtial());
}

class Indusrtial extends StatelessWidget {
  const Indusrtial({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/welcome/about.jpg"), context);
    precacheImage(AssetImage("assets/images/welcome/crypto.jpg"), context);
    precacheImage(AssetImage("assets/images/welcome/welcome.jpg"), context);
    final box = GetStorage();
    return GetMaterialApp(
      title: 'Industrial',
      translations: Languages(),
      locale: Locale('en', 'EN'),
      fallbackLocale: const Locale('ru', 'RU'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff2e3d46)),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          bodyLarge: TextStyle(fontSize: 17),
          bodyMedium: TextStyle(fontSize: 17),
          bodySmall: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pinkAccent, brightness: Brightness.dark),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          bodyLarge: TextStyle(fontSize: 17),
          bodyMedium: TextStyle(fontSize: 17),
          bodySmall: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
        ),
      ),
      home: box.read('welcome') ?? true ? WelcomePage() : ManagerScreen(),
    );
  }
}
