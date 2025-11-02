// lib/screens/payment/transaction_status_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// SỬA: Import file model (số nhiều) chứa tất cả các lớp
import 'package:doan_mobile/models/payment_model.dart';

// SỬA: Import file biên lai (để điều hướng)
import 'receipt_screen.dart';
import 'package:doan_mobile/screens/home/home_screen.dart'; // Màn hình chính
import 'package:doan_mobile/config/theme.dart'; // Import theme của bạn

class TransactionStatusScreen extends StatelessWidget {
  // Nhận paymentDocId từ PaymentSelectionScreen
  final String paymentDocId;

  const TransactionStatusScreen({super.key, required this.paymentDocId});

  @override
  Widget build(BuildContext context) {
    // Lấy màu từ theme
    final Color backgroundColor = AppTheme.darkTheme.scaffoldBackgroundColor;
    final Color primaryColor = AppTheme.primaryColor;
    final Color secondaryTextColor = AppTheme.textSecondaryColor;
    final Color errorColor = AppTheme.errorColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Trạng thái giao dịch'),
        automaticallyImplyLeading: false, // Ẩn nút back
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Bước 7: Lắng nghe document trên Firestore
        stream: FirebaseFirestore.instance
            .collection('payments')
            .doc(paymentDocId)
            .snapshots(),

        builder: (context, snapshot) {
          // Trạng thái 1: Đang chờ dữ liệu từ Firestore
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          // Trạng thái 2: Không tìm thấy giao dịch
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return _buildStatusView(context,
                icon: Icons.error_outline,
                color: errorColor,
                title: 'Không tìm thấy giao dịch',
                message:
                    'Đã xảy ra lỗi. Không thể tìm thấy giao dịch $paymentDocId.',
                showReceiptButton: false);
          }

          // Trạng thái 3: Đã có dữ liệu
          // Chuyển đổi DocumentSnapshot thành đối tượng Payment
          // (Đảm bảo 'Payment.fromFirestore' tồn tại trong 'payment_models.dart')
          final payment = Payment.fromFirestore(snapshot.data!);

          // Dùng switch để hiển thị UI tương ứng với status
          switch (payment.status) {
            // Case "pending" (đang chờ Webhook)
            case 'pending':
            case 'processing': // (Có thể bạn dùng cả status này)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    const SizedBox(height: 20),
                    Text('Đang chờ xác nhận...',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 16, color: secondaryTextColor)),
                    const SizedBox(height: 10),
                    Text('Vui lòng không đóng ứng dụng.',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              );

            // Case "success" (Backend đã cập nhật)
            case 'success':
              return _buildStatusView(context,
                  icon: Icons.check_circle_outline,
                  color: Colors.greenAccent[400] ?? Colors.green, // Màu xanh lá
                  title: 'Thanh toán thành công!',
                  message: 'Giao dịch của bạn đã được xử lý thành công.',
                  showReceiptButton: true,
                  paymentDocId: paymentDocId);

            // Case "failed" hoặc "cancelled" (Backend đã cập nhật)
            case 'failed':
            case 'cancelled':
            default:
              return _buildStatusView(context,
                  icon: Icons.cancel_outlined,
                  color: errorColor, // Màu đỏ lỗi
                  title: 'Thanh toán thất bại',
                  message: payment.errorMessage ??
                      'Giao dịch đã bị hủy hoặc thất bại. Vui lòng thử lại.',
                  showReceiptButton: false);
          }
        },
      ),
    );
  }

  // Widget chung để hiển thị kết quả (Thành công/Thất bại)
  Widget _buildStatusView(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required bool showReceiptButton,
    String? paymentDocId,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 80),
            const SizedBox(height: 24),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondaryColor)),
            const SizedBox(height: 32),

            // Nút "Xem biên lai" (chỉ hiện khi thành công)
            if (showReceiptButton && paymentDocId != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // --- SỬA Ở ĐÂY: Mở file 'receipt_screen.dart' ---
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      // Truyền ID qua cho màn hình biên lai
                      builder: (_) => ReceiptScreen(paymentDocId: paymentDocId),
                    ),
                  );
                  // --- KẾT THÚC SỬA ĐỔI ---
                },
                label: const Text('Xem biên lai'),
              ),
            const SizedBox(height: 12),

            // Nút "Về trang chủ"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.fieldColor, // Màu xám
                  foregroundColor: AppTheme.textPrimaryColor),
              onPressed: () {
                // Quay về trang chủ và xóa tất cả màn hình thanh toán
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const HomeScreen()), // Thay bằng HomeScreen của bạn
                  (route) => false, // Xóa tất cả các route trước đó
                );
              },
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
