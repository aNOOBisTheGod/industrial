import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/chat.dart';
import 'package:industrial/models/message.dart';
import 'package:industrial/screens/wallet/manager.dart';

import '../backend/auth.dart';
import '../models/user.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  int chatId;
  User receiver;
  ChatScreen({super.key, required this.chatId, required this.receiver});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  double? nextAmount;
  String? nextAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiver.nickname),
      ),
      body: StreamBuilder(
          stream: Database().getChatStream(widget.chatId.toString()),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            Chat chat = Chat.fromJson((snapshot.data as DocumentSnapshot).data()
                as Map<String, dynamic>);
            return Stack(
              children: [
                Container(
                  child: SingleChildScrollView(
                    child: Column(
                        children: chat.messages
                            .map((e) => MessageWidget(message: e))
                            .toList()),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: context.getWidth(),
                    child: Row(children: [
                      Expanded(
                          child: TextField(
                        maxLines: null,
                        controller: messageController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(hintText: 'Message...'.tr),
                      )),
                      IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  final manager = WalletManager();
                                  manager.loadPrivateKey();
                                  if (manager.privateKey != null) {
                                    addressController.text = (WalletManager()
                                            .getPublicKey(manager.privateKey!))
                                        .toString();
                                  }
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    width: double.infinity,
                                    child: Column(children: [
                                      Text(
                                        "Request payment",
                                        style: context.largeTextTheme(),
                                      ),
                                      TextField(
                                        controller: addressController,
                                        decoration: InputDecoration(
                                            hintText: "Address"),
                                      ),
                                      TextField(
                                        controller: amountController,
                                        decoration: InputDecoration(
                                            hintText: "Amount (ETH)"),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            nextAmount = double.parse(
                                                amountController.text);
                                            nextAddress =
                                                addressController.text;
                                            Navigator.pop(context);
                                          },
                                          child: Text("Done".tr))
                                    ]),
                                  );
                                });
                          },
                          icon: Icon(Icons.wallet)),
                      IconButton(
                          onPressed: () {
                            Message message = Message(
                                id: Random().nextInt(4294967296),
                                sender: Auth().currentUser!.uid,
                                content: messageController.text,
                                moneyAmount: nextAmount,
                                walletAddress: nextAddress);
                            Database()
                                .postMessage(widget.chatId.toString(), message);
                            messageController.text = '';
                            addressController.text = '';
                            amountController.text = '';
                            nextAddress = null;
                            nextAmount = null;
                          },
                          icon: Icon(Icons.send))
                    ]),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
