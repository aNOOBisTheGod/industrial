import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/screens/wallet/create.dart';
import 'package:pinput/pinput.dart';

class PinCreatePage extends StatefulWidget {
  PinCreatePage({super.key});

  @override
  State<PinCreatePage> createState() => _PinCreatePageState();
}

class _PinCreatePageState extends State<PinCreatePage> {
  TextEditingController pinController = TextEditingController();

  bool confirm = false;
  String pin = '';

  @override
  Widget build(BuildContext context) {
    List<Color> gradinetColors = [];
    if (Get.isDarkMode) {
      gradinetColors = [
        Color.fromARGB(255, 53, 44, 54),
        Color.fromARGB(255, 83, 46, 87),
      ];
    } else {
      gradinetColors = [Color(0xffdfd3e7), Color(0xfffcfcfb)];
    }
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: gradinetColors, begin: Alignment.topLeft)),
            child: Center(
                child: SizedBox(
              width: context.getWidth() * .6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        !confirm ? "Create PIN" : "Approve PIN",
                        style:
                            context.largeTextTheme().apply(fontSizeDelta: 10),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        !confirm
                            ? "You should create PIN to make your wallet more safe place"
                            : "Please enter your PIN one more time",
                        textAlign: TextAlign.center,
                        style: context.smallTextTheme(),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Pinput(
                        controller: pinController,
                        defaultPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: TextStyle(
                              fontSize: 20,
                              color: Get.isDarkMode
                                  ? Colors.white
                                  : Color.fromRGBO(30, 60, 87, 1),
                              fontWeight: FontWeight.w600),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: TextStyle(
                              fontSize: 20,
                              color: Get.isDarkMode
                                  ? Colors.white
                                  : Color.fromRGBO(30, 60, 87, 1),
                              fontWeight: FontWeight.w600),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 5,
                                  color:
                                      const Color.fromARGB(255, 205, 154, 214))
                            ],
                            color: Colors.white,
                            border: Border.all(
                                color: Color.fromRGBO(234, 239, 243, 1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (s) {
                          if (!confirm) {
                            setState(() {
                              confirm = true;
                              pin = pinController.text;
                              pinController.text = '';
                            });
                          } else {
                            if (pinController.text == pin) {
                              final box = GetStorage();
                              box.write('pin', pin);
                              Get.to(CreateWalletPage());
                            } else {
                              Get.snackbar(
                                  "Attention".tr, "Your PINs are different!");
                            }
                          }
                          return null;
                        },
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        onCompleted: (pin) => print(pin),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.keyboard_arrow_left)),
          ),
        ],
      ),
    );
  }
}
