import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import '../../models/new_and_promotion.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  final posts = [
    New(
      id: '',
      title: 'Bom tấn “Barbie” chính thức ra rạp',
      content: 'Khán giả Việt Nam đang háo hức chờ đón bộ phim “Barbie” với nhiều màu sắc và âm nhạc sống động.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'news',
    ),
    New(
      id: '',
      title: 'Ưu đãi combo bắp nước 2 người chỉ 79k',
      content: 'Áp dụng tại tất cả các rạp CGV từ thứ 6 đến Chủ nhật. Quét mã QR trên app để nhận ưu đãi.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      type: 'promotion',
    ),
    New(
      id: '',
      title: 'Phim Marvel “Deadpool 3” tung trailer chính thức',
      content: 'Trailer mới hé lộ nhiều cảnh hành động cực kỳ hấp dẫn khiến fan Marvel đứng ngồi không yên.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      type: 'news',
    ),
    New(
      id: '',
      title: 'Khuyến mãi sinh nhật: Vé miễn phí cho hội viên CGV',
      content: 'Nếu sinh nhật của bạn rơi trong tháng này, nhận ngay 01 vé miễn phí tại tất cả các rạp.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      type: 'promotion',
    ),
    New(
      id: '',
      title: 'Phim Việt “Người tình ánh trăng” đạt doanh thu kỷ lục',
      content: 'Chỉ sau 5 ngày công chiếu, bộ phim vượt mốc 20 tỷ đồng, tạo nên cơn sốt phòng vé.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      type: 'news',
    ),
    New(
      id: '',
      title: 'Combo cuối tuần: Vé 2D + bắp nước chỉ 99k',
      content: 'Áp dụng từ thứ 6 đến Chủ nhật, chỉ cần quét mã QR trên ứng dụng CGV.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      type: 'promotion',
    ),
    New(
      id: '',
      title: 'Tin nóng: Lịch chiếu phim Tết 2026 tại CGV',
      content: 'Cập nhật lịch chiếu các bộ phim hot nhất dịp Tết 2026 tại tất cả cụm rạp CGV.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      type: 'news',
    ),
    New(
      id: '',
      title: 'Khuyến mãi đặc biệt: Vé 2D chỉ 49k ngày đầu tuần',
      content: 'Áp dụng từ thứ 2 đến thứ 4 tại tất cả các rạp CGV trên toàn quốc.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      type: 'promotion',
    ),
    New(
      id: '',
      title: 'Phim bom tấn “Oppenheimer” công phá phòng vé',
      content: 'Bộ phim Oppenheimer đang gây sốt toàn cầu, khán giả Việt háo hức thưởng thức.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 16)),
      type: 'news',
    ),
    New(
      id: '',
      title: 'Ưu đãi nhóm 4 người: Vé chỉ 200k',
      content: 'Đặt vé cho nhóm 4 người tại CGV để được giảm giá cực sốc chỉ 200k/4 vé.',
      imageUrl: 'lib/images/banner3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      type: 'promotion',
    ),
  ];

  for (final post in posts) {
    try {
      await firestore.collection('posts').add(post.toMap());
      print("✅ Đã upload: ${post.title}");
    } catch (e) {
      print("❌ Lỗi upload: $e");
    }
  }

  print("🎉 Hoàn tất upload tất cả 10 bài viết nổi bật và khuyến mãi CGV!");
}
