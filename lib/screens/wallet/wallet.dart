import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/manager.dart';
import 'package:industrial/screens/wallet/create.dart';
import 'package:industrial/screens/wallet/manager.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  WalletManager manager = WalletManager();
  double balance = 0.0;
  String address = '';
  TextEditingController receiverController = TextEditingController();
  TextEditingController amountConroller = TextEditingController();
  Future<void> getData() async {
    manager.loadPrivateKey();
    balance = await manager.getBalance();
    address = (await manager.getPublicKey(manager.privateKey!)).toString();
    setState(() {});
  }

  @override
  void initState() {
    getData();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(children: [
                  Text("Your balance: " + balance.toString() + ' ETH'),
                  Text("Wallet address: " + address.toString()),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                                  padding: EdgeInsets.all(20),
                                  width: double.infinity,
                                  child: Column(children: [
                                    Text(
                                      'Share your wallet',
                                      style: context.largeTextTheme(),
                                    ),
                                    QrImageView(
                                      data: address.toString(),
                                      version: QrVersions.auto,
                                      size: MediaQuery.of(context).size.width *
                                          .5,
                                      eyeStyle:
                                          QrEyeStyle(color: Colors.blueGrey),
                                      dataModuleStyle: QrDataModuleStyle(
                                          color: Colors.blueGrey,
                                          dataModuleShape:
                                              QrDataModuleShape.circle),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      width: context.getWidth() * .8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .6,
                                              child: Text(address.toString())),
                                          IconButton(
                                              onPressed: () async {
                                                await Clipboard.setData(
                                                    ClipboardData(
                                                        text: address));
                                              },
                                              icon: const Icon(Icons.copy)),
                                        ],
                                      ),
                                    )
                                  ]),
                                ));
                      },
                      child: Text("Share address")),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                                  padding: EdgeInsets.all(20),
                                  width: double.infinity,
                                  child: Column(children: [
                                    Text(
                                      'Send ETH',
                                      style: context.largeTextTheme(),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    TextField(
                                      controller: amountConroller,
                                      decoration:
                                          InputDecoration(hintText: "Amount"),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextField(
                                      controller: receiverController,
                                      decoration: InputDecoration(
                                          hintText: "Receiver wallet address"),
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          WalletManager manager =
                                              WalletManager();
                                          manager.loadPrivateKey();
                                          manager.sendTransaction(
                                              receiverController.text,
                                              EtherAmount.inWei(BigInt.from(
                                                  double.parse(amountConroller
                                                          .text) *
                                                      pow(10, 18))));
                                        },
                                        child: Text("Send"))
                                  ]),
                                ));
                      },
                      child: Text("Send")),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        launchUrl(Uri.parse('https://itez.com/'),
                            mode: LaunchMode.externalApplication);
                      },
                      child: Text("Buy ETH")),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Get.dialog(AlertDialog(
                          title: Text(
                              "Are you sure you want to create/import new wallet?"
                                  .tr),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text("No".tr)),
                            TextButton(
                                onPressed: () {
                                  WalletManager().removePrivateKey();
                                  Get.off(CreateWalletPage(),
                                      transition: Transition.fadeIn);
                                },
                                child: Text("Yes".tr)),
                          ],
                        ));
                      },
                      child: Text("New wallet"))
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
