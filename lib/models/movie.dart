class Movie {
  final String id;
  final String title;
  final String genre;
  final int duration; // phút
  final double rating;
  final String posterUrl;
  final String status; // now_showing | coming_soon
  final String releaseDate;


  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.posterUrl,
    required this.status,
    required this.releaseDate,

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
    };
  }
}
