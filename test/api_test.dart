import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:industrial/apis/nsfw.dart';

void main() async {
  test("NSFW API test", () async {
    bool value = await checkImage(
        'https://d1e8vjamx1ssze.cloudfront.net/coloratura/images/nsfw/nsfw-header.png');
    print(value);
    log('something');
  });
}
