import 'package:cloud_firestore/cloud_firestore.dart'; // <-- THÊM
import 'package:flutter/material.dart';
import '/services/auth_service.dart'; // <-- Sửa đường dẫn nếu cần
import '/services/firestore_service.dart'; // <-- Sửa đường dẫn nếu cần
import '/models/movie.dart'; // <-- Sửa đường dẫn nếu cần
import '/config/theme.dart'; // <-- Sửa đường dẫn nếu cần

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    // Lấy màu nền và màu chính từ theme
    final Color backgroundColor = AppTheme.darkTheme.scaffoldBackgroundColor;
    final Color primaryColor = AppTheme.primaryColor;
    final Color textColor = AppTheme.textPrimaryColor;
    final Color secondaryTextColor = AppTheme.textSecondaryColor;
    final Color cardColor = AppTheme.cardColor;
    final Color fieldColor = AppTheme.fieldColor; // Màu placeholder

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Vé của tôi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _userId == null || _userId!.isEmpty
          ? Center(
              child: Text(
              'Vui lòng đăng nhập để xem vé.',
              style: TextStyle(color: secondaryTextColor),
            ))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getUserBookingsStream(_userId!),
              builder: (context, snapshot) {
                // Đang tải
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: primaryColor));
                }
                // Lỗi
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Lỗi tải danh sách vé: ${snapshot.error}',
                          style: TextStyle(color: secondaryTextColor)));
                }
                // Không có vé
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('Bạn chưa có vé nào.',
                          style: TextStyle(color: secondaryTextColor)));
                }

                // Có dữ liệu vé
                final bookingDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: bookingDocs.length,
                  itemBuilder: (context, index) {
                    final bookingData =
                        bookingDocs[index].data() as Map<String, dynamic>;
                    final movieId = bookingData['movieId'] as String?;
                    final showtimeDateTime =
                        bookingData['showtimeDateTime'] as Timestamp?;
                    // Lấy danh sách ghế (List<dynamic>) và chuyển thành List<String>
                    final seatsBookedDynamic =
                        bookingData['seatsBooked'] as List<dynamic>?;
                    final seatsBooked = seatsBookedDynamic
                            ?.map((seat) => seat.toString())
                            .toList() ??
                        [];
                    final seatsString =
                        seatsBooked.join(', '); // Nối chuỗi ghế lại

                    // Định dạng ngày và giờ chiếu
                    final String showDateString = showtimeDateTime != null
                        ? '${showtimeDateTime.toDate().day.toString().padLeft(2, '0')}/${showtimeDateTime.toDate().month.toString().padLeft(2, '0')}/${showtimeDateTime.toDate().year}'
                        : 'N/A';
                    final String showTimeString = showtimeDateTime != null
                        ? '${showtimeDateTime.toDate().hour.toString().padLeft(2, '0')}:${showtimeDateTime.toDate().minute.toString().padLeft(2, '0')}'
                        : 'N/A';

                    // Nếu không có movieId, hiển thị lỗi cơ bản
                    if (movieId == null || movieId.isEmpty) {
                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Lỗi: Thiếu thông tin phim cho vé này',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      );
                    }

                    // Dùng FutureBuilder để lấy thông tin phim
                    return FutureBuilder<Movie?>(
                      future: _firestoreService.getMovieById(movieId),
                      builder: (context, movieSnapshot) {
                        // Placeholder khi đang tải phim
                        if (movieSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Card(
                            color: cardColor,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 18,
                                      width: 200,
                                      color:
                                          fieldColor), // Placeholder tên phim
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Icon(Icons.calendar_today,
                                        size: 16, color: secondaryTextColor),
                                    const SizedBox(width: 8),
                                    Container(
                                        height: 14,
                                        width: 80,
                                        color: fieldColor), // Placeholder ngày
                                    const SizedBox(width: 16),
                                    Icon(Icons.access_time,
                                        size: 16, color: secondaryTextColor),
                                    const SizedBox(width: 8),
                                    Container(
                                        height: 14,
                                        width: 50,
                                        color: fieldColor), // Placeholder giờ
                                  ]),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    Icon(Icons.chair_outlined,
                                        size: 16, color: secondaryTextColor),
                                    const SizedBox(width: 8), // Icon outline
                                    Container(
                                        height: 14,
                                        width: 100,
                                        color: fieldColor), // Placeholder ghế
                                  ]),
                                ],
                              ),
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Lỗi tải thông tin phim cho vé này',
                                  style: TextStyle(color: Colors.redAccent)),
                            ),
                          );
                        }

                        // Có thông tin phim
                        final movie = movieSnapshot.data!;

                        // Hiển thị Card vé hoàn chỉnh
                        return Card(
                          color: cardColor,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)), // Bo góc
                          elevation: 3, // Thêm đổ bóng nhẹ
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10), // Tăng khoảng cách
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 16, color: secondaryTextColor),
                                    const SizedBox(width: 8),
                                    Text('Ngày: $showDateString',
                                        style: TextStyle(
                                            color: secondaryTextColor)),
                                    const SizedBox(width: 16),
                                    Icon(Icons.access_time,
                                        size: 16, color: secondaryTextColor),
                                    const SizedBox(width: 8),
                                    Text('Giờ: $showTimeString',
                                        style: TextStyle(
                                            color: secondaryTextColor)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.chair_outlined,
                                        size: 16,
                                        color:
                                            secondaryTextColor), // Icon outline
                                    const SizedBox(width: 8),
                                    // Hiển thị danh sách ghế, giới hạn số lượng nếu quá dài
                                    Expanded(
                                      // Dùng Expanded để text ghế không bị tràn
                                      child: Text(
                                        'Ghế: $seatsString',
                                        style: TextStyle(
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight
                                                .w500), // In đậm nhẹ ghế
                                        overflow: TextOverflow
                                            .ellipsis, // Thêm dấu ... nếu quá dài
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                // TODO: Có thể thêm nút xem chi tiết vé hoặc QR code ở đây
                              ],
                            ),
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
