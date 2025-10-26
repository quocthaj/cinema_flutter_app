import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/theater_model.dart';
import '../../models/movie.dart';
import '../../services/firestore_service.dart';
import '../bookings/booking_screen.dart'; // 🆕 Direct to BookingScreen

class TheaterDetailScreen extends StatefulWidget {
  final Theater theater;
  const TheaterDetailScreen({super.key, required this.theater});

  @override
  State<TheaterDetailScreen> createState() => _TheaterDetailScreenState();
}

class _TheaterDetailScreenState extends State<TheaterDetailScreen> {
  final _firestoreService = FirestoreService();
  
  // Map: movieId -> Movie
  Map<String, Movie> _movies = {};
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoviesPlayingAtTheater();
  }

  /// Tải danh sách phim đang chiếu tại rạp này
  Future<void> _loadMoviesPlayingAtTheater() async {
    try {
      // 1. Lấy tất cả showtimes của theater này
      // Note: We need to get all showtimes and filter by theaterId
      // Since getShowtimesByTheaterAndDate requires a date, we'll fetch all movies first
      // and then check their showtimes
      
      final allMovies = await _firestoreService.getMoviesStream().first;
      final Map<String, Movie> movieMap = {};
      
      // 2. For each movie, check if it has showtimes at this theater
      for (var movie in allMovies) {
        final showtimes = await _firestoreService
            .getShowtimesByMovie(movie.id)
            .first;
        
        // Check if any showtime is at this theater
        final hasShowtimeAtTheater = showtimes.any(
          (st) => st.theaterId == widget.theater.id
        );
        
        if (hasShowtimeAtTheater) {
          movieMap[movie.id] = movie;
        }
      }

      if (!mounted) return;

      setState(() {
        _movies = movieMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách phim: $e')),
        );
      }
    }
  }

  /// Navigate to BookingScreen (Cinema-First Flow)
  void _selectMovie(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          movie: movie,
          // BookingScreen sẽ tự load showtimes của movie tại theater này
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.theater.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theater Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppTheme.cardColor,
              child: Column(
                children: [
                  // Theater Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.theaters,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.theater.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.theater.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_city, color: AppTheme.textSecondaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.theater.city,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, color: AppTheme.textSecondaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.theater.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Section: Phim đang chiếu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '🎬 Phim đang chiếu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            // Movies List
            _isLoading
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    ),
                  )
                : _movies.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.movie_outlined,
                                size: 64,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Rạp này chưa chiếu phim nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies.values.elementAt(index);
                          return _buildMovieCard(movie);
                        },
                      ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Build movie card for grid
  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => _selectMovie(movie),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Poster
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  movie.posterUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white54,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Movie Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppTheme.goldColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.rating}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

