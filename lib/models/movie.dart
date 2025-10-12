class Movie {
  final String id;
  final String title;
  final String genre;
  final int duration; // phút
  final double rating;
  final String posterUrl;
  final String status; // now_showing | coming_soon
  final String releaseDate;
  final String description; // ✅ thêm dòng này

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.posterUrl,
    required this.status,
    required this.releaseDate,
    required this.description, // ✅ thêm dòng này
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      genre: json['genre'],
      duration: json['duration'],
      rating: (json['rating'] as num).toDouble(),
      posterUrl: json['posterUrl'],
      status: json['status'],
      releaseDate: json['releaseDate'],
      description: json['description'] ?? "", // ✅ thêm dòng này
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "genre": genre,
      "duration": duration,
      "rating": rating,
      "posterUrl": posterUrl,
      "status": status,
      "releaseDate": releaseDate,
      "description": description, // ✅ thêm dòng này
    };
  }
}
