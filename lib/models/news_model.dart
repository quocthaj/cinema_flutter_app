// lib/models/news_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String id;
  final String title;
  final String imageUrl;
  final String content;
  final DateTime startDate;
  final DateTime endDate;
  final String category; // 'promotion' hoặc 'news'
  final bool isActive;
  final DateTime createdAt;
  final String? notes; // Phần lưu ý hiển thị trong khung riêng

  NewsModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.startDate,
    required this.endDate,
    required this.category,
    this.isActive = true,
    required this.createdAt,
    this.notes,
  });

  /// Convert từ Firestore DocumentSnapshot
  factory NewsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewsModel(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      content: data['content'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      category: data['category'] ?? 'news',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      notes: data['notes'],
    );
  }

  /// Convert sang Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'content': content,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'category': category,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      if (notes != null) 'notes': notes,
    };
  }

  /// Copy with method để update
  NewsModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? content,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    String? notes,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      content: content ?? this.content,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  /// Kiểm tra có đang trong thời gian khuyến mãi không
  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(startDate) && 
           now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Format date range
  String get dateRange {
    final start = '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final end = '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    return '$start - $end';
  }
}
