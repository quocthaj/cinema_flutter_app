# 🎬 Cinema Flutter App - Firestore Integration Guide

## 📁 Cấu trúc Project

```
lib/
├── models/                          # ✅ HOÀN THÀNH
│   ├── movie.dart                   # Model cho phim
│   ├── theater_model.dart           # Model cho rạp chiếu
│   ├── screen_model.dart            # Model cho phòng chiếu
│   ├── showtime.dart                # Model cho lịch chiếu (đã cập nhật)
│   ├── booking_model.dart           # Model cho đặt vé (MỚI)
│   ├── payment_model.dart           # Model cho thanh toán (MỚI)
│   ├── ticket.dart                  # UI Model cho vé (đã cập nhật)
│   └── user_model.dart              # Model cho người dùng
│
├── services/                        # ✅ HOÀN THÀNH
│   ├── firestore_service.dart       # Service CRUD cho Firestore (đã mở rộng)
│   ├── seed_data_service.dart       # Service thêm dữ liệu mẫu (MỚI)
│   └── auth_service.dart            # Service xác thực
│
└── screens/
    └── admin/                       # ✅ HOÀN THÀNH
        └── seed_data_screen.dart    # Màn hình admin seed data (MỚI)
```

## 🎯 Những gì đã hoàn thành

### ✅ 1. Models (Đầy đủ)
- [x] `movie.dart` - Phim với toJson/fromFirestore
- [x] `theater_model.dart` - Rạp chiếu
- [x] `screen_model.dart` - Phòng chiếu với sơ đồ ghế
- [x] `showtime.dart` - Lịch chiếu (đã cập nhật hoàn chỉnh)
- [x] `booking_model.dart` - Đặt vé (MỚI - đầy đủ)
- [x] `payment_model.dart` - Thanh toán (MỚI - đầy đủ)
- [x] `user_model.dart` - Người dùng
- [x] `ticket.dart` - UI Model (đã cập nhật)

### ✅ 2. Services
- [x] `firestore_service.dart` - CRUD đầy đủ cho tất cả collections
  - Movies CRUD
  - Theaters CRUD
  - Screens CRUD
  - Showtimes CRUD
  - Bookings CRUD (với transaction)
  - Payments CRUD
  - Users CRUD

- [x] `seed_data_service.dart` - Thêm dữ liệu mẫu
  - Seed 5 phim
  - Seed 4 rạp
  - Seed 12 phòng chiếu
  - Seed lịch chiếu 7 ngày
  - Clear all data (reset)

### ✅ 3. UI Admin
- [x] `seed_data_screen.dart` - Màn hình admin thêm/xóa dữ liệu

### ✅ 4. Documentation
- [x] `ARCHITECTURE.md` - Kiến trúc tổng quan
- [x] `USAGE_GUIDE.md` - Hướng dẫn chi tiết
- [x] `IMPLEMENTATION_SUMMARY.md` - Tóm tắt (file này)

## 🚀 Cách sử dụng ngay

### Bước 1: Thêm màn hình Seed Data vào app

#### Option 1: Thêm nút tạm trong Home Screen
```dart
// lib/screens/home/home_screen.dart
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SeedDataScreen(),
      ),
    );
  },
  child: const Icon(Icons.admin_panel_settings),
  tooltip: 'Admin - Seed Data',
)
```

#### Option 2: Thêm vào Drawer
```dart
// lib/screens/home/custom_drawer.dart
ListTile(
  leading: const Icon(Icons.admin_panel_settings),
  title: const Text('Admin - Seed Data'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SeedDataScreen(),
      ),
    );
  },
)
```

### Bước 2: Import cần thiết
```dart
import 'screens/admin/seed_data_screen.dart';
```

### Bước 3: Chạy app và seed data
1. Chạy app: `flutter run`
2. Nhấn nút Admin hoặc mở từ Drawer
3. Nhấn "Thêm tất cả dữ liệu mẫu"
4. Đợi 2-3 phút
5. Kiểm tra Firebase Console

### Bước 4: Sử dụng FirestoreService trong app

```dart
// Ví dụ: Màn hình danh sách phim
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/movie.dart';

class MovieListScreen extends StatelessWidget {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Movie>>(
      stream: _firestoreService.getMoviesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Chưa có phim nào'));
        }

        final movies = snapshot.data!;
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return ListTile(
              leading: Image.network(movie.posterUrl),
              title: Text(movie.title),
              subtitle: Text('${movie.genre} • ${movie.duration} phút'),
              trailing: Text('⭐ ${movie.rating}'),
            );
          },
        );
      },
    );
  }
}
```

## 📊 Collections trong Firestore

| Collection | Document Count (After Seed) | Mục đích |
|-----------|---------------------------|----------|
| `movies` | 5 | Danh sách phim |
| `theaters` | 4 | Danh sách rạp |
| `screens` | 12 (3 screens × 4 theaters) | Phòng chiếu |
| `showtimes` | ~60+ (7 days × 3 movies × 3 times) | Lịch chiếu |
| `bookings` | 0 (user tạo khi đặt vé) | Đặt vé |
| `payments` | 0 (user tạo khi thanh toán) | Thanh toán |
| `users` | Auto (Firebase Auth) | Người dùng |

## 🔗 Mối quan hệ dữ liệu

```
movies (1) ──→ (N) showtimes
theaters (1) ──→ (N) screens
screens (1) ──→ (N) showtimes
showtimes (1) ──→ (N) bookings
users (1) ──→ (N) bookings
bookings (1) ──→ (1) payments
```

## 📖 Đọc thêm

- **ARCHITECTURE.md**: Kiến trúc chi tiết, security rules, indexes
- **USAGE_GUIDE.md**: Hướng dẫn sử dụng từng function, ví dụ code
- **Models**: Xem comment trong từng file model

## ⚡ Quick Commands

```bash
# Run app
flutter run

# Build release
flutter build apk

# Clean build
flutter clean && flutter pub get

# Check code
flutter analyze
```

## 🎯 Checklist triển khai

### Phase 1: Setup (✅ Hoàn thành)
- [x] Tạo models đầy đủ
- [x] Tạo FirestoreService với CRUD
- [x] Tạo SeedDataService
- [x] Tạo Admin UI

### Phase 2: Integration (Tiếp theo)
- [ ] Kết nối UI với Firestore
- [ ] Implement booking flow
- [ ] Implement payment flow
- [ ] Test end-to-end

### Phase 3: Enhancement (Sau này)
- [ ] Add search/filter
- [ ] Add favorites
- [ ] Add reviews
- [ ] Add notifications

## 🐛 Known Issues & Solutions

### Issue 1: Import errors
```
Error: 'package:cinema_flutter_app/models/booking_model.dart' not found
```
**Solution**: Chạy `flutter pub get`

### Issue 2: Firebase not initialized
```
Error: Firebase has not been correctly initialized
```
**Solution**: Kiểm tra `firebase_options.dart` và gọi `Firebase.initializeApp()` trong `main()`

### Issue 3: Permission denied
```
Error: [cloud_firestore/permission-denied] Missing or insufficient permissions
```
**Solution**: Cập nhật Security Rules trong Firebase Console (xem ARCHITECTURE.md)

## 📞 Support

Nếu gặp vấn đề:
1. Đọc USAGE_GUIDE.md
2. Kiểm tra Firebase Console
3. Xem logs: `flutter logs`
4. Clear cache: `flutter clean`

## 🎉 Kết luận

Bạn đã có đầy đủ:
✅ Models hoàn chỉnh cho tất cả entities
✅ FirestoreService với CRUD đầy đủ
✅ SeedDataService để thêm dữ liệu mẫu
✅ Admin UI để quản lý data
✅ Documentation chi tiết

**Tiếp theo**: Bắt đầu kết nối UI của bạn với các services này!

---
**Made with ❤️ for Cinema Flutter App**
