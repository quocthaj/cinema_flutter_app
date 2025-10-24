import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/theme.dart';
import '../../models/booking_model.dart';
import '../../models/movie.dart';
import '../../models/showtime.dart';
import '../../models/theater_model.dart';
import '../../services/firestore_service.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Check user authentication
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé của tôi'),
        centerTitle: true,
      ),
      body: user == null
          ? _buildLoginPrompt(context)
          : _buildTicketStream(context, user.uid),
    );
  }

  /// ✅ NEW: Login prompt for non-authenticated users
  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 80,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Vui lòng đăng nhập',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Đăng nhập để xem vé đã đặt',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to login screen
              Navigator.pushNamed(context, '/login');
            },
            icon: const Icon(Icons.login),
            label: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  /// ✅ NEW: Stream builder for real-time bookings
  Widget _buildTicketStream(BuildContext context, String userId) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Booking>>(
      stream: firestoreService.getBookingsByUser(userId),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 60, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text('Lỗi: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Trigger rebuild
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        // Empty
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context);
        }

        // Success - display bookings
        final bookings = snapshot.data!;
        return _buildTicketList(context, bookings, firestoreService);
      },
    );
  }

  // Widget khi không có vé
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_activity_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Bạn chưa có vé nào',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy bắt đầu đặt vé và trải nghiệm phim hay!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// ✅ NEW: Ticket list with real bookings
  Widget _buildTicketList(
    BuildContext context,
    List<Booking> bookings,
    FirestoreService firestoreService,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildTicketCard(context, booking, firestoreService);
      },
    );
  }

  /// ✅ NEW: Ticket card with nested data loading
  Widget _buildTicketCard(
    BuildContext context,
    Booking booking,
    FirestoreService firestoreService,
  ) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadBookingDetails(booking, firestoreService),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Container(
              height: 150,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = snapshot.data!;
        final movie = data['movie'] as Movie;
        final showtime = data['showtime'] as Showtime;
        final theater = data['theater'] as Theater;

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Movie poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.posterUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 120,
                            color: AppTheme.cardColor,
                            child: const Icon(
                              Icons.movie_creation_outlined,
                              color: Colors.white54,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.calendar_today,
                            '${showtime.getDate()} - ${showtime.getTime()}',
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow(Icons.theaters, theater.name),
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            Icons.chair,
                            'Ghế: ${booking.seatsString}',
                          ),
                          const SizedBox(height: 4),
                          _buildStatusChip(booking.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng cộng:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${booking.totalPrice.toStringAsFixed(0)} VNĐ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 18,
                          ),
                    ),
                  ],
                ),

                // ✅ Cancel button (if booking can be cancelled)
                if (booking.canCancel()) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelBooking(
                        context,
                        booking,
                        firestoreService,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Hủy vé'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ NEW: Load nested booking details
  Future<Map<String, dynamic>> _loadBookingDetails(
    Booking booking,
    FirestoreService firestoreService,
  ) async {
    final results = await Future.wait([
      firestoreService.getMovieById(booking.movieId),
      firestoreService.getShowtimeById(booking.showtimeId),
      firestoreService.getTheaterById(booking.theaterId),
    ]);

    return {
      'movie': results[0],
      'showtime': results[1],
      'theater': results[2],
    };
  }

  /// ✅ NEW: Booking status badge
  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Chờ xử lý';
        icon = Icons.pending;
        break;
      case 'confirmed':
        color = Colors.green;
        label = 'Đã xác nhận';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Đã hủy';
        icon = Icons.cancel;
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Hoàn thành';
        icon = Icons.done_all;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.info;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  /// ✅ NEW: Cancel booking with confirmation
  Future<void> _cancelBooking(
    BuildContext context,
    Booking booking,
    FirestoreService firestoreService,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            const Text('Xác nhận hủy vé'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc muốn hủy vé này?'),
            const SizedBox(height: 12),
            Text(
              'Ghế: ${booking.seatsString}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Tổng: ${booking.totalPrice.toStringAsFixed(0)} VNĐ'),
            const SizedBox(height: 12),
            Text(
              'Lưu ý: Bạn có thể không được hoàn tiền.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    EasyLoading.show(status: 'Đang hủy vé...');

    try {
      await firestoreService.cancelBooking(booking.id);

      EasyLoading.dismiss();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Hủy vé thành công'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi hủy vé: $e'),
            backgroundColor: AppTheme.errorColor,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () =>
                  _cancelBooking(context, booking, firestoreService),
            ),
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondaryColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
