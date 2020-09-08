import 'package:flutter/foundation.dart';

class ChatModel {
  final String content;
  final String idFrom;
  final String idTo;
  final String timestamp;
  final int type;
  final String documentid;

  ChatModel({
    @required this.content,
    @required this.idFrom,
    @required this.idTo,
    @required this.timestamp,
    @required this.type,
    @required this.documentid,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'idFrom': idFrom,
      'idTo': idTo,
      'timestamp': timestamp,
      'type': type,
    };
  }

  static ChatModel fromMap(Map<String, dynamic> map, String documentId) {
    if (map == null) return null;

    return ChatModel(
        content: map['content'],
        idFrom: map['idFrom'],
        idTo: map['idTo'],
        timestamp: map['timestamp'],
        type: map['type'],
        documentid: documentId);
  }
}
