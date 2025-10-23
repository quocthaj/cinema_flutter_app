import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String genre;
  final int duration; // phút
  final double rating;
  final String posterUrl;
  final String status; // now_showing | coming_soon
  final String releaseDate;
  final String description;
  final String trailerUrl; // Thêm trường này để phát trailer

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.posterUrl,
    required this.status,
    required this.releaseDate,
    required this.description,
    required this.trailerUrl,
  });

  /// Hàm Factory: Chuyển đổi một DocumentSnapshot từ Firestore thành một đối tượng Movie.
  /// Đây là phần quan trọng nhất để đọc dữ liệu.
  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? 'Không có mô tả.',
      posterUrl: data['posterUrl'] ?? '',
      trailerUrl: data['trailerUrl'] ?? '',
      genre: data['genre'] ?? 'Chưa phân loại',
      // Dùng (num) để chấp nhận cả int và double từ Firestore, sau đó chuyển đổi
      duration: (data['duration'] ?? 0).toInt(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'coming_soon',
      releaseDate: data['releaseDate'] ?? 'Đang cập nhật',
    );
  }
}
