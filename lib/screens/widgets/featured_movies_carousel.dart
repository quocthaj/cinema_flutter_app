import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/movie.dart';

/// Widget riêng cho carousel phim nổi bật
/// Tách ra để setState chỉ rebuild carousel, không rebuild toàn bộ HomeScreen
class FeaturedMoviesCarousel extends StatefulWidget {
  final List<Movie> movies;
  final Function(Movie) onMovieTap;

  const FeaturedMoviesCarousel({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  State<FeaturedMoviesCarousel> createState() => _FeaturedMoviesCarouselState();
}

class _FeaturedMoviesCarouselState extends State<FeaturedMoviesCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Text(
          "Chưa có phim nổi bật.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: SizedBox(
        height: 480, // Tăng từ 444 lên 480 để có space cho transform
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.movies.length * 1000,
          itemBuilder: (context, index) {
            final actualIndex = index % widget.movies.length;
            final movie = widget.movies[actualIndex];
            final movieNumber = actualIndex + 1;

            final scale = (1 - ((_currentPage - index).abs() * 0.2)).clamp(0.8, 1.0);
            final rotation = (_currentPage - index) * 0.3;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateY(rotation)
                ..scale(scale, scale),
              child: GestureDetector(
                onTap: () => widget.onMovieTap(movie),
                child: _buildFeaturedMovieCard(movie, movieNumber),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedMovieCard(Movie movie, int movieNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      height: 428,
      child: ClipPath(
        clipper: TicketCardClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF9B3232).withOpacity(0.3),
                const Color(0xFF9B3232).withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Poster + Number
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          movie.posterUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.movie_creation_outlined,
                                color: Colors.white54,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$movieNumber',
                              style: const TextStyle(
                                color: Color(0xFF9B3232),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Movie Info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF9B3232).withOpacity(0.85),
                        const Color(0xFF9B3232).withOpacity(0.95),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFD700),
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${movie.rating}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${movie.duration} Phút",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            movie.releaseDate,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dashed Line
                CustomPaint(
                  size: const Size(double.infinity, 2),
                  painter: DashedLinePainter(),
                ),

                // Book Button
                Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF9B3232),
                        Color(0xFF7A2828),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onMovieTap(movie),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: const Text(
                            "Đặt vé",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Ticket Card Clipper
class TicketCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double cornerRadius = 20.0;
    const double notchRadius = 8.0;
    const int notchCountVertical = 10;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    final double notchHeightRight =
        (size.height - 2 * cornerRadius) / notchCountVertical;
    for (int i = 0; i <= notchCountVertical; i++) {
      final double y = cornerRadius + i * notchHeightRight;
      if (i > 0) {
        path.lineTo(size.width, y - notchHeightRight / 2 - notchRadius);
        path.arcToPoint(
          Offset(size.width, y - notchHeightRight / 2 + notchRadius),
          radius: const Radius.circular(notchRadius),
          clockwise: false,
        );
      }
      if (i < notchCountVertical) {
        path.lineTo(size.width, y + notchHeightRight / 2);
      }
    }

    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    for (int i = notchCountVertical; i >= 0; i--) {
      final double y = cornerRadius + i * notchHeightRight;
      if (i < notchCountVertical) {
        path.lineTo(0, y + notchHeightRight / 2 + notchRadius);
        path.arcToPoint(
          Offset(0, y + notchHeightRight / 2 - notchRadius),
          radius: const Radius.circular(notchRadius),
          clockwise: false,
        );
      }
      if (i > 0) {
        path.lineTo(0, y - notchHeightRight / 2);
      }
    }

    path.lineTo(0, cornerRadius);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Dashed Line Painter
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5;

    const double dashWidth = 8;
    const double dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
