import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:doan_mobile/services/auth_service.dart'; // Sửa đường dẫn nếu cần
import 'package:doan_mobile/services/firestore_service.dart'; // Sửa đường dẫn nếu cần
import 'package:doan_mobile/models/movie.dart'; // Sửa đường dẫn nếu cần
import 'package:doan_mobile/config/theme.dart'; // Sửa đường dẫn nếu cần
import 'package:cached_network_image/cached_network_image.dart'; // Dùng cho ảnh poster
import 'package:intl/intl.dart'; // Dùng để định dạng ngày giờ
import 'package:barcode_widget/barcode_widget.dart'; // <-- THÊM THƯ VIỆN MÃ VẠCH
import 'package:provider/provider.dart'; // Dùng Provider để lấy service

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  // SỬA: Lấy service từ Provider (nếu đã setup) hoặc giữ nguyên
  late final AuthService _authService;
  late final FirestoreService _firestoreService;
  String? _userId;

  // Định dạng ngày giờ
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy', 'vi_VN');
  final DateFormat _timeFormatter = DateFormat('HH:mm', 'vi_VN');

  @override
  void initState() {
    super.initState();
    // Lấy service từ Provider
    _authService = Provider.of<AuthService>(context, listen: false);
    _firestoreService = Provider.of<FirestoreService>(context, listen: false);
    _userId = _authService.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    // ... (Lấy màu từ theme) ...
    final Color backgroundColor = AppTheme.darkTheme.scaffoldBackgroundColor;
    final Color primaryColor = AppTheme.primaryColor;
    final Color secondaryTextColor = AppTheme.textSecondaryColor;
    final Color cardColor = AppTheme.cardColor;

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
              // SỬA: Stream này lấy từ collection 'bookings'
              stream: _firestoreService.getUserBookingsStream(_userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: primaryColor));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Lỗi tải danh sách vé: ${snapshot.error}',
                          style: TextStyle(color: secondaryTextColor)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('Bạn chưa có vé nào.',
                          style: TextStyle(color: secondaryTextColor)));
                }

                final bookingDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding:
                      const EdgeInsets.all(16.0), // Padding cho cả danh sách
                  itemCount: bookingDocs.length,
                  itemBuilder: (context, index) {
                    final bookingSnapshot = bookingDocs[index];
                    final bookingData =
                        bookingSnapshot.data() as Map<String, dynamic>;

                    // SỬA: Trả về widget Thẻ Vé (Ticket Card)
                    return _buildTicketCard(
                        context, bookingSnapshot.id, bookingData);
                  },
                );
              },
            ),
    );
  }

  /// WIDGET MỚI: Xây dựng giao diện cho mỗi Thẻ Vé
  Widget _buildTicketCard(BuildContext context, String bookingId,
      Map<String, dynamic> bookingData) {
    final String movieId = bookingData['movieId'] ?? '';
    final Timestamp? showtimeTimestamp =
        bookingData['showtimeDateTime'] as Timestamp?;
    final List<String> seatsBooked =
        List<String>.from(bookingData['selectedSeats'] ?? []);
    final String seatsString = seatsBooked.join(', ');
    final String theaterName = bookingData['theaterName'] ?? 'Tại rạp';
    final String roomName = bookingData['screenName'] ?? 'Phòng chiếu';

    // Định dạng ngày giờ
    final String showDateString = showtimeTimestamp != null
        ? _dateFormatter.format(showtimeTimestamp.toDate())
        : 'N/A';
    final String showTimeString = showtimeTimestamp != null
        ? _timeFormatter.format(showtimeTimestamp.toDate())
        : 'N/A';

    // Lấy màu từ theme
    final Color textColor = AppTheme.textPrimaryColor;
    final Color secondaryTextColor = AppTheme.textSecondaryColor;
    final Color cardColor = AppTheme.cardColor;
    final Color fieldColor = AppTheme.fieldColor;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16), // Khoảng cách giữa các vé
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Movie?>(
          future: _firestoreService.getMovieById(movieId), // Lấy thông tin phim
          builder: (context, movieSnapshot) {
            // Lấy thông tin phim (nếu có)
            final movieTitle = movieSnapshot.data?.title ??
                (bookingData['movieTitle'] ?? 'Đang tải...');
            final posterUrl = movieSnapshot.data?.posterUrl;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Phần Thông tin Phim ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh Poster
                    SizedBox(
                      width: 80,
                      height: 110,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: posterUrl == null
                            ? Container(
                                color: fieldColor,
                                child: Icon(Icons.movie,
                                    color: secondaryTextColor))
                            : CachedNetworkImage(
                                imageUrl: posterUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: fieldColor),
                                errorWidget: (context, url, error) => Container(
                                    color: fieldColor,
                                    child: Icon(Icons.error,
                                        color: secondaryTextColor)),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tiêu đề và Rạp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movieTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _buildTicketInfoRow(Icons.theaters_outlined,
                              '$theaterName - $roomName', secondaryTextColor),
                          const SizedBox(height: 4),
                          _buildTicketInfoRow(
                              Icons.calendar_today_outlined,
                              '$showDateString - $showTimeString',
                              secondaryTextColor),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(color: Colors.white24, height: 24),

                // --- Phần Ghế ---
                _buildTicketInfoRow(Icons.chair_outlined, 'Ghế: $seatsString',
                    secondaryTextColor,
                    valueStyle: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16) // Nổi bật ghế
                    ),

                const Divider(color: Colors.white24, height: 24),

                // --- PHẦN MÃ VẠCH (BARCODE) ---
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white, // Mã vạch phải có nền trắng
                        borderRadius: BorderRadius.circular(8)),
                    child: BarcodeWidget(
                      barcode: Barcode.code128(), // Loại mã vạch (Code 128)
                      data: bookingId, // Dữ liệu mã vạch (ID của vé/booking)
                      height: 70,
                      drawText: false, // Không cần vẽ text (vì đã có ở dưới)
                      color: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    bookingId, // Hiển thị ID bên dưới mã vạch
                    style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        letterSpacing: 1.5),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Widget con để hiển thị từng hàng thông tin (Ngày, Giờ, Rạp, Ghế)
  Widget _buildTicketInfoRow(IconData icon, String text, Color iconColor,
      {TextStyle? valueStyle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: valueStyle ??
                TextStyle(color: AppTheme.textPrimaryColor, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
