import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/user.dart';
import 'package:industrial/screens/wallet/manager.dart';
import 'package:industrial/screens/wallet/wallet.dart';

import '../../backend/auth.dart';
import '../../manager.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({super.key});

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  String? mnemonic;
  WalletManager manager = WalletManager();
  bool importWallet = false;
  TextEditingController mnemonicController = TextEditingController();
  Future<void> generateAdress() async {
    mnemonic = await manager.generateMnemonic();
    setState(() {});
  }

  @override
  void initState() {
    generateAdress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet"),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Get.off(ManagerScreen(), transition: Transition.fadeIn);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your mnemonic phrase",
              style: context.largeTextTheme(),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Copy it to safe place and don't show to anyone. This is your access to this wallet!",
              style: context.smallTextTheme(),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: mnemonic == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Text(mnemonic!),
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () async {
                      mnemonic = await manager.generateMnemonic();

                      setState(() {});
                    },
                    icon: Icon(Icons.change_circle_outlined)),
                IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: mnemonic!));
                    },
                    icon: const Icon(Icons.copy)),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    importWallet = !importWallet;
                  });
                },
                child: Text(importWallet ? "Cancel import" : "Import wallet")),
            importWallet
                ? TextField(
                    controller: mnemonicController,
                    decoration:
                        InputDecoration(hintText: "Your mnemonic phrase"),
                  )
                : Container(),
            importWallet
                ? SizedBox(
                    height: 10,
                  )
                : Container(),
            importWallet
                ? ElevatedButton(
                    onPressed: () {
                      if (mnemonicController.text.split(' ').length >= 10) {
                        setState(() {
                          mnemonic = mnemonicController.text;
                        });
                      } else {
                        Get.snackbar(
                            "Attention".tr, "Your mnemonic is incorrect!",
                            backgroundGradient: LinearGradient(
                                colors: [Colors.red, Colors.redAccent]));
                      }
                    },
                    child: Text("Done"))
                : Container(),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (mnemonic == null) {
                    return;
                  }
                  String privateKey = await manager.getPrivateKey(mnemonic!);
                  final publicKey = await manager.getPublicKey(privateKey);
                  Get.to(WalletPage(), transition: Transition.fadeIn);
                  if (Auth().currentUser == null) {
                    return;
                  }
                  User user =
                      await Database().getUserData(Auth().currentUser!.uid);
                  user.walletAddress = publicKey.toString();
                  Database().editUserData(user);
                },
                child: const Text("Create my wallet!")),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
