// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/backend/auth.dart';
import 'package:industrial/backend/database.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/models/job.dart';
import 'package:industrial/screens/job.dart';
import 'package:industrial/screens/wallet/manager.dart';
import 'package:web3dart/web3dart.dart';

class Message {
  int id;
  String sender;
  String content;
  int? jobId;
  String? walletAddress;
  double? moneyAmount;

  Message(
      {required this.id,
      required this.sender,
      required this.content,
      this.walletAddress,
      this.moneyAmount,
      this.jobId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'content': content,
      'jobId': jobId,
      'walletAddress': walletAddress,
      'moneyAmount': moneyAmount
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        id: json['id'],
        sender: json['sender'],
        content: json['content'],
        jobId: json['jobId'],
        walletAddress: json['walletAddress'],
        moneyAmount: json['moneyAmount']);
  }
}

class MessageWidget extends StatelessWidget {
  Message message;
  MessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
      child: Auth().currentUser!.uid == message.sender
          ? Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).brightness == Brightness.light
                        ? context.primaryColor().withOpacity(.5)
                        : Colors.pink.withOpacity(.3)),
                constraints: BoxConstraints(maxWidth: context.getWidth() * .8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.content),
                    message.jobId == null
                        ? Container()
                        : ElevatedButton(
                            onPressed: () async {
                              Job job =
                                  await Database().getJobData(message.jobId!);
                              Get.to(JobPage(job: job),
                                  transition: Transition.fadeIn);
                            },
                            child: Text("View linked job".tr)),
                    message.walletAddress == null
                        ? Container()
                        : ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                        padding: EdgeInsets.all(20),
                                        width: double.infinity,
                                        child: Column(children: [
                                          Text(
                                            'Sending...',
                                            style: context.largeTextTheme(),
                                          ),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          Text("${message.moneyAmount} ETH"),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text("to ${message.walletAddress!}"),
                                          const SizedBox(
                                            height: 40,
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                WalletManager manager =
                                                    WalletManager();
                                                manager.loadPrivateKey();
                                                manager.sendTransaction(
                                                    message.walletAddress
                                                        .toString(),
                                                    EtherAmount.inWei(
                                                        BigInt.from(message
                                                                .moneyAmount! *
                                                            pow(10, 18))));
                                              },
                                              child: const Text("Send"))
                                        ]),
                                      ));
                            },
                            child: Text("Pay ${message.moneyAmount}"))
                  ],
                ),
              ),
            )
          : Align(
              alignment: Alignment.topLeft,
              child: Container(
                constraints: BoxConstraints(maxWidth: context.getWidth() * .8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[200]
                      : Colors.grey,
                ),
                width: context.getWidth() * .8,
                child: Text(message.content),
              ),
            ),
    );
  }
}
