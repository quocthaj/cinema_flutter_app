# 📚 HƯỚNG DẪN SỬ DỤNG HỆ THỐNG SEED DỮ LIỆU CỨNG

## ✅ Tổng quan

Hệ thống seed data đã được **REFACTOR HOÀN TOÀN** sử dụng dữ liệu cứng (hardcoded) thay vì random.

### 🎯 Ưu điểm:
- ✅ **100% chính xác**: Theater-Screen mapping luôn đúng
- ✅ **Không trùng lặp**: Suất chiếu không bao giờ xung đột
- ✅ **Dữ liệu thực tế**: Từ `movie_seed_data.dart` và `theater_seed_data.dart`
- ✅ **Dễ bảo trì**: Chia nhỏ thành nhiều file rõ ràng

---

## 📂 Cấu trúc Files

```
lib/services/seed/
├── hardcoded_movies_data.dart          # 15 phim (8 now_showing + 7 coming_soon)
├── hardcoded_theaters_data.dart        # 18 rạp (7 HN + 8 HCM + 3 ĐN)
├── hardcoded_screens_data.dart         # 72 phòng (18 × 4)
├── hardcoded_showtimes_data.dart       # Suất chiếu Hà Nội (7 rạp)
├── hardcoded_showtimes_hcm_data.dart   # Suất chiếu TP.HCM (8 rạp)
├── hardcoded_showtimes_danang_data.dart # Suất chiếu Đà Nẵng (3 rạp)
└── hardcoded_seed_service.dart         # Service chính
```

---

## 📊 Thống kê Dữ liệu

### 🎬 Movies (15 phim)
| Trạng thái | Số lượng | Ví dụ |
|------------|----------|-------|
| **now_showing** | 8 | "Cục Vàng Của Ngoại", "Nhà Ma Xó", "Tử Chiến Trên Không"... |
| **coming_soon** | 7 | "Phá Đám Sinh Nhật Mẹ", "Avatar 3", "Zootopia 2"... |

### 🏢 Theaters (18 rạp)
| Thành phố | Số rạp | Chuỗi rạp |
|-----------|--------|-----------|
| **Hà Nội** | 7 | CGV (3), Lotte (2), BHD (2) |
| **TP.HCM** | 8 | CGV (3), Lotte (3), Galaxy (2) |
| **Đà Nẵng** | 3 | CGV (2), Lotte (1) |

### 🪑 Screens (72 phòng)
- **Mỗi rạp**: 4 phòng chiếu
- **Cấu trúc**:
  - Phòng 1-3: Standard (80 ghế - 8 hàng × 10 cột)
  - Phòng 4: VIP (48 ghế - 6 hàng × 8 cột)

### ⏰ Showtimes (7 ngày: 29/10 - 04/11/2025)
| Thành phố | Số rạp | Suất/ngày | Tổng (7 ngày) |
|-----------|--------|-----------|---------------|
| **Hà Nội** | 7 | ~100 suất | ~700 suất |
| **TP.HCM** | 8 | ~140 suất | ~980 suất |
| **Đà Nẵng** | 3 | ~50 suất | ~350 suất |
| **Tổng** | 18 | **~290 suất** | **~2,030 suất** |

**Lưu ý**: Template showtimes (1 ngày) được lưu trong các file `hardcoded_showtimes_*.dart`, sau đó `hardcoded_seed_service.dart` sẽ tự động mở rộng cho 7 ngày.

---

## 🚀 Cách Sử Dụng

### 1️⃣ Từ Admin UI
1. Mở app → Vào màn hình **Seed Data (Admin)**
2. Nhấn nút **"Seed Hardcoded Data"**
3. Chờ process chạy xong (có progress log)
4. Xác nhận thành công

### 2️⃣ Từ Code (Debugging)
```dart
import 'package:cinema_flutter_app/services/seed/hardcoded_seed_service.dart';

// Seed all data
final service = HardcodedSeedService();
await service.seedAll();

// Clear all data
await service.clearAll();
```

---

## 🔍 Chi Tiết Files

### `hardcoded_movies_data.dart`
```dart
// Truy cập dữ liệu
HardcodedMoviesData.nowShowingMovies  // 8 phim đang chiếu
HardcodedMoviesData.comingSoonMovies  // 7 phim sắp chiếu
HardcodedMoviesData.allMovies         // Tất cả 15 phim
```

### `hardcoded_theaters_data.dart`
```dart
// Truy cập dữ liệu theo thành phố
HardcodedTheatersData.hanoiTheaters   // 7 rạp Hà Nội
HardcodedTheatersData.hcmTheaters     // 8 rạp TP.HCM
HardcodedTheatersData.daNangTheaters  // 3 rạp Đà Nẵng
HardcodedTheatersData.allTheaters     // Tất cả 18 rạp
```

### `hardcoded_screens_data.dart`
```dart
// Truy cập screens theo theater
HardcodedScreensData.screensByTheater["cgv-vincom-ba-trieu"]  // 4 phòng
HardcodedScreensData.allScreens  // Tất cả 72 phòng

// Helper methods
HardcodedScreensData.generateStandardSeats()  // 80 ghế
HardcodedScreensData.generateVIPSeats()       // 48 ghế
```

### `hardcoded_showtimes_data.dart`
```dart
// Showtimes Hà Nội (template - sẽ được mở rộng cho 7 ngày)
HardcodedShowtimesData.cgvVincomBaTrieuShowtimes  // CGV Vincom Bà Triệu
HardcodedShowtimesData.allHanoiShowtimes          // Tất cả rạp HN

// Helper (date sẽ được set bởi service)
HardcodedShowtimesData.createShowtime(...)  // Tạo showtime entry
```

**Quan trọng**: File này chỉ chứa template cho 1 ngày. Service `hardcoded_seed_service.dart` sẽ tự động lặp lại template này cho 7 ngày (29/10 - 04/11/2025).

---

## ✅ Validation Logic

### 1. Theater-Screen Mapping
```dart
// Service tự động kiểm tra:
if (screenTheaterId != theaterId) {
  throw Exception('Screen không thuộc theater!');
}
```

### 2. Duplicate Prevention
- Check `externalId` trước khi thêm mới
- Sử dụng Firestore batch để tối ưu performance

### 3. Data Integrity
- `movieId`, `theaterId`, `screenId` đều được validate
- Missing IDs sẽ bị skip và log warning

---

## 🎯 Ví dụ Sử Dụng

### VD1: Test với "Cục Vàng Của Ngoại" tại CGV Vincom Bà Triệu
```
✅ Chọn phim: "Cục Vàng Của Ngoại"
✅ Chọn rạp: "CGV Vincom Center Bà Triệu"
✅ Chọn ngày: 29/10, 30/10, 31/10, 01/11, 02/11, 03/11, hoặc 04/11/2025
✅ Chọn suất: 13:00, 16:00, 19:00, hoặc 21:30
✅ PHÒNG CHIẾU HIỂN THỊ: "Phòng 1" (thuộc CGV Vincom Bà Triệu)
```

**Kết quả mong đợi**: 
- ✅ Phòng chiếu là "CGV Vincom Center Bà Triệu - Phòng 1"
- ❌ KHÔNG còn hiện "BHD Star Vincom Phạm Ngọc Thạch - Phòng 3"
- ✅ Có thể đặt vé cho bất kỳ ngày nào trong 7 ngày tới

---

## 🐛 Troubleshooting

### Lỗi: "Screen không thuộc theater!"
**Nguyên nhân**: Dữ liệu cứng bị sai mapping  
**Cách fix**: Kiểm tra lại `hardcoded_screens_data.dart` và `hardcoded_showtimes_data.dart`

### Seed chạy chậm
**Nguyên nhân**: Firestore throttling  
**Cách fix**: Batch size đã set = 500, delay 100ms giữa các batch

### Dữ liệu bị duplicate
**Nguyên nhân**: Chạy seed nhiều lần  
**Cách fix**: Service tự động check `externalId`, nhưng có thể clear trước:
```dart
await HardcodedSeedService().clearAll();
await HardcodedSeedService().seedAll();
```

---

## 📝 Lưu ý

1. **KHÔNG SỬA** `movie_seed_data.dart` và `theater_seed_data.dart` - đó là dữ liệu gốc của user
2. **SỬA** các file `hardcoded_*_data.dart` nếu cần thay đổi screens/showtimes
3. **Thêm rạp mới**: Cập nhật cả 3 file (theaters, screens, showtimes)
4. **Thêm phim mới**: Chỉ cần sửa `hardcoded_movies_data.dart`

---

## 🎉 Kết Luận

Hệ thống seed data hiện tại:
- ✅ **Stable**: Không còn random
- ✅ **Scalable**: Dễ thêm rạp/phim mới
- ✅ **Maintainable**: Code rõ ràng, chia file logic
- ✅ **Correct**: 100% đúng nghiệp vụ

**Bug đã fix**: Theater-Screen mapping luôn chính xác! 🎊
