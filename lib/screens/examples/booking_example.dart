// lib/screens/examples/booking_example.dart
// File này chỉ để tham khảo, không cần chạy trực tiếp

import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/movie.dart';
import '../../models/showtime.dart';
import '../../models/booking_model.dart';

/// Example: Màn hình chọn phim và đặt vé
class BookingExampleScreen extends StatefulWidget {
  const BookingExampleScreen({super.key});

  @override
  State<BookingExampleScreen> createState() => _BookingExampleScreenState();
}

class _BookingExampleScreenState extends State<BookingExampleScreen> {
  final _firestoreService = FirestoreService();
  String? selectedMovieId;
  String? selectedShowtimeId;
  List<String> selectedSeats = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt vé')),
      body: Column(
        children: [
          // Step 1: Chọn phim
          _buildMovieSelection(),
          
          // Step 2: Chọn lịch chiếu
          if (selectedMovieId != null) _buildShowtimeSelection(),
          
          // Step 3: Chọn ghế
          if (selectedShowtimeId != null) _buildSeatSelection(),
          
          // Step 4: Xác nhận đặt vé
          if (selectedSeats.isNotEmpty) _buildConfirmButton(),
        ],
      ),
    );
  }

  /// Step 1: Hiển thị danh sách phim
  Widget _buildMovieSelection() {
    return Expanded(
      child: StreamBuilder<List<Movie>>(
        stream: _firestoreService.getMoviesByStatus('now_showing'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: Image.network(
                  movie.posterUrl,
                  width: 50,
                  height: 75,
                  fit: BoxFit.cover,
                ),
                title: Text(movie.title),
                subtitle: Text('${movie.genre} • ${movie.duration} phút'),
                trailing: Text('⭐ ${movie.rating}'),
                selected: selectedMovieId == movie.id,
                onTap: () {
                  setState(() {
                    selectedMovieId = movie.id;
                    selectedShowtimeId = null; // Reset
                    selectedSeats = [];
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Step 2: Hiển thị lịch chiếu của phim đã chọn
  Widget _buildShowtimeSelection() {
    return Expanded(
      child: StreamBuilder<List<Showtime>>(
        stream: _firestoreService.getShowtimesByMovie(selectedMovieId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final showtimes = snapshot.data!;
          return ListView.builder(
            itemCount: showtimes.length,
            itemBuilder: (context, index) {
              final showtime = showtimes[index];
              return ListTile(
                title: Text('${showtime.getDate()} - ${showtime.getTime()}'),
                subtitle: Text(
                  'Còn ${showtime.availableSeats} ghế • '
                  '${showtime.basePrice.toInt()}đ - ${showtime.vipPrice.toInt()}đ'
                ),
                selected: selectedShowtimeId == showtime.id,
                onTap: () {
                  setState(() {
                    selectedShowtimeId = showtime.id;
                    selectedSeats = [];
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Step 3: Chọn ghế (simplified)
  Widget _buildSeatSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Chọn ghế (demo)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(10, (index) {
              final seatId = 'A${index + 1}';
              final isSelected = selectedSeats.contains(seatId);
              
              return ChoiceChip(
                label: Text(seatId),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedSeats.add(seatId);
                    } else {
                      selectedSeats.remove(seatId);
                    }
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Step 4: Nút xác nhận đặt vé
  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _confirmBooking,
        child: Text('Đặt vé (${selectedSeats.length} ghế)'),
      ),
    );
  }

  /// Xử lý đặt vé
  Future<void> _confirmBooking() async {
    try {
      // 1. Lấy thông tin showtime
      final showtime = await _firestoreService.getShowtimeById(selectedShowtimeId!);
      if (showtime == null) {
        throw Exception('Không tìm thấy lịch chiếu');
      }

      // 2. Tính tổng tiền (giả sử tất cả ghế là standard)
      final totalPrice = showtime.basePrice * selectedSeats.length;

      // 3. Tạo booking
      final booking = Booking(
        id: '', // Firestore sẽ tự generate
        userId: 'current_user_id', // Thay bằng Firebase Auth currentUser.uid
        showtimeId: selectedShowtimeId!,
        movieId: selectedMovieId!,
        theaterId: showtime.theaterId,
        screenId: showtime.screenId,
        selectedSeats: selectedSeats,
        seatTypes: {
          for (var seat in selectedSeats) seat: 'standard'
        },
        totalPrice: totalPrice,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // 4. Lưu vào Firestore
      final bookingId = await _firestoreService.createBooking(booking);

      // 5. Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đặt vé thành công! ID: $bookingId'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          selectedMovieId = null;
          selectedShowtimeId = null;
          selectedSeats = [];
        });
      }

    } catch (e) {
      // Hiển thị lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ============================================
// EXAMPLE 2: Hiển thị danh sách booking của user
// ============================================

class MyBookingsScreen extends StatelessWidget {
  final String userId = 'current_user_id'; // Thay bằng Firebase Auth
  final _firestoreService = FirestoreService();

  MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vé của tôi')),
      body: StreamBuilder<List<Booking>>(
        stream: _firestoreService.getBookingsByUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Bạn chưa có vé nào'));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Booking #${booking.id.substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ghế: ${booking.seatsString}'),
                      Text('Tổng tiền: ${booking.totalPrice.toInt()}đ'),
                      Text('Trạng thái: ${booking.status}'),
                    ],
                  ),
                  trailing: booking.canCancel()
                      ? TextButton(
                          onPressed: () => _cancelBooking(context, booking.id),
                          child: const Text('Hủy'),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancelBooking(BuildContext context, String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn hủy vé?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.cancelBooking(bookingId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Hủy vé thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// ============================================
// EXAMPLE 3: Search movies
// ============================================

class SearchMoviesExample extends StatefulWidget {
  const SearchMoviesExample({super.key});

  @override
  State<SearchMoviesExample> createState() => _SearchMoviesExampleState();
}

class _SearchMoviesExampleState extends State<SearchMoviesExample> {
  final _firestoreService = FirestoreService();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm phim...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
      body: StreamBuilder<List<Movie>>(
        stream: _firestoreService.getMoviesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter movies by search query
          final movies = snapshot.data!.where((movie) {
            return movie.title.toLowerCase().contains(searchQuery) ||
                   movie.genre.toLowerCase().contains(searchQuery);
          }).toList();

          if (movies.isEmpty) {
            return const Center(child: Text('Không tìm thấy phim'));
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: Image.network(movie.posterUrl, width: 50),
                title: Text(movie.title),
                subtitle: Text(movie.genre),
              );
            },
          );
        },
      ),
    );
  }
}
