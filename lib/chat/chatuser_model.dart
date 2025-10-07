class ChatUser {
  final String name;
  final String matriId;
  final String profilePhoto;
  String newMessage;

  ChatUser(
      {required this.name,
      required this.matriId,
      required this.profilePhoto,
      required this.newMessage});

  factory ChatUser.fromJson(Map<String, dynamic> json, String baseUrl) {
    return ChatUser(
        name: (json['first_name'] + " " + json['last_name']) ?? '',
        matriId: json['matri_id'] ?? '',
        profilePhoto: (json['url'] == null || json['url'].isEmpty)
            ? ''
            : ("$baseUrl/" + json['url']),
        newMessage: json['newMessage'].toString());
  }
}

class Messages {
  // final String name;
  // final String matriId;
  // final String profilePhoto;

  final String id;
  final String matri_id_by;
  final String matri_id_to;
  final String message;

  Messages(
      {required this.id,
      required this.matri_id_by,
      required this.matri_id_to,
      required this.message});

  factory Messages.fromJson(Map<String, dynamic> json, String baseUrl) {
    return Messages(
      id: json['id'].toString(),
      matri_id_by: json['matri_id_by'] ?? '',
      matri_id_to: json['matri_id_to'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
