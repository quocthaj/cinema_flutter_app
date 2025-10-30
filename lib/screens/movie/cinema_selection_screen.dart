import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/movie.dart';
import '../../models/theater_model.dart';
import '../../models/showtime.dart';
import '../../services/firestore_service.dart';
import '../bookings/booking_screen.dart'; // 🆕 Direct to BookingScreen

/// CinemaSelectionScreen - Movie-First Flow Step 2
/// Hiển thị danh sách rạp đang chiếu phim đã chọn
class CinemaSelectionScreen extends StatefulWidget {
  final Movie movie;

  const CinemaSelectionScreen({
    super.key,
    required this.movie,
  });

  @override
  State<CinemaSelectionScreen> createState() => _CinemaSelectionScreenState();
}

class _CinemaSelectionScreenState extends State<CinemaSelectionScreen> {
  final _firestoreService = FirestoreService();
  
  // Map: theaterId -> List<Showtime>
  Map<String, List<Showtime>> _showtimesByTheater = {};
  
  // Map: theaterId -> Theater
  Map<String, Theater> _theaters = {};
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheatersPlayingMovie();
  }

  /// Tải danh sách rạp đang chiếu phim này
  Future<void> _loadTheatersPlayingMovie() async {
    try {
      // 1. Lấy tất cả showtimes của phim
      final showtimes = await _firestoreService
          .getShowtimesByMovie(widget.movie.id)
          .first;

      if (!mounted) return;

      // 2. Nhóm showtimes theo theaterId
      final Map<String, List<Showtime>> grouped = {};
      for (var showtime in showtimes) {
        if (!grouped.containsKey(showtime.theaterId)) {
          grouped[showtime.theaterId] = [];
        }
        grouped[showtime.theaterId]!.add(showtime);
      }

      // 3. Lấy thông tin theater cho mỗi theaterId
      final Map<String, Theater> theaterMap = {};
      for (var theaterId in grouped.keys) {
        final theater = await _firestoreService.getTheaterById(theaterId);
        if (theater != null) {
          theaterMap[theaterId] = theater;
        }
      }

      if (!mounted) return;

      setState(() {
        _showtimesByTheater = grouped;
        _theaters = theaterMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  /// Navigate to BookingScreen với theater đã chọn
  void _selectTheater(Theater theater) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          movie: widget.movie,
          theater: theater, // ✅ Truyền theater đã chọn
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn rạp chiếu'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Info Card
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.cardColor,
            child: Row(
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.movie.posterUrl,
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.movie, color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Movie Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.goldColor, size: 16),
                          const SizedBox(width: 4),
                          Text('${widget.movie.rating}'),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, size: 16, color: AppTheme.textSecondaryColor),
                          const SizedBox(width: 4),
                          Text('${widget.movie.duration}\''),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Rạp đang chiếu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Theater List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : _theaters.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.theaters_outlined,
                              size: 64,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không có rạp nào chiếu phim này',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _theaters.length,
                        itemBuilder: (context, index) {
                          final theaterId = _theaters.keys.elementAt(index);
                          final theater = _theaters[theaterId]!;
                          final showtimeCount = _showtimesByTheater[theaterId]?.length ?? 0;

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => _selectTheater(theater),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Theater Name
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.theaters,
                                          color: AppTheme.primaryColor,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            theater.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Address
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            theater.address,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Showtime Count
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$showtimeCount suất chiếu',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
