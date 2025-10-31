import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Dùng Provider
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; // <-- Dùng EasyLoading

// --- THÊM CÁC IMPORT SERVICE ---
// (Hãy đảm bảo các đường dẫn này là chính xác)
import 'package:doan_mobile/services/auth_service.dart';
import 'package:doan_mobile/services/firestore_service.dart';
import 'package:doan_mobile/services/payment_service.dart';

// --- SỬA ĐƯỜNG DẪN MÀN HÌNH ---
// (AuthWrapper sẽ được tạo ở file riêng, file 2)
import 'auth_wrapper.dart';
import 'package:doan_mobile/config/theme.dart'; // Theme của bạn
import 'firebase_options.dart';

void main() async {
  // 1. Đảm bảo khởi động Flutter và Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Cấu hình EasyLoading (từ code của bạn)
  configLoading();

  // 3. Chạy ứng dụng và bọc nó bằng MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // --- CUNG CẤP CÁC SERVICE ---

        // Cung cấp AuthService
        // (Lưu ý: Nếu AuthService là ChangeNotifier, hãy dùng ChangeNotifierProvider)
        Provider<AuthService>(create: (_) => AuthService()),

        // Cung cấp FirestoreService
        Provider<FirestoreService>(create: (_) => FirestoreService()),

        // Cung cấp PaymentService (phiên bản Deep Link không cần ChangeNotifier)
        Provider<PaymentService>(create: (_) => PaymentService()),
      ],
      child: const MyApp(), // Chạy ứng dụng chính
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema Booking',
      theme: AppTheme.darkTheme, // Giữ theme của bạn

      // SỬA: 'home' bây giờ SẼ LUÔN LÀ AuthWrapper.
      // AuthWrapper sẽ tự quyết định hiển thị HomeScreen hay LoginScreen.
      home: const AuthWrapper(),

      // THÊM: Khởi tạo EasyLoading cho MaterialApp
      builder: EasyLoading.init(),
    );
  }
}

// Cấu hình EasyLoading (từ code của bạn)
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black87
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}
