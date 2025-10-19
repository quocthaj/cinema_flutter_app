import 'movie.dart';
import 'showtime.dart';

class Ticket {
  final String id;
  final Movie movie;
  final Showtime showtime;
  final List<String> seats;
  final double totalPrice;

  Ticket({
    required this.id,
    required this.movie,
    required this.showtime,
    required this.seats,
    required this.totalPrice,
  });
}
