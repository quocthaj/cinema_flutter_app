// lib/screens/payment/receipt_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_mobile/models/payment_model.dart';
import 'package:doan_mobile/services/firestore_service.dart'; // Sửa đường dẫn nếu cần
import 'package:doan_mobile/screens/home/home_screen.dart'; // Sửa đường dẫn nếu cần
import 'package:doan_mobile/config/theme.dart'; // Sửa đường dẫn nếu cần
import 'package:provider/provider.dart'; // Dùng Provider để lấy service

class ReceiptScreen extends StatefulWidget {
  final String paymentDocId; // Nhận ID từ TransactionStatusScreen

  const ReceiptScreen({super.key, required this.paymentDocId});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  // SỬA: Lấy service từ Provider (cách tốt nhất)
  // (Chúng ta đã setup Provider trong main.dart)
  late final FirestoreService _firestoreService;
  late Future<TransactionReceipt> _receiptFuture;

  @override
  void initState() {
    super.initState();
    // Lấy service từ Provider. 'listen: false' an toàn trong initState.
    // Lưu ý: Nếu bạn chưa sửa main.dart để dùng Provider,
    // code cũ 'FirestoreService()' của bạn vẫn chạy được,
    // nhưng đây là cách làm chuẩn hơn.
    _firestoreService = Provider.of<FirestoreService>(context, listen: false);

    // Gọi hàm fetch dữ liệu ngay khi màn hình được tạo
    _receiptFuture = _firestoreService.getReceiptDetails(widget.paymentDocId);
  }

  @override
  Widget build(BuildContext context) {
    // Định dạng tiền tệ và ngày giờ
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    final timeFormatter = DateFormat('HH:mm', 'vi_VN');

    // Lấy màu từ theme
    final Color backgroundColor = AppTheme.darkTheme.scaffoldBackgroundColor;
    final Color cardColor = AppTheme.cardColor;
    final Color primaryColor = AppTheme.primaryColor;
    final Color textColor = AppTheme.textPrimaryColor;
    final Color secondaryTextColor = AppTheme.textSecondaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Biên lai giao dịch'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back
      ),
      body: FutureBuilder<TransactionReceipt>(
        future: _receiptFuture,
        builder: (context, snapshot) {
          // Trạng thái 1: Đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          // Trạng thái 2: Lỗi
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Lỗi tải biên lai: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            );
          }

          // Trạng thái 3: Không có dữ liệu (không nên xảy ra nếu không lỗi)
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Không tìm thấy dữ liệu biên lai.',
                style: TextStyle(color: secondaryTextColor),
              ),
            );
          }

          // Trạng thái 4: Tải thành công!
          final receipt = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent[400],
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Thanh toán thành công', // Lấy từ status
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent[400],
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mã QR Code (Ví dụ - Cần package 'qr_flutter')
                  // Center(
                  //   child: QrImageView(
                  //     data: receipt.transactionId, // Mã QR chính là ID giao dịch
                  //     version: QrVersions.auto,
                  //     size: 150.0,
                  //     backgroundColor: Colors.white,
                  //     padding: EdgeInsets.all(10),
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  _buildReceiptRow(Icons.receipt_long_outlined, "Mã GD:",
                      receipt.transactionId,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  const Divider(color: Colors.white12),
                  _buildReceiptRow(
                      Icons.movie_outlined, "Phim:", receipt.movieTitle,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  const Divider(color: Colors.white12),
                  _buildReceiptRow(
                      Icons.theaters_outlined, "Rạp:", receipt.theaterName,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  _buildReceiptRow(
                      Icons.meeting_room_outlined, "Phòng:", receipt.roomName,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  const Divider(color: Colors.white12),
                  _buildReceiptRow(Icons.calendar_today_outlined, "Ngày chiếu:",
                      dateFormatter.format(receipt.showtime),
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  _buildReceiptRow(Icons.access_time_outlined, "Giờ chiếu:",
                      timeFormatter.format(receipt.showtime),
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  _buildReceiptRow(
                      Icons.chair_outlined, "Ghế:", receipt.seats.join(', '),
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  const Divider(color: Colors.white12),
                  _buildReceiptRow(Icons.payment_outlined, "Phương thức:",
                      receipt.paymentMethod,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  _buildReceiptRow(Icons.schedule_outlined, "Thời gian TT:",
                      "${timeFormatter.format(receipt.paymentTime)} - ${dateFormatter.format(receipt.paymentTime)}",
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  const Divider(color: Colors.white12),
                  _buildReceiptRow(Icons.monetization_on_outlined, "Tổng tiền:",
                      currencyFormatter.format(receipt.amountPaid),
                      isAmount: true,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 30),

                  // Nút Đóng
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.home_outlined),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.fieldColor, // Màu nút khác
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        // Quay về trang chủ và xóa hết lịch sử
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      label: const Text('Về Trang chủ'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget con để hiển thị từng hàng thông tin
  Widget _buildReceiptRow(
    IconData icon,
    String label,
    String value, {
    bool isAmount = false,
    required Color textColor,
    required Color secondaryTextColor,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: secondaryTextColor),
          const SizedBox(width: 16),
          Text('$label ',
              style: TextStyle(color: secondaryTextColor, fontSize: 14)),
          const Spacer(), // Đẩy giá trị sang phải
          Expanded(
            flex: 2, // Cho giá trị nhiều không gian hơn
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
                fontSize: isAmount ? 18 : 15,
                color: isAmount ? primaryColor : textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
