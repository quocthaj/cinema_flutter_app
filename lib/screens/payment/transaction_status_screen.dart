// lib/screens/payment/transaction_status_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan_mobile/models/payment_model.dart'; // Import model
import 'receipt_screen.dart'; // Màn hình biên lai (cần tạo)
import 'package:doan_mobile/screens/home/home_screen.dart'; // Màn hình chính

class TransactionStatusScreen extends StatelessWidget {
  // Nhận paymentDocId từ PaymentSelectionScreen
  final String paymentDocId;

  const TransactionStatusScreen({
    super.key, 
    required this.paymentDocId
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trạng thái giao dịch'),
        automaticallyImplyLeading: false, // Ẩn nút back
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
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái 2: Không tìm thấy giao dịch
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return _buildStatusView(
              context,
              icon: Icons.error_outline,
              color: Colors.red,
              title: 'Không tìm thấy giao dịch',
              message: 'Đã xảy ra lỗi. Không thể tìm thấy giao dịch $paymentDocId.',
              showReceiptButton: false
            );
          }

          // Trạng thái 3: Đã có dữ liệu
          // Chuyển đổi DocumentSnapshot thành đối tượng Payment
          final payment = Payment.fromFirestore(snapshot.data!);

          // Dùng switch để hiển thị UI tương ứng với status
          switch (payment.status) {
            // Case "pending" (đang chờ Webhook)
            case 'pending':
            case 'processing': // (Có thể bạn dùng cả status này)
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Đang chờ xác nhận từ MoMo...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text('Vui lòng không đóng ứng dụng.',
                         style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              );
            
            // Case "success" (Backend đã cập nhật)
            case 'success':
              return _buildStatusView(
                context,
                icon: Icons.check_circle_outline,
                color: Colors.green,
                title: 'Thanh toán thành công!',
                message: 'Giao dịch của bạn đã được xử lý thành công.',
                showReceiptButton: true,
                paymentDocId: paymentDocId
              );

            // Case "failed" hoặc "cancelled" (Backend đã cập nhật)
            case 'failed':
            case 'cancelled':
            default:
              return _buildStatusView(
                context,
                icon: Icons.cancel_outlined,
                color: Colors.red,
                title: 'Thanh toán thất bại',
                message: payment.errorMessage ?? 'Giao dịch đã bị hủy hoặc thất bại. Vui lòng thử lại.',
                showReceiptButton: false
              );
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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            
            // Nút "Xem biên lai" (chỉ hiện khi thành công)
            if (showReceiptButton && paymentDocId != null)
              ElevatedButton(
                onPressed: () {
                  // TODO: Tạo file 'receipt_screen.dart'
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => ReceiptScreen(transactionId: paymentDocId),
                  //   ),
                  // );
                },
                child: const Text('Xem biên lai'),
              ),
            const SizedBox(height: 12),
            
            // Nút "Về trang chủ"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700]),
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