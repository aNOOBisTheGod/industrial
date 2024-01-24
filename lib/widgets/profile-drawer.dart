import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/user.dart';
import 'package:industrial/screens/app-settings.dart';
import 'package:industrial/screens/edit-profile.dart';
import 'package:industrial/screens/wallet/manager.dart';
import 'package:industrial/screens/wallet/pin-create.dart';
import 'package:industrial/screens/wallet/pin-enter.dart';

// ignore: must_be_immutable
class ProfileDrawer extends StatefulWidget {
  String? userId;
  ProfileDrawer({super.key, this.userId});

  @override
  State<ProfileDrawer> createState() => ProfileDrawerState();
}

class ProfileDrawerState extends State<ProfileDrawer> {
  User? user;

  Future<void> getData() async {
    print('getting user data');
    user = await Database().getUserData(widget.userId);
    print('got user data!');
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return user == null
        ? Drawer()
        : Drawer(
            child: Padding(
              padding: EdgeInsets.only(
                  top: context.getHeight() * .1, left: 16, right: 16),
              child: Column(children: [
                user!.avatarUrl == null
                    ? CircleAvatar(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white,
                        radius: context.getWidth() * .2 + 10,
                        child: CircleAvatar(
                          radius: context.getWidth() * .2,
                          child: Image.asset(
                            'assets/images/no-avatar.png',
                          ),
                        ),
                      )
                    : CircleAvatar(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white,
                        radius: context.getWidth() * .2 + 10,
                        child: CircleAvatar(
                          radius: context.getWidth() * .2,
                          child: ClipOval(
                            child: Image.network(
                              user!.avatarUrl!,
                            ),
                          ),
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  user!.nickname,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                Text("${user!.name} ${user!.surname}"),
                ListTile(
                  title: Text("Profile settings".tr),
                  leading: Icon(Icons.person),
                  onTap: () {
                    Get.to(
                        EditProfile(
                          user: user!,
                        ),
                        transition: Transition.fadeIn);
                  },
                ),
                ListTile(
                  title: Text("Switch theme mode".tr),
                  leading: Icon(Icons.color_lens),
                  onTap: () {
                    Get.changeThemeMode(
                      Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                    );
                  },
                ),
                ListTile(
                  title: Text("Wallet".tr),
                  leading: Icon(Icons.wallet_rounded),
                  onTap: () {
                    final box = GetStorage();
                    if (box.read('pin') == null) {
                      Get.to(PinCreatePage(), transition: Transition.fadeIn);
                    } else {
                      Get.to(PinEnterPage());
                    }
                  },
                ),
                ListTile(
                  title: Text("App settings".tr),
                  leading: Icon(Icons.settings),
                  onTap: () {
                    Get.to(AppSettings(), transition: Transition.fadeIn);
                  },
                ),
                ListTile(
                  title: Text("Log out".tr),
                  leading: Icon(Icons.logout),
                  onTap: () {
                    GetStorage().remove('pin');
                    Auth().signOut();
                    WalletManager().removePrivateKey();
                  },
                ),
              ]),
            ),
          );
  }
}
