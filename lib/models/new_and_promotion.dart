import 'package:cloud_firestore/cloud_firestore.dart';

class New {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime createdAt;
  final String type; // 'news' hoặc 'promotion'

  New({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.type,
  });

  // 🔹 Firestore → Model
  factory New.fromMap(Map<String, dynamic> data, String documentId) {
    return New(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      type: data['type'] ?? 'news',
    );
  }

  // 🔹 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt), // 🔹 fix: chuyển DateTime → Timestamp
      'type': type,
    };
  }
}
