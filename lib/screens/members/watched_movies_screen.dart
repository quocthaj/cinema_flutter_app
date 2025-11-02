import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- THÊM: Dùng Provider
import 'package:intl/intl.dart'; // <-- THÊM: Dùng Intl
import 'package:cached_network_image/cached_network_image.dart'; // <-- THÊM: Dùng CachedImage

// SỬA: Đảm bảo các đường dẫn này là chính xác
import 'package:doan_mobile/services/auth_service.dart';
import 'package:doan_mobile/services/firestore_service.dart';
import 'package:doan_mobile/models/movie.dart';
import 'package:doan_mobile/config/theme.dart';

class WatchedMoviesScreen extends StatefulWidget {
  const WatchedMoviesScreen({super.key});

  @override
  State<WatchedMoviesScreen> createState() => _WatchedMoviesScreenState();
}

class _WatchedMoviesScreenState extends State<WatchedMoviesScreen> {
  // SỬA: Dùng 'late final'
  late final AuthService _authService;
  late final FirestoreService _firestoreService;
  String? _userId; // Lưu userId để dùng trong StreamBuilder

  // SỬA: Thêm định dạng ngày giờ
  final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');

  @override
  void initState() {
    super.initState();
    // SỬA: Lấy service từ Provider
    _authService = Provider.of<AuthService>(context, listen: false);
    _firestoreService = Provider.of<FirestoreService>(context, listen: false);
    _userId = _authService.currentUser?.uid; // Lấy userId khi màn hình khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    // Lấy màu nền và màu chính từ theme
    final Color backgroundColor = AppTheme.darkTheme.scaffoldBackgroundColor;
    final Color primaryColor = AppTheme.primaryColor;
    final Color textColor = AppTheme.textPrimaryColor;
    final Color secondaryTextColor = AppTheme.textSecondaryColor;
    final Color cardColor = AppTheme.cardColor;
    final Color fieldColor = AppTheme.fieldColor;

    return Scaffold(
      backgroundColor: backgroundColor, // Áp dụng màu nền
      appBar: AppBar(
        title: const Text('Phim đã xem'),
        backgroundColor: Colors.transparent, // Nền trong suốt cho AppBar
        elevation: 0,
      ),
      body: _userId == null || _userId!.isEmpty
          ? Center(
              child: Text(
              'Vui lòng đăng nhập để xem lịch sử.',
              style: TextStyle(color: secondaryTextColor),
            ))
          : StreamBuilder<QuerySnapshot>(
              // SỬA: Đảm bảo stream này đúng
              // (getUserBookingsStream trả về 'bookings' nơi userId == _userId)
              stream: _firestoreService.getUserBookingsStream(_userId!),
              builder: (context, snapshot) {
                // Đang tải dữ liệu
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: primaryColor));
                }
                // Có lỗi xảy ra
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Lỗi tải lịch sử: ${snapshot.error}',
                          style: TextStyle(color: secondaryTextColor)));
                }
                // Không có dữ liệu hoặc danh sách rỗng
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('Bạn chưa xem phim nào.',
                          style: TextStyle(color: secondaryTextColor)));
                }

                // Có dữ liệu bookings
                final bookingDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Thêm padding cho ListView
                  itemCount: bookingDocs.length,
                  itemBuilder: (context, index) {
                    final bookingData =
                        bookingDocs[index].data() as Map<String, dynamic>;
                    final movieId = bookingData['movieId'] as String?;
                    final showtimeDateTime =
                        bookingData['showtimeDateTime'] as Timestamp?;

                    // SỬA: Dùng DateFormat
                    final String watchedDateString = showtimeDateTime != null
                        ? _dateTimeFormatter.format(showtimeDateTime.toDate())
                        : 'Không rõ ngày';

                    // Nếu không có movieId thì hiển thị tạm
                    if (movieId == null || movieId.isEmpty) {
                      return Card(
                        color: cardColor, // Màu nền Card
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)), // Bo góc Card
                        child: ListTile(
                          title: Text('Phim không xác định',
                              style: TextStyle(color: textColor)),
                          subtitle: Text('Ngày xem: $watchedDateString',
                              style: TextStyle(color: secondaryTextColor)),
                          leading: Icon(Icons.movie_creation_outlined,
                              color: secondaryTextColor),
                        ),
                      );
                    }

                    // Dùng FutureBuilder để lấy thông tin phim dựa trên movieId
                    return FutureBuilder<Movie?>(
                      future: _firestoreService.getMovieById(movieId),
                      builder: (context, movieSnapshot) {
                        // Đang tải thông tin phim
                        if (movieSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Placeholder giữ chỗ đẹp hơn
                          return Card(
                            color: cardColor,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Container(
                                  width: 50,
                                  height: 75,
                                  color: fieldColor, // Màu nền placeholder
                                  child: Center(
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: primaryColor)))),
                              title: Container(
                                  height: 14,
                                  width: 150,
                                  color: fieldColor), // Placeholder cho title
                              subtitle: Container(
                                  height: 12,
                                  width: 100,
                                  margin: const EdgeInsets.only(top: 4),
                                  color:
                                      fieldColor), // Placeholder cho subtitle
                            ),
                          );
                        }
                        // Lỗi tải phim hoặc không tìm thấy phim
                        if (movieSnapshot.hasError ||
                            !movieSnapshot.hasData ||
                            movieSnapshot.data == null) {
                          return Card(
                            color: cardColor,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text('Lỗi tải thông tin phim',
                                  style: TextStyle(color: textColor)),
                              subtitle: Text('Ngày xem: $watchedDateString',
                                  style: TextStyle(color: secondaryTextColor)),
                              leading: const Icon(Icons.error_outline,
                                  color: Colors.redAccent),
                            ),
                          );
                        }

                        // Có thông tin phim
                        final movie = movieSnapshot.data!;

                        // Hiển thị ListTile với đầy đủ thông tin
                        return Card(
                          color: cardColor,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8), // Tăng padding ListTile
                            leading: SizedBox(
                              width: 55, // Tăng nhẹ chiều rộng
                              height: 80, // Tăng nhẹ chiều cao
                              child: ClipRRect(
                                // Thêm ClipRRect để bo góc ảnh
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  // SỬA: Dùng CachedNetworkImage
                                  imageUrl: movie.posterUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) {
                                    return Container(
                                        color: fieldColor,
                                        child: Center(
                                            child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: primaryColor))));
                                  },
                                  // --- SỬA LỖI Ở ĐÂY ---
                                  // Đổi 'errorBuilder' thành 'errorWidget'
                                  errorWidget: (context, url, error) =>
                                      // --- KẾT THÚC SỬA LỖI ---
                                      Container(
                                          color: fieldColor,
                                          child: Icon(
                                              Icons.movie_creation_outlined,
                                              color: secondaryTextColor,
                                              size: 30)),
                                ),
                              ),
                            ),
                            title: Text(
                              movie.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 16), // Tăng cỡ chữ title
                              maxLines: 2, // Giới hạn 2 dòng
                              overflow:
                                  TextOverflow.ellipsis, // Thêm dấu ... nếu dài
                            ),
                            subtitle: Padding(
                              // Thêm Padding cho subtitle
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Ngày xem: $watchedDateString',
                                  style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 13)), // Giảm cỡ chữ subtitle
                            ),
                            trailing: Icon(Icons.chevron_right,
                                color: secondaryTextColor), // Icon mũi tên phải
                            onTap: () {
                              // TODO: Có thể thêm điều hướng đến chi tiết phim nếu muốn
                              // Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)));
                              print('Đã nhấn vào phim: ${movie.title}');
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
