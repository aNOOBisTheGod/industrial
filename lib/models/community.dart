import 'package:industrial/models/post.dart';

import 'interest.dart';

class Community {
  int id;
  String name;
  String description;
  List<Post> posts;
  List<Interest> interests;
  Community(
      {required this.id,
      required this.name,
      required this.description,
      required this.posts,
      required this.interests});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "posts": posts.map((e) => e.toJson()),
      "interests": interests.map((e) => e.toJson())
    };
  }

  factory Community.fromJson(json) {
    return Community(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        posts: json['posts'].map((e) => Post.fromJson(e)),
        interests: json['interests'].map((e) => Interest.fromJson(e)));
  }
}
