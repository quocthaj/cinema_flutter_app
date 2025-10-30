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
  final String trailerUrl;
  final String director;
  final String cast;
  final String language;
  final String ageRating;

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
    required this.director,
    required this.cast,
    required this.language,
    required this.ageRating,
  });

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? 'Không có mô tả.',
      posterUrl: data['posterUrl'] ?? '',
      trailerUrl: data['trailerUrl'] ?? '',
      genre: data['genre'] ?? 'Chưa phân loại',
      duration: (data['duration'] ?? 0).toInt(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'coming_soon',
      releaseDate: data['releaseDate'] ?? 'Đang cập nhật',
      director: data['director'] ?? 'Đang cập nhật',
      cast: data['cast'] ?? 'Đang cập nhật',
      language: data['language'] ?? 'Đang cập nhật',
      ageRating: data['ageRating'] ?? 'K',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'genre': genre,
      'duration': duration,
      'rating': rating,
      'posterUrl': posterUrl,
      'status': status,
      'releaseDate': releaseDate,
      'description': description,
      'trailerUrl': trailerUrl,
      'director': director,
      'cast': cast,
      'language': language,
      'ageRating': ageRating,
    };
  }
}
