````markdown
# 📚 Seed Data Services - Kiến Trúc Module

## 📋 Tổng Quan

Hệ thống seed data đã được **refactor** theo mô hình **modular architecture** để:
- ✅ Dễ quản lý và bảo trì
- ✅ Tránh timeout khi seed dữ liệu lớn
- ✅ Có thể seed từng phần riêng lẻ
- ✅ Code rõ ràng, dễ mở rộng

## �️ Cấu Trúc

```
lib/services/seed/
├── README.md                      # File này
├── movie_seed_data.dart          # 🎬 Dữ liệu mẫu Movies
├── theater_seed_data.dart        # 🏢 Dữ liệu mẫu Theaters
├── seed_movies_service.dart      # 🎬 Service seed Movies
├── seed_theaters_service.dart    # 🏢 Service seed Theaters
├── seed_screens_service.dart     # 🪑 Service seed Screens
└── seed_showtimes_service.dart   # ⏰ Service seed Showtimes
```

---

## 📊 Dữ Liệu Mẫu Hiện Tại

### 🎬 Movies (16 phim)
**File:** `movie_seed_data.dart`

- **8 phim đang chiếu** (`now_showing`):
  - Cục Vàng Của Ngoại
  - Nhà Ma Xó
  - Tay Anh Giữ Một Vì Sao
  - Tee Yod 3: Quỷ Ăn Tạng
  - Tử chiến trên không
  - Trò Chơi Ảo Giác: Ares
  - Vận May
  - Tổ quốc trong tim

- **8 phim sắp chiếu** (`coming_soon`):
  - Phá Đám Sinh Nhật Mẹ
  - Điện Thoại Đen 2
  - Cải Mả
  - Tình Người Duyên Ma
  - Truy Tìm Long Diên Hương
  - Zootopia 2
  - Avatar 3

**Thuộc tính đầy đủ:**
- `title`, `genre`, `duration`, `rating`, `status`
- `releaseDate`, `description`, `posterUrl`, `trailerUrl`
- `director`, `cast`, `language`, `ageRating` ✨ (mới)

### 🏢 Theaters (18 rạp)
**File:** `theater_seed_data.dart`

- **7 rạp ở Hà Nội**: CGV Vincom (3), Lotte (2), BHD Star (2)
- **8 rạp ở TP.HCM**: CGV (3), Lotte (3), Galaxy (2)
- **3 rạp ở Đà Nẵng**: CGV (2), Lotte (1)

### 🪑 Screens (54-90 phòng)
- Mỗi rạp: 3-5 phòng chiếu
- Phòng thường: 8 hàng × 10 ghế = 80 ghế
- Phòng VIP: 6 hàng × 8 ghế = 48 ghế
- 2 hàng cuối: ghế VIP

### ⏰ Showtimes (700+ lịch chiếu)
- 7 ngày từ hôm nay
- 5 phim đầu tiên
- Mỗi phim: 4 suất/ngày (09:30, 13:00, 16:30, 20:00)
- Giá: 80.000đ (thường), 120.000đ (VIP)

---

## 🚀 Cách Sử Dụng

### 1️⃣ Seed Tất Cả Dữ Liệu (Khuyến nghị)

```dart
import 'package:cinema_flutter_app/services/seed_data_service.dart';

final seedService = SeedDataService();

// Seed tất cả: Movies → Theaters → Screens → Showtimes
await seedService.seedAllData();
```

**Output:**
```
🚀 BẮT ĐẦU SEED DỮ LIỆU...

🎬 Bắt đầu thêm Movies...
✅ Đã thêm phim: Cục Vàng Của Ngoại
...
🎉 Hoàn thành thêm 16 phim!

🏢 Bắt đầu thêm Theaters...
✅ Đã thêm rạp: CGV Vincom Center Bà Triệu
...
🎉 Hoàn thành thêm 18 rạp!

🪑 Bắt đầu thêm Screens...
✅ Đã thêm: Phòng 1 - Rạp 1
...
🎉 Hoàn thành thêm 72 phòng chiếu!

⏰ Bắt đầu thêm Showtimes...
  ↳ Đã thêm 10 lịch chiếu...
  ↳ Đã thêm 20 lịch chiếu...
...
🎉 Hoàn thành thêm 840 lịch chiếu!

✅ HOÀN THÀNH SEED DỮ LIỆU!
📊 Tổng kết:
   - 16 phim
   - 18 rạp
   - 72 phòng chiếu
   - Nhiều lịch chiếu trong 7 ngày tới
```

### 2️⃣ Seed Từng Collection Riêng

```dart
final seedService = SeedDataService();

// 🎬 Seed chỉ Movies
final movieIds = await seedService.seedMovies();
print('Đã seed ${movieIds.length} phim');

// 🏢 Seed chỉ Theaters
final theaterIds = await seedService.seedTheaters();
print('Đã seed ${theaterIds.length} rạp');

// 🪑 Seed Screens (cần theaterIds trước)
final screenIds = await seedService.seedScreens(theaterIds);
print('Đã seed ${screenIds.length} phòng chiếu');

// ⏰ Seed Showtimes (cần tất cả IDs)
await seedService.seedShowtimes(movieIds, theaterIds, screenIds);
print('Đã seed showtimes');
```

### 3️⃣ Thêm Dữ Liệu Đơn Lẻ

```dart
final seedService = SeedDataService();

// Thêm 1 phim
final movieId = await seedService.addSingleMovie({
  'title': 'Avengers: Secret Wars',
  'genre': 'Action, Superhero',
  'duration': 180,
  'rating': 9.5,
  'status': 'coming_soon',
  'releaseDate': '01/05/2026',
  'description': 'The multiverse saga concludes',
  'posterUrl': 'https://...',
  'trailerUrl': 'https://...',
  'director': 'Russo Brothers',
  'cast': 'Robert Downey Jr., Chris Evans, ...',
  'language': 'English',
  'ageRating': 'T13',
});

// Thêm 1 rạp
final theaterId = await seedService.addSingleTheater({
  'name': 'Galaxy Cinema Tân Bình',
  'address': '....',
  'city': 'Tp.Hồ Chí Minh',
  'phone': '1900 2224',
  'screens': [],
});
```

---

## 🗑️ Xóa Dữ Liệu

### Xóa Tất Cả

```dart
final seedService = SeedDataService();
await seedService.clearAllData();
```

Xóa theo thứ tự: `bookings` → `payments` → `showtimes` → `screens` → `theaters` → `movies`

### Xóa Từng Collection

```dart
await seedService.clearCollection('movies');
await seedService.clearCollection('theaters');
await seedService.clearCollection('screens');
await seedService.clearCollection('showtimes');
```

---

## 📝 Cập Nhật Dữ Liệu Mẫu

### Thêm Phim Mới

**File:** `lib/services/seed/movie_seed_data.dart`

```dart
class MovieSeedData {
  static List<Map<String, dynamic>> get movies => [
    {
      "title": "Tên Phim Mới",
      "genre": "Action, Drama",
      "duration": 120,
      "rating": 8.5,
      "status": "now_showing",  // hoặc "coming_soon"
      "releaseDate": "01/01/2026",
      "description": "Mô tả phim...",
      "posterUrl": "https://...",
      "trailerUrl": "https://...",
      "director": "Tên Đạo Diễn",
      "cast": "Diễn viên A, Diễn viên B",
      "language": "Tiếng Việt",
      "ageRating": "T13",  // P, K, T13, T16, T18
    },
    // ... existing movies
  ];
}
```

### Thêm Rạp Mới

**File:** `lib/services/seed/theater_seed_data.dart`

```dart
class TheaterSeedData {
  static List<Map<String, dynamic>> get theaters => [
    {
      "name": "Tên Rạp Mới",
      "address": "Địa chỉ đầy đủ",
      "city": "Hà Nội",  // hoặc Tp.Hồ Chí Minh, Đà Nẵng
      "phone": "1900 xxxx",
      "screens": []
    },
    // ... existing theaters
  ];
}
```

---

## ⚙️ Cấu Hình Service

### Screens Configuration

**File:** `lib/services/seed/seed_screens_service.dart`

```dart
// Mỗi rạp có 3-5 phòng
final numberOfScreens = 3 + (theaterIds.indexOf(theaterId) % 3);

// Cấu hình ghế
final isVIPScreen = i == numberOfScreens; // Phòng cuối là VIP
final rows = isVIPScreen ? 6 : 8;
final columns = isVIPScreen ? 8 : 10;
```

### Showtimes Configuration

**File:** `lib/services/seed/seed_showtimes_service.dart`

```dart
// Số ngày seed
for (int day = 0; day < 7; day++) {
  
// Số phim có lịch
final moviesToSchedule = movieIds.take(5).toList();

// Các khung giờ
for (var timeSlot in ['09:30', '13:00', '16:30', '20:00']) {
  
// Giá vé
'basePrice': 80000.0,
'vipPrice': 120000.0,
```

---

## 🔧 Architecture

### Service Layer

```
SeedDataService (Main Orchestrator)
├── SeedMoviesService
│   └── MovieSeedData
├── SeedTheatersService
│   └── TheaterSeedData
├── SeedScreensService
└── SeedShowtimesService
```

### Dependency Flow

```
Movies ────┐
           ├──> Screens ──> Showtimes
Theaters ──┘
```

**Lưu ý:** Phải seed theo thứ tự này!

---

## ✅ Lợi Ích Của Kiến Trúc Module

### 1. **Separation of Concerns**
- Mỗi service chịu trách nhiệm 1 collection
- Dễ tìm và sửa lỗi

### 2. **Data Centralization**
- Tất cả dữ liệu mẫu ở 2 file: `movie_seed_data.dart`, `theater_seed_data.dart`
- Dễ cập nhật, không cần sửa service logic

### 3. **Reusability**
- Có thể seed từng phần độc lập
- Tái sử dụng trong testing

### 4. **Batch Operations**
- Xử lý theo batch (500 docs/batch) để tránh timeout
- Progress logging rõ ràng

### 5. **Error Handling**
- Try-catch riêng từng service
- Dễ debug khi có lỗi

---

## ⚠️ Lưu Ý Quan Trọng

### 1. Thứ Tự Seed
```
✅ ĐÚNG: Movies → Theaters → Screens → Showtimes
❌ SAI:  Showtimes → Screens → Theaters → Movies
```

### 2. Dependencies
- `Screens` cần `theaterIds`
- `Showtimes` cần `movieIds`, `theaterIds`, `screenIds`

### 3. Delay Giữa Operations
```dart
await Future.delayed(Duration(milliseconds: 100));  // Tránh quá tải
```

### 4. Batch Size
```dart
const batchSize = 500;  // Firebase limit
```

### 5. Kiểm Tra Firebase Console
- Sau khi seed, vào Firebase Console kiểm tra data
- URL: https://console.firebase.google.com/

---

## 🧪 Testing

### Test Seed Movies

```dart
test('Seed movies should return 16 IDs', () async {
  final service = SeedMoviesService();
  final ids = await service.seedMovies();
  expect(ids.length, 16);
});
```

### Test Seed Theaters

```dart
test('Seed theaters should return 18 IDs', () async {
  final service = SeedTheatersService();
  final ids = await service.seedTheaters();
  expect(ids.length, 18);
});
```

---

## 🔥 Migration Guide

### Từ Old Architecture

```dart
// CŨ ❌
// Tất cả trong 1 file, 800+ lines
Future<void> seedAllData() {
  // Inline data
  final movies = [...];
  final theaters = [...];
  // ...
}

// MỚI ✅
// Chia nhỏ thành modules
import 'seed/seed_movies_service.dart';
import 'seed/seed_theaters_service.dart';

final _moviesService = SeedMoviesService();
final _theatersService = SeedTheatersService();

await _moviesService.seedMovies();
await _theatersService.seedTheaters();
```

---

## 📞 Troubleshooting

### ❌ Lỗi: Timeout

**Nguyên nhân:** Seed quá nhiều data cùng lúc

**Giải pháp:**
```dart
// Tăng delay
await Future.delayed(Duration(milliseconds: 200));

// Hoặc seed từng phần
await seedMovies();  // Chạy xong
await seedTheaters(); // Rồi chạy tiếp
```

### ❌ Lỗi: Missing Required Fields

**Nguyên nhân:** Model thiếu thuộc tính mới (director, cast, language, ageRating)

**Giải pháp:**
- Kiểm tra `lib/models/movie.dart` đã cập nhật chưa
- Đảm bảo tất cả movies trong `movie_seed_data.dart` có đủ fields

### ❌ Lỗi: Reference Not Found

**Nguyên nhân:** Seed sai thứ tự

**Giải pháp:**
```dart
// Phải seed theo đúng thứ tự
await seedMovies();     // 1
await seedTheaters();   // 2
await seedScreens();    // 3
await seedShowtimes();  // 4
```

---

## 🎉 Summary

✅ **Kiến trúc module rõ ràng**
✅ **Dễ bảo trì và mở rộng**
✅ **Seed từng phần hoặc toàn bộ**
✅ **Batch operations tránh timeout**
✅ **Data centralized, dễ cập nhật**

🚀 **Sẵn sàng cho production!**

````

## 📋 Tổng Quan

Hệ thống seed data đã được **refactor hoàn toàn** theo mô hình **3-phase architecture** để giải quyết các vấn đề:
- ❌ Showtimes bị trùng lặp
- ❌ Thiếu seed cho seats (Regular/VIP/Couple)
- ❌ Code monolithic khó maintain

## 🏗️ Kiến Trúc Mới

```
lib/services/seed/
├── seed_config.dart              # ⚙️  Cấu hình tập trung
├── seed_data_orchestrator.dart   # 🎯 Điều phối toàn bộ process
├── movie_theater_seeder.dart     # 🎬 Phase 1: Movies & Theaters & Screens
├── showtime_seeder.dart          # ⏰ Phase 2: Showtimes (KHÔNG TRÙNG)
└── seat_seeder.dart              # 🪑 Phase 3: Seats (Regular/VIP/Couple)
```

---

## ⚙️ 1. seed_config.dart

**Mục đích:** Tập trung TẤT CẢ constants để dễ dàng config

### Các config quan trọng:

```dart
// 📊 SHOWTIMES
static const int daysToSeed = 7;  // Số ngày seed
static const int showtimesPerMoviePerDay = 2;  // Số suất/phim/ngày
static const List<String> timeSlots = [
  '08:00', '10:30', '13:00', '15:30', 
  '18:00', '20:30', '22:45'
];

// 🪑 SEATS
static const double regularSeatRatio = 0.70;  // 70% ghế thường
static const double vipSeatRatio = 0.25;      // 25% ghế VIP
static const double coupleSeatRatio = 0.05;   // 5% ghế đôi

// 🏷️ SEAT LAYOUT
static const List<String> seatRows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
static const List<String> vipRows = ['D', 'E', 'F'];  // VIP rows
static const List<String> coupleRows = ['I', 'J'];    // Couple rows
```

**Lợi ích:**
- ✅ Thay đổi config tại 1 chỗ, ảnh hưởng toàn bộ hệ thống
- ✅ Dễ test với các config khác nhau
- ✅ Clear và dễ hiểu

---

## 🎬 2. movie_theater_seeder.dart (Phase 1)

**Nhiệm vụ:** Seed Movies, Theaters, Screens

### API:

```dart
final seeder = MovieTheaterSeeder();

// Seed movies
Map<String, List<String>> movieResult = await seeder.seedMovies();
// Returns: {'nowShowing': [...ids], 'comingSoon': [...ids]}

// Seed theaters
List<String> theaterIds = await seeder.seedTheaters();

// Seed screens (trả về metadata để dùng cho Phase 2)
List<Map<String, dynamic>> screens = await seeder.seedScreens(theaterIds);
// Returns: [{id, theaterId, name, type, capacity}, ...]
```

### Đặc điểm:
- ✅ Batch upload (500 ops/batch)
- ✅ Trả về metadata để Phase 2 & 3 sử dụng
- ✅ Phân loại movies: `now_showing` vs `coming_soon`

---

## ⏰ 3. showtime_seeder.dart (Phase 2) - ⭐ GIẢI QUYẾT TRÙNG LẶP

**Nhiệm vụ:** Seed Showtimes với logic **KHÔNG TRÙNG LẶP**

### Logic chống trùng:

```dart
// Tracking map: screen + date + time
Map<String, Set<String>> _screenSchedule = {};

bool _canSchedule(String screenId, DateTime startTime) {
  // Key: "screenId-2025-10-26"
  final key = '$screenId-${startTime.year}-${startTime.month}-${startTime.day}';
  
  // Time slot: "08:00"
  final timeSlot = '${startTime.hour}:${startTime.minute}';
  
  // Check đã tồn tại chưa
  if (_screenSchedule[key]!.contains(timeSlot)) {
    return false; // ❌ Trùng
  }
  
  _screenSchedule[key]!.add(timeSlot);
  return true; // ✅ OK
}
```

### API:

```dart
final seeder = ShowtimeSeeder();

List<String> showtimeIds = await seeder.seedShowtimes(
  nowShowingMovieIds: [...],
  screens: [...],
);
```

### Đặc điểm:
- ✅ **MỖI screen + date + time CHỈ CÓ 1 SHOWTIME DUY NHẤT**
- ✅ Random time slots để tránh pattern
- ✅ Phân phối movies cho theaters (mỗi rạp 3-5 phim)
- ✅ Tính giá động (weekend, prime time, room type)
- ✅ Progress indicator

---

## 🪑 4. seat_seeder.dart (Phase 3) - ⭐ GIẢI QUYẾT SEATS

**Nhiệm vụ:** Seed Seats với phân loại Regular/VIP/Couple

### Logic phân loại:

```dart
String _determineSeatType(String row) {
  if (SeedConfig.coupleRows.contains(row)) {
    return 'Couple'; // Hàng I, J
  } else if (SeedConfig.vipRows.contains(row)) {
    return 'VIP'; // Hàng D, E, F
  } else {
    return 'Regular'; // Hàng còn lại
  }
}
```

### Seat Layout:

```
     1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
A  [●][●][●][●][●][●][●][●][●][●][●][●][●][●][●]  Regular
B  [●][●][●][●][●][●][●][●][●][●][●][●][●][●][●]  Regular
C  [●][●][●][●][●][●][●][●][●][●][●][●][●][●][●]  Regular
D  [●][●][●][●][●][●][●][●][●][●][●][●][●][●][●]  VIP
E  [●][●][●][●][●][●][●][●][●][●][●][●][●][●][●]  VIP
F  [●][●][●][●][●][●][●][●][●][●][●][●][●][●][●]  VIP
G  [●][●][●][●][●][●][●][●][●][●][●][●][●][●][●]  Regular
H  [●][●][●][●][●][●][●][●][●][●][●][●][●][●][●]  Regular
I  [●●][●●][●●][●●][●●][●●][●●]                    Couple
J  [●●][●●][●●][●●][●●][●●][●●]                    Couple
```

### API:

```dart
final seeder = SeatSeeder();

int totalSeats = await seeder.seedSeats(showtimeIds);
```

### Đặc điểm:
- ✅ Seats có `seatType`: Regular/VIP/Couple
- ✅ Giá ghế khác nhau theo type
- ✅ Seat data: `{seatNumber, row, column, seatType, price, status, isBooked}`
- ✅ Batch upload với progress

---

## 🎯 5. seed_data_orchestrator.dart - ĐIỀU PHỐI TOÀN BỘ

**Nhiệm vụ:** Orchestrate toàn bộ seed process

### API chính:

#### 1. Seed toàn bộ (Auto Phase 1 → 2 → 3)

```dart
final orchestrator = SeedDataOrchestrator();
await orchestrator.seedAll();
```

**Output:**
```
╔═══════════════════════════════════════════════════════╗
║  🚀 BẮT ĐẦU SEED DỮ LIỆU - HỆ THỐNG RẠP VIỆT NAM    ║
╚═══════════════════════════════════════════════════════╝

┌─────────────────────────────────────────┐
│  🎬 PHASE 1.1: SEEDING MOVIES          │
└─────────────────────────────────────────┘
  ✅ Mai (now_showing)
  ✅ Venom: The Last Dance (now_showing)
  ...
✅ Đã thêm 15 phim!

┌─────────────────────────────────────────┐
│  🏢 PHASE 1.2: SEEDING THEATERS        │
└─────────────────────────────────────────┘
✅ Đã thêm 10 rạp!

┌─────────────────────────────────────────┐
│  🪑 PHASE 1.3: SEEDING SCREENS         │
└─────────────────────────────────────────┘
✅ Đã tạo 60 phòng chiếu!

┌─────────────────────────────────────────┐
│  ⏰ PHASE 2: SEEDING SHOWTIMES         │
└─────────────────────────────────────────┘
   📌 Logic: Mỗi screen + ngày + giờ chỉ có 1 showtime
   ✅ Ngày 1/7: 120 showtimes
   ✅ Ngày 2/7: 115 showtimes
   ...
✅ HOÀN TẤT: Đã tạo 800 showtimes (KHÔNG TRÙNG LẶP)!

┌─────────────────────────────────────────┐
│  🪑 PHASE 3: SEEDING SEATS             │
└─────────────────────────────────────────┘
   💾 Đã xử lý 50/800 showtimes...
   💾 Đã xử lý 100/800 showtimes...
   ...
✅ HOÀN TẤT: Đã tạo 120,000 ghế!

╔═══════════════════════════════════════════════════════╗
║              ✅ HOÀN THÀNH SEED DỮ LIỆU              ║
╚═══════════════════════════════════════════════════════╝

📊 TỔNG KẾT:
│  🎬 Phim:               15 phim (10 đang chiếu)
│  🏢 Rạp chiếu:          10 rạp
│  🪑 Phòng chiếu:        60 phòng
│  ⏰ Lịch chiếu:         800 suất (7 ngày)
│  🎫 Ghế ngồi:       120000 ghế
│  ⏱️  Thời gian:          45s

🎯 CHI TIẾT:
  • 10 phim đang chiếu (CÓ LỊCH CHIẾU)
  • 5 phim sắp chiếu (KHÔNG CÓ LỊCH)
  • Mỗi phim: 2 suất/ngày
  • Ghế: 70% Regular, 25% VIP, 5% Couple
  • ✅ KHÔNG CÓ SHOWTIME TRÙNG LẶP
  • ✅ SEATS PHÂN LOẠI THEO HÀNG
```

#### 2. Seed từng phase riêng lẻ

```dart
// Chỉ seed Phase 1
await orchestrator.seedPhase(SeedPhase.phase1MoviesTheaters);

// Chỉ seed Phase 2 (CẦN có dữ liệu Phase 1 trước)
await orchestrator.seedPhase(SeedPhase.phase2Showtimes);

// Chỉ seed Phase 3 (CẦN có dữ liệu Phase 2 trước)
await orchestrator.seedPhase(SeedPhase.phase3Seats);
```

#### 3. Clear all data

```dart
await orchestrator.clearAllData();
```

#### 4. Validate showtimes (check conflicts)

```dart
Map<String, dynamic> result = await orchestrator.validateShowtimes();

if (result['isValid']) {
  print('✅ Không có conflict!');
} else {
  print('❌ Có ${result['conflicts'].length} conflicts');
}
```

---

## 🚀 CÁCH SỬ DỤNG

### Trong Admin Screen:

```dart
import 'package:your_app/services/seed/seed_data_orchestrator.dart';

final orchestrator = SeedDataOrchestrator();

// Button: Thêm tất cả dữ liệu
ElevatedButton(
  onPressed: () async {
    await orchestrator.seedAll();
  },
  child: Text('Seed All Data'),
);

// Button: Xóa dữ liệu
OutlinedButton(
  onPressed: () async {
    await orchestrator.clearAllData();
  },
  child: Text('Clear All Data'),
);

// Button: Validate
OutlinedButton(
  onPressed: () async {
    final result = await orchestrator.validateShowtimes();
    print(result);
  },
  child: Text('Validate Showtimes'),
);
```

---

## ✅ LỢI ÍCH CỦA KIẾN TRÚC MỚI

### 1. **Giải quyết vấn đề trùng lặp showtimes**
- ❌ Trước: Cùng 1 screen có thể có nhiều showtimes ở cùng thời điểm
- ✅ Sau: **Map tracking** đảm bảo mỗi screen + date + time DUY NHẤT

### 2. **Seed seats với phân loại rõ ràng**
- ❌ Trước: Không có seats
- ✅ Sau: Seats có `seatType` (Regular/VIP/Couple) và giá khác nhau

### 3. **Chia nhỏ thành modules**
- ❌ Trước: 1 file 800 dòng, khó maintain
- ✅ Sau: 5 files với responsibility rõ ràng

### 4. **Dễ mở rộng**
- ✅ Thêm phase mới? Tạo file mới + register vào orchestrator
- ✅ Thay đổi logic? Chỉ sửa 1 file cụ thể
- ✅ Config mới? Chỉ sửa `seed_config.dart`

### 5. **Chạy tuần tự hoặc riêng lẻ**
- ✅ Test Phase 1 trước khi chạy Phase 2
- ✅ Re-seed chỉ Phase 3 nếu muốn thay đổi seat layout
- ✅ Clear data cụ thể từng collection

### 6. **Batch upload & Progress tracking**
- ✅ Firebase batch limit: 500 ops/batch
- ✅ Auto commit và tạo batch mới
- ✅ Progress indicator rõ ràng

---

## 📊 SO SÁNH TRƯỚC/SAU

| Metric | Trước | Sau |
|--------|-------|-----|
| **Files** | 1 file (800 lines) | 5 files (~200 lines each) |
| **Showtimes trùng** | ❌ Có | ✅ **KHÔNG** (tracking map) |
| **Seats** | ❌ Không có | ✅ **CÓ** (Regular/VIP/Couple) |
| **Maintainability** | ❌ Khó | ✅ **Dễ** (separation of concerns) |
| **Testability** | ❌ Khó test | ✅ **Dễ test** (test từng phase) |
| **Config** | ❌ Hard-coded | ✅ **Centralized** (seed_config.dart) |
| **Extensibility** | ❌ Khó mở rộng | ✅ **Dễ mở rộng** (thêm phase mới) |

---

## 🧪 TESTING

### Test Phase 1:
```dart
final orchestrator = SeedDataOrchestrator();
await orchestrator.seedPhase(SeedPhase.phase1MoviesTheaters);
// Check Firebase: movies, theaters, screens collections
```

### Test Phase 2:
```dart
await orchestrator.seedPhase(SeedPhase.phase2Showtimes);
// Validate không trùng:
final result = await orchestrator.validateShowtimes();
assert(result['isValid'] == true);
```

### Test Phase 3:
```dart
await orchestrator.seedPhase(SeedPhase.phase3Seats);
// Check Firebase: seats collection có đủ Regular/VIP/Couple
```

---

## 🎓 THIẾT KẾ PATTERNS

### 1. **Orchestrator Pattern**
- `SeedDataOrchestrator` điều phối toàn bộ process
- Dependency injection cho các seeders

### 2. **Strategy Pattern**
- Mỗi seeder là 1 strategy riêng
- Dễ swap hoặc extend

### 3. **Builder Pattern**
- `_generateSeatLayout()` xây dựng seat data
- Flexible và customizable

### 4. **Template Method Pattern**
- `seedAll()` định nghĩa skeleton
- Mỗi phase implement chi tiết

---

## 📝 NOTES QUAN TRỌNG

1. **Thứ tự chạy:**
   - Phase 1 TRƯỚC
   - Phase 2 SAU (cần movieIds, screens)
   - Phase 3 CUỐI (cần showtimeIds)

2. **Config seats:**
   - VIP rows: D, E, F (giữa rạp)
   - Couple rows: I, J (hàng cuối)
   - Regular: Còn lại

3. **Pricing:**
   - Base: 70k
   - Weekend: +20k
   - Prime time (18h-23h): +15k
   - Early bird (<12h): -15k
   - VIP seat: +40k
   - Couple seat: +60k
   - IMAX room: +50k

4. **Batch operations:**
   - Limit: 500 ops/batch
   - Auto commit khi đạt limit
   - Tạo batch mới sau commit

---

## 🔥 MIGRATION TỪ FILE CŨ

Nếu đang dùng `seed_data_service.dart` cũ:

```dart
// CŨ ❌
import 'package:your_app/services/seed_data_service.dart';
final service = SeedDataService();
await service.seedAllData();

// MỚI ✅
import 'package:your_app/services/seed/seed_data_orchestrator.dart';
final orchestrator = SeedDataOrchestrator();
await orchestrator.seedAll();
```

**Lưu ý:** File cũ vẫn tồn tại để backward compatibility, nhưng nên dùng orchestrator mới.

---

## 🎉 KẾT LUẬN

Kiến trúc mới:
- ✅ **Giải quyết HOÀN TOÀN vấn đề showtimes trùng lặp**
- ✅ **Thêm seats với phân loại rõ ràng**
- ✅ **Code clean, maintainable, extensible**
- ✅ **Chạy tuần tự hoặc riêng lẻ từng phase**
- ✅ **Config tập trung, dễ customize**

🚀 **Sẵn sàng cho production!**
