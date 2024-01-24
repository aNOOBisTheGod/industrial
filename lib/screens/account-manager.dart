import 'package:flutter/material.dart';

import '../backend/auth.dart';
import 'account.dart';
import 'login.dart';

class AccountPageManager extends StatefulWidget {
  const AccountPageManager({super.key});

  @override
  State<AccountPageManager> createState() => _AccountPageManagerState();
}

class _AccountPageManagerState extends State<AccountPageManager> {
  late bool loggedIn;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData && Auth().currentUser != null) {
            return AccountPage();
          } else {
            return LoginPage();
          }
        });
  }
}
