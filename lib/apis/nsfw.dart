import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

Future<bool> checkImage(String imageUrl) async {
  http.Response response = await http.get(Uri.parse(
      'https://api.imagga.com/v2/categories/nsfw_beta?image_url=$imageUrl'));
  log(response.body);
  List data = json.decode(response.body)['result']['categories'];
  for (var i in data) {
    try {
      if (i['confidence'] > 50) {
        if (i['name']['en'] == 'nsfw') {
          return false;
        }
      }
    } catch (_) {}
  }
  return true;
}
