import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/user.dart' as models;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  TextEditingController _mailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _nickController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  bool signUp = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(seconds: 25),
      upperBound: 1,
      lowerBound: -1,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> loginWidgets = [
      SizedBox(
        height: context.getHeight() * .1,
      ),
      Text(
        "Log in".tr,
        style: context.largeTextTheme(),
      ),
      SizedBox(
        height: 50,
      ),
      TextField(
        controller: _mailController,
        decoration: InputDecoration(
            hintText: "Insert your email".tr,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
      const SizedBox(
        height: 20,
      ),
      TextField(
        controller: _passController,
        obscureText: true,
        decoration: InputDecoration(
            hintText: "Insert your password".tr,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
      const SizedBox(
        height: 50,
      ),
      ElevatedButton(
          onPressed: () async {
            Auth auth = Auth();
            bool loggedIn = await auth.signInWithEmailAndPassword(
                email: _mailController.text, password: _passController.text);
            if (!loggedIn) {
              // ignore: use_build_context_synchronously
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Attention'.tr),
                        content: Text(
                            "No user found with credentials like that. Do you want to sign up?"
                                .tr),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("No".tr)),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  signUp = true;
                                });
                              },
                              child: Text("Yes".tr)),
                        ],
                      ));
            }
          },
          child: Text("Log In".tr)),
      ElevatedButton(
          onPressed: () async {
            Auth auth = Auth();
            bool loggedIn = await auth.signInWithEmailAndPassword(
                email: _mailController.text, password: _passController.text);
            if (!loggedIn) {
              // ignore: use_build_context_synchronously
              setState(() {
                signUp = true;
              });
            }
          },
          child: Text("Sign Up".tr)),
      const SizedBox(
        height: 10,
      ),
      Text(
        "OR",
        style: context.largeTextTheme(),
      ),
      TextButton(
        child: Text("Log in with Google".tr),
        onPressed: () {
          Auth().signInWithGoogle();
        },
      ),
      SizedBox(
        height: context.getHeight() * .1,
      )
    ];

    List<Widget> signUpWidgets = [
      SizedBox(
        height: context.getHeight() * .1,
      ),
      Text(
        "Sign up",
        style: context.largeTextTheme(),
      ),
      SizedBox(
        height: 50,
      ),
      TextField(
        controller: _nickController,
        decoration: InputDecoration(
            hintText: "Insert your nickname".tr,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
      const SizedBox(
        height: 20,
      ),
      TextField(
        controller: _nameController,
        decoration: InputDecoration(
            hintText: "Insert your real name".tr,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
      const SizedBox(
        height: 20,
      ),
      TextField(
        controller: _surnameController,
        decoration: InputDecoration(
            hintText: "Insert your real surname".tr,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
      const SizedBox(
        height: 20,
      ),
      TextField(
        controller: _mailController,
        decoration: InputDecoration(
            hintText: "Insert your email".tr,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
      const SizedBox(
        height: 20,
      ),
      TextField(
        controller: _passController,
        obscureText: true,
        decoration: InputDecoration(
            hintText: "Insert your password".tr,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
      const SizedBox(
        height: 50,
      ),
      ElevatedButton(
          onPressed: () async {
            Auth auth = Auth();
            bool loggedIn = await auth.signInWithEmailAndPassword(
                email: _mailController.text, password: _passController.text);
            if (!loggedIn) {
              // ignore: use_build_context_synchronously
              auth
                  .createUserWithEmailAndPassword(
                      email: _mailController.text,
                      password: _passController.text)
                  .whenComplete(() {
                if (auth.currentUser != null) {
                  models.User user = models.User(
                      id: Auth().currentUser!.uid,
                      nickname: _nickController.text,
                      email: _mailController.text,
                      surname: _surnameController.text,
                      name: _nameController.text,
                      postsLiked: [],
                      posts: [],
                      chats: []);
                  Database().addUser(user);
                }
              });
            }
          },
          child: Text("Sign Up".tr)),
      TextButton(
          onPressed: () async {
            Auth auth = Auth();
            bool loggedIn = await auth.signInWithEmailAndPassword(
                email: _mailController.text, password: _passController.text);
            if (!loggedIn) {
              // ignore: use_build_context_synchronously
              setState(() {
                signUp = false;
              });
            }
          },
          child: Text("Back to login page".tr)),
      SizedBox(
        height: context.getHeight() * .1,
      )
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: context.getWidth() * .8,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: signUp ? signUpWidgets : loginWidgets),
          ),
        ),
      ),
    );
  }
}
