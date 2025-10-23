import 'package:cloud_firestore/cloud_firestore.dart'; // <-- THÊM
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- THÊM: Để định dạng ngày giờ
import '/services/auth_service.dart'; // <-- Sửa đường dẫn nếu cần
import '/services/firestore_service.dart'; // <-- Sửa đường dẫn nếu cần
import '/models/movie.dart'; // <-- Sửa đường dẫn nếu cần
import '/config/theme.dart'; // <-- Sửa đường dẫn nếu cần
import 'package:cached_network_image/cached_network_image.dart'; // <-- THÊM: Để hiển thị ảnh

class WatchedMoviesScreen extends StatefulWidget {
  const WatchedMoviesScreen({super.key});

  @override
  State<WatchedMoviesScreen> createState() => _WatchedMoviesScreenState();
}

class _WatchedMoviesScreenState extends State<WatchedMoviesScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String? _userId; // Lưu userId để dùng trong StreamBuilder

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser?.uid; // Lấy userId khi màn hình khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    // Lấy màu nền và màu chính từ theme
    final Color backgroundColor = AppTheme.darkTheme.scaffoldBackgroundColor;
    final Color primaryColor = AppTheme.primaryColor;
    final Color textColor = AppTheme.textPrimaryColor;
    final Color secondaryTextColor = AppTheme.textSecondaryColor;

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

                    // Định dạng ngày xem
                    final String watchedDateString = showtimeDateTime != null
                        ? DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(
                            showtimeDateTime.toDate()) // Thêm locale 'vi_VN'
                        : 'Không rõ ngày';

                    // Nếu không có movieId thì hiển thị tạm
                    if (movieId == null || movieId.isEmpty) {
                      return Card(
                        color: AppTheme.cardColor, // Màu nền Card
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
                            color: AppTheme.cardColor,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Container(
                                  width: 50,
                                  height: 75,
                                  color: AppTheme
                                      .fieldColor, // Màu nền placeholder
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
                                  color: AppTheme
                                      .fieldColor), // Placeholder cho title
                              subtitle: Container(
                                  height: 12,
                                  width: 100,
                                  margin: const EdgeInsets.only(top: 4),
                                  color: AppTheme
                                      .fieldColor), // Placeholder cho subtitle
                            ),
                          );
                        }
                        // Lỗi tải phim hoặc không tìm thấy phim
                        if (movieSnapshot.hasError ||
                            !movieSnapshot.hasData ||
                            movieSnapshot.data == null) {
                          return Card(
                            color: AppTheme.cardColor,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text('Lỗi tải thông tin phim',
                                  style: TextStyle(color: textColor)),
                              subtitle: Text('Ngày xem: $watchedDateString',
                                  style: TextStyle(color: secondaryTextColor)),
                              leading: Icon(Icons.error_outline,
                                  color: Colors.redAccent),
                            ),
                          );
                        }

                        // Có thông tin phim
                        final movie = movieSnapshot.data!;

                        // Hiển thị ListTile với đầy đủ thông tin
                        return Card(
                          color: AppTheme.cardColor,
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
                                  imageUrl: movie.posterUrl,
                                  placeholder: (context, url) => Container(
                                      color: AppTheme.fieldColor,
                                      child: Center(
                                          child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: primaryColor)))),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                          color: AppTheme.fieldColor,
                                          child: Icon(
                                              Icons.movie_creation_outlined,
                                              color: secondaryTextColor,
                                              size: 30)),
                                  fit: BoxFit.cover, // Đảm bảo ảnh đầy khung
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
