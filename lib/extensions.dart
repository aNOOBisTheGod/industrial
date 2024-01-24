import 'package:flutter/material.dart';

extension Navigation on BuildContext {
  void pushRoute(Widget route) {
    Navigator.of(this).push(MaterialPageRoute(builder: (context) => route));
  }

  void replaceRoute(Widget route) {
    Navigator.of(this)
        .pushReplacement(MaterialPageRoute(builder: (context) => route));
  }

  void pop() {
    Navigator.of(this).pop();
  }
}

extension Themes on BuildContext {
  TextStyle largeTextTheme() {
    return Theme.of(this).textTheme.headlineMedium!;
  }

  TextStyle mediumTextTheme() {
    return Theme.of(this).textTheme.bodyMedium!;
  }

  TextStyle smallTextTheme() {
    return Theme.of(this).textTheme.bodySmall!;
  }

  Color primaryColor() {
    return Theme.of(this).primaryColor;
  }
}

extension Sizes on BuildContext {
  double getHeight() {
    return MediaQuery.of(this).size.height;
  }

  double getWidth() {
    return MediaQuery.of(this).size.width;
  }
}

extension Notifications on BuildContext {
  void fastSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}
