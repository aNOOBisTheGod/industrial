class Attachment {
  int id;
  String url;

  Attachment({required this.id, required this.url});

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url};
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(id: json['id'], url: json['url']);
  }
}
