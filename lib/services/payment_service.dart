// lib/services/payment_service.dart

import 'dart:convert'; // Cho jsonEncode/Decode
import 'package:flutter/material.dart'; // Cho @required
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // Dùng để mở deeplink

// SỬA: Đảm bảo đường dẫn này chính xác
import 'package:doan_mobile/models/payment_model.dart';

class PaymentService {
  // SỬA ĐỔI: Thay thế bằng URL Backend C# (Ngrok hoặc domain thật)
  // URL này phải khớp với URL bạn thấy khi chạy ngrok
  final String _backendBaseUrl =
      "https://nondemonstrative-bimonthly-peter.ngrok-free.dev/api";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// HÀM CHÍNH: Xử lý thanh toán theo luồng "Deep Link"
  /// Trả về paymentDocId nếu khởi tạo thành công, ngược lại trả về null
  Future<String?> processPayment({
    required String bookingId,
    required double amount,
    required String gateway, // "momo", "vnpay", "zalopay"
    String description = "Thanh toán vé xem phim",
  }) async {
    String? paymentDocId; // ID của document trên Firestore

    try {
      // Bước 3a: Lấy User và ID Token
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("Người dùng chưa đăng nhập. Không thể thanh toán.");
      }
      // Lấy token mới nhất
      final idToken = await user.getIdToken(true);

      // Bước 3b & 3c: Tạo document 'pending' trên Firestore
      print("Đang tạo document thanh toán 'pending' trên Firestore...");
      final docRef = await _firestore.collection('payments').add({
        'bookingId': bookingId,
        'userId': user.uid,
        'amount': amount,
        'method': gateway,
        'status': 'pending', // Trạng thái ban đầu
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': null,
        'transactionId': null,
        'errorMessage': null,
      });
      paymentDocId = docRef.id;
      print("Đã tạo payment document ID: $paymentDocId");

      // Bước 4: Gọi API Backend C#
      print("Đang gọi API Backend C# để lấy deeplink...");
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/payments/create-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // Gửi token xác thực
        },
        body: jsonEncode({
          // Gửi 'transactionId' để khớp với C# 'CreatePaymentIntentRequest'
          'transactionId': paymentDocId,
          'userId': user.uid,
          'amount': amount,
          'gateway': gateway,
          'description': description,
          'bookingId': bookingId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Backend Error (${response.statusCode}): ${response.body}");
        throw Exception("Lỗi từ server: ${response.body}");
      }

      // --- SỬA LỖI ĐỌC JSON ---
      // Bước 5a: Nhận phản hồi
      final responseData = jsonDecode(response.body);

      // 1. Kiểm tra xem có 'paymentData' không
      if (responseData['paymentData'] == null ||
          responseData['paymentData'] is! Map<String, dynamic>) {
        throw Exception("Backend không trả về cấu trúc 'paymentData' hợp lệ.");
      }

      // 2. Lấy Map lồng nhau
      final Map<String, dynamic> paymentData = responseData['paymentData'];

      // 3. Tìm link (ưu tiên deeplink, sau đó là payUrl, v.v...)
      // (Backend C# của bạn trả về 'deeplink' cho MoMo, 'paymentUrl' cho VNPay, 'orderUrl' cho ZaloPay)
      final String? deeplink = paymentData['deeplink'] as String?;
      final String? payUrl = paymentData['paymentUrl'] as String?;
      final String? zaloOrderUrl = paymentData['orderUrl'] as String?;

      // Lấy link đầu tiên tìm thấy
      final String? linkToOpen = deeplink ?? payUrl ?? zaloOrderUrl;

      if (linkToOpen == null || linkToOpen.isEmpty) {
        throw Exception(
            "Backend không trả về 'deeplink' hoặc 'payUrl' hợp lệ.");
      }
      // --- KẾT THÚC SỬA LỖI ---

      // Bước 5b: Mở deeplink/payUrl
      print("Đã nhận link, đang mở: $linkToOpen");
      final Uri url = Uri.parse(linkToOpen);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // Nếu không mở được app (chế độ external), thử mở bằng WebView nội bộ
        // (Quan trọng cho VNPay)
        if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
          throw Exception(
              'Không thể mở ứng dụng thanh toán hoặc trang WebView.');
        }
      }

      // Bước 5c: Trả về paymentDocId cho UI
      print("Trả về paymentDocId cho UI để theo dõi.");
      return paymentDocId;
    } catch (e) {
      print("Lỗi nghiêm trọng trong processPayment: $e");
      // Nếu đã tạo document Firestore nhưng bị lỗi ở các bước sau,
      // cập nhật lỗi vào document đó
      if (paymentDocId != null) {
        await _firestore.collection('payments').doc(paymentDocId).update({
          'status': 'failed',
          'errorMessage': e.toString(),
          'completedAt': FieldValue.serverTimestamp(),
        });
      }
      return null; // Trả về null để UI biết là đã thất bại
    }
  }
}
