import '../models/movie.dart';



final List<Movie> mockMovies = [
  Movie(
    id: "1",
    title: "Tử Chiến Trên Không",
    genre: "Action",
    duration: 118,
    rating: 9.8,
    posterUrl: "lib/images/poster1.jpg",
    status: "now_showing",
    releaseDate: "2025-09-19",

  ),
  Movie(
    id: "2",
    title: "Batman",
    genre: "Action",
    duration: 150,
    rating: 8.5,
    posterUrl: "https://i.imgur.com/BtYH6xD.jpeg",
    status: "coming_soon",
    releaseDate: "2025-11-01",
  ),
  Movie(
    id: "3",
    title: "Avengers: Endgame",
    genre: "Action",
    duration: 180,
    rating: 9.0,
    posterUrl: "https://i.imgur.com/7W5A9nB.jpeg",
    status: "now_showing",
    releaseDate: "2019-04-26",
  ),
];
