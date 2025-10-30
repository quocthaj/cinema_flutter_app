# 🎯 HƯỚNG DẪN CHI TIẾT: Sử Dụng UI Admin để Seed Data

## 📍 PHẦN 1: Các Cách Mở UI Admin

### ✅ Cách đã cài đặt: FloatingActionButton trong Home Screen

**File đã được cập nhật:** `lib/screens/home/home_screen.dart`

```dart
// Import đã thêm
import '../admin/seed_data_screen.dart';

// FloatingActionButton đã thêm vào Scaffold
floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SeedDataScreen(),
      ),
    );
  },
  icon: const Icon(Icons.admin_panel_settings),
  label: const Text('Admin'),
  backgroundColor: Colors.deepPurple,
  tooltip: 'Mở Admin Panel để seed dữ liệu',
),
```

**Cách sử dụng:**
1. Chạy app: `flutter run`
2. Ở màn hình Home, nhìn góc dưới bên phải
3. Nhấn nút **"Admin"** màu tím với icon ⚙️
4. Màn hình Admin sẽ hiện ra

---

### 🔧 Cách 2: Thêm vào Drawer Menu (Tùy chọn)

Nếu muốn thêm vào menu drawer thay vì floating button:

```dart
// lib/screens/home/custom_drawer.dart
import '../admin/seed_data_screen.dart';

// Thêm ListTile này vào Drawer
ListTile(
  leading: const Icon(
    Icons.admin_panel_settings,
    color: Colors.deepPurple,
  ),
  title: const Text('Admin - Seed Data'),
  subtitle: const Text('Thêm dữ liệu mẫu'),
  onTap: () {
    Navigator.pop(context); // Đóng drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SeedDataScreen(),
      ),
    );
  },
),
```

---

### 🚀 Cách 3: Thêm vào app_routes.dart (Cách chuyên nghiệp)

```dart
// lib/config/app_routes.dart
import '../screens/admin/seed_data_screen.dart';

class AppRoutes {
  static const String seedData = '/admin/seed-data';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case seedData:
        return MaterialPageRoute(
          builder: (_) => const SeedDataScreen(),
        );
      // ... các routes khác
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Không tìm thấy trang')),
          ),
        );
    }
  }
}

// Sử dụng:
Navigator.pushNamed(context, AppRoutes.seedData);
```

---

## 🔄 PHẦN 2: Cách Hoạt Động của Seed Data System

### 2.1. Kiến trúc tổng quan

```
User nhấn nút "Thêm dữ liệu mẫu"
        ↓
seed_data_screen.dart (UI Layer)
        ↓
seed_data_service.dart (Business Logic)
        ↓
FirebaseFirestore.instance (Firebase SDK)
        ↓
Firebase Cloud Firestore (Backend)
```

---

### 2.2. Flow chi tiết khi nhấn nút "Thêm dữ liệu mẫu"

#### **Bước 1: UI nhận sự kiện**
```dart
// lib/screens/admin/seed_data_screen.dart
ElevatedButton.icon(
  onPressed: _isLoading ? null : _seedAllData,
  icon: const Icon(Icons.upload),
  label: const Text('Thêm tất cả dữ liệu mẫu'),
)
```

#### **Bước 2: UI gọi Service**
```dart
Future<void> _seedAllData() async {
  setState(() {
    _isLoading = true;
    _statusMessage = 'Đang thêm dữ liệu...';
  });

  try {
    // 🔥 GỌI SERVICE ĐỂ SEED DATA
    await _seedService.seedAllData();
    
    setState(() {
      _statusMessage = '✅ Thêm dữ liệu thành công!';
    });
  } catch (e) {
    setState(() {
      _statusMessage = '❌ Lỗi: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
```

#### **Bước 3: Service thực thi theo thứ tự**

```dart
// lib/services/seed_data_service.dart
Future<void> seedAllData() async {
  print('🚀 BẮT ĐẦU SEED DỮ LIỆU...\n');

  // 1️⃣ SEED MOVIES (5 phim)
  final movieIds = await seedMovies();
  await Future.delayed(Duration(seconds: 1));

  // 2️⃣ SEED THEATERS (4 rạp)
  final theaterIds = await seedTheaters();
  await Future.delayed(Duration(seconds: 1));

  // 3️⃣ SEED SCREENS (12 phòng chiếu: 3 phòng × 4 rạp)
  final screenIds = await seedScreens(theaterIds);
  await Future.delayed(Duration(seconds: 1));

  // 4️⃣ SEED SHOWTIMES (60+ lịch chiếu trong 7 ngày)
  await seedShowtimes(movieIds, theaterIds, screenIds);

  print('✅ HOÀN THÀNH SEED DỮ LIỆU!');
}
```

---

### 2.3. Chi tiết từng bước Seed

#### **BƯỚC 3.1: Seed Movies**

```dart
Future<List<String>> seedMovies() async {
  print('🎬 Bắt đầu thêm Movies...');
  
  final movies = [
    {
      'title': 'Avatar: The Way of Water',
      'genre': 'Sci-Fi, Adventure',
      'duration': 192,
      'rating': 8.5,
      'posterUrl': 'https://image.tmdb.org/t/p/w500/...',
      'status': 'now_showing',
      'releaseDate': '16/12/2022',
      'description': '...',
      'trailerUrl': 'https://www.youtube.com/...',
    },
    // ... 4 phim khác
  ];

  List<String> movieIds = [];
  
  for (var movieData in movies) {
    // 🔥 THÊM VÀO FIRESTORE
    final docRef = await FirebaseFirestore.instance
        .collection('movies')
        .add(movieData);
    
    movieIds.add(docRef.id);
    print('✅ Đã thêm phim: ${movieData['title']}');
  }

  return movieIds; // Trả về IDs để dùng cho showtimes
}
```

**Firestore operation:**
```javascript
// Firebase Console sẽ tạo:
movies/
  ├── {auto-generated-id-1}/
  │   ├── title: "Avatar: The Way of Water"
  │   ├── genre: "Sci-Fi, Adventure"
  │   ├── duration: 192
  │   ├── rating: 8.5
  │   └── ...
  ├── {auto-generated-id-2}/
  │   └── ... (Mai)
  ├── {auto-generated-id-3}/
  │   └── ... (Deadpool & Wolverine)
  ├── {auto-generated-id-4}/
  │   └── ... (Oppenheimer)
  └── {auto-generated-id-5}/
      └── ... (The Marvels)
```

---

#### **BƯỚC 3.2: Seed Theaters**

```dart
Future<List<String>> seedTheaters() async {
  print('🏢 Bắt đầu thêm Theaters...');
  
  final theaters = [
    {
      'name': 'CGV Vincom Center',
      'address': '191 Bà Triệu, Hai Bà Trưng',
      'city': 'Hà Nội',
      'phone': '1900 6017',
      'screens': [], // Sẽ cập nhật sau khi tạo screens
    },
    // ... 3 rạp khác (Galaxy, Lotte, BHD)
  ];

  List<String> theaterIds = [];
  
  for (var theaterData in theaters) {
    final docRef = await FirebaseFirestore.instance
        .collection('theaters')
        .add(theaterData);
    
    theaterIds.add(docRef.id);
    print('✅ Đã thêm rạp: ${theaterData['name']}');
  }

  return theaterIds;
}
```

**Kết quả trên Firestore:**
```javascript
theaters/
  ├── {theater-id-1}/ → CGV Vincom (Hà Nội)
  ├── {theater-id-2}/ → Galaxy Nguyễn Du (HCM)
  ├── {theater-id-3}/ → Lotte Đà Nẵng
  └── {theater-id-4}/ → BHD Star (HCM)
```

---

#### **BƯỚC 3.3: Seed Screens**

```dart
Future<List<String>> seedScreens(List<String> theaterIds) async {
  print('🪑 Bắt đầu thêm Screens...');
  
  List<String> screenIds = [];

  // Mỗi rạp có 3 phòng chiếu
  for (var theaterId in theaterIds) {
    for (int i = 1; i <= 3; i++) {
      final isVIPScreen = i == 3;
      final rows = isVIPScreen ? 6 : 8;
      final columns = isVIPScreen ? 8 : 10;
      
      // TẠO SƠ ĐỒ GHẾ
      List<Map<String, dynamic>> seats = [];
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          final seatId = '${String.fromCharCode(65 + row)}${col + 1}';
          final isVIPSeat = isVIPScreen || row >= rows - 2;
          
          seats.add({
            'id': seatId,
            'type': isVIPSeat ? 'vip' : 'standard',
            'isAvailable': true,
          });
        }
      }

      final screenData = {
        'theaterId': theaterId,
        'name': 'Phòng $i${isVIPScreen ? ' (VIP)' : ''}',
        'totalSeats': rows * columns,
        'rows': rows,
        'columns': columns,
        'seats': seats,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('screens')
          .add(screenData);
      
      screenIds.add(docRef.id);

      // CẬP NHẬT LẠI THEATER VỚI SCREEN ID
      await FirebaseFirestore.instance
          .collection('theaters')
          .doc(theaterId)
          .update({
        'screens': FieldValue.arrayUnion([docRef.id])
      });
    }
  }

  return screenIds;
}
```

**Kết quả:**
```javascript
screens/
  ├── {screen-id-1}/ → Phòng 1 (CGV Vincom) - 80 ghế
  ├── {screen-id-2}/ → Phòng 2 (CGV Vincom) - 80 ghế
  ├── {screen-id-3}/ → Phòng 3 (VIP) (CGV Vincom) - 48 ghế
  ├── ... (9 phòng khác)
  └── {screen-id-12}/ → Phòng 3 (VIP) (BHD Star)

// Và theaters được cập nhật:
theaters/{theater-id-1}/screens = [screen-id-1, screen-id-2, screen-id-3]
```

---

#### **BƯỚC 3.4: Seed Showtimes**

```dart
Future<void> seedShowtimes(
  List<String> movieIds, 
  List<String> theaterIds, 
  List<String> screenIds
) async {
  print('⏰ Bắt đầu thêm Showtimes...');
  
  int count = 0;
  final now = DateTime.now();

  // TẠO LỊCH CHIẾU CHO 7 NGÀY TỚI
  for (int day = 0; day < 7; day++) {
    final date = now.add(Duration(days: day));
    
    // Mỗi phim có 3 suất chiếu/ngày
    for (var movieId in movieIds.take(3)) { // Chỉ lấy 3 phim đầu
      for (var timeSlot in ['10:00', '14:30', '19:00']) {
        final timeParts = timeSlot.split(':');
        final startTime = DateTime(
          date.year, date.month, date.day,
          int.parse(timeParts[0]), int.parse(timeParts[1])
        );
        final endTime = startTime.add(Duration(minutes: 120));

        // Random một screen
        final screenId = screenIds[count % screenIds.length];
        
        // Lấy thông tin screen để biết theaterId và totalSeats
        final screenDoc = await FirebaseFirestore.instance
            .collection('screens')
            .doc(screenId)
            .get();
        
        final theaterId = screenDoc.data()?['theaterId'] ?? theaterIds[0];
        final totalSeats = screenDoc.data()?['totalSeats'] ?? 80;

        final showtimeData = {
          'movieId': movieId,
          'screenId': screenId,
          'theaterId': theaterId,
          'startTime': Timestamp.fromDate(startTime),
          'endTime': Timestamp.fromDate(endTime),
          'basePrice': 80000.0,
          'vipPrice': 120000.0,
          'availableSeats': totalSeats,
          'bookedSeats': [],
          'status': 'active',
        };

        await FirebaseFirestore.instance
            .collection('showtimes')
            .add(showtimeData);
        
        count++;
      }
    }
  }

  print('🎉 Hoàn thành thêm $count lịch chiếu!');
}
```

**Kết quả:**
```javascript
showtimes/
  ├── {showtime-id-1}/
  │   ├── movieId: "movie-1"
  │   ├── screenId: "screen-1"
  │   ├── theaterId: "theater-1"
  │   ├── startTime: Timestamp(2025-10-24 10:00)
  │   ├── endTime: Timestamp(2025-10-24 12:00)
  │   ├── basePrice: 80000
  │   ├── vipPrice: 120000
  │   ├── availableSeats: 80
  │   ├── bookedSeats: []
  │   └── status: "active"
  ├── ... (60+ showtimes khác)
  └── {showtime-id-63}/

// Phân bố:
// - 7 ngày × 3 phim × 3 suất/ngày = 63 showtimes
```

---

## 📊 PHẦN 3: Danh Sách Dữ Liệu Mẫu Được Thêm

### 3.1. MOVIES (5 phim)

| # | Tên Phim | Thể Loại | Thời Lượng | Rating | Trạng Thái |
|---|----------|----------|------------|--------|------------|
| 1 | Avatar: The Way of Water | Sci-Fi, Adventure | 192 phút | 8.5 | now_showing |
| 2 | Mai | Drama, Romance | 131 phút | 7.8 | now_showing |
| 3 | Deadpool & Wolverine | Action, Comedy | 128 phút | 8.2 | now_showing |
| 4 | Oppenheimer | Biography, Drama | 180 phút | 8.9 | now_showing |
| 5 | The Marvels | Action, Adventure | 105 phút | 7.1 | coming_soon |

---

### 3.2. THEATERS (4 rạp)

| # | Tên Rạp | Địa Chỉ | Thành Phố | Hotline |
|---|---------|---------|-----------|---------|
| 1 | CGV Vincom Center | 191 Bà Triệu, Hai Bà Trưng | Hà Nội | 1900 6017 |
| 2 | Galaxy Cinema Nguyễn Du | 116 Nguyễn Du, Quận 1 | Hồ Chí Minh | 1900 2224 |
| 3 | Lotte Cinema Đà Nẵng | 255 Hùng Vương, Quận Hải Châu | Đà Nẵng | 1900 5454 |
| 4 | BHD Star Cineplex | 3/2 Vincom Plaza, Quận 10 | Hồ Chí Minh | 1900 2099 |

---

### 3.3. SCREENS (12 phòng chiếu)

**Mỗi rạp có 3 phòng:**
- **Phòng 1**: 8 hàng × 10 ghế = 80 ghế (Standard + VIP ở 2 hàng cuối)
- **Phòng 2**: 8 hàng × 10 ghế = 80 ghế (Standard + VIP ở 2 hàng cuối)
- **Phòng 3 (VIP)**: 6 hàng × 8 ghế = 48 ghế (Toàn VIP)

**Tổng cộng:** 4 rạp × 3 phòng = **12 phòng chiếu**

**Sơ đồ ghế mẫu (Phòng 1):**
```
A1 A2 A3 A4 A5 A6 A7 A8 A9 A10  [Standard]
B1 B2 B3 B4 B5 B6 B7 B8 B9 B10  [Standard]
C1 C2 C3 C4 C5 C6 C7 C8 C9 C10  [Standard]
D1 D2 D3 D4 D5 D6 D7 D8 D9 D10  [Standard]
E1 E2 E3 E4 E5 E6 E7 E8 E9 E10  [Standard]
F1 F2 F3 F4 F5 F6 F7 F8 F9 F10  [Standard]
G1 G2 G3 G4 G5 G6 G7 G8 G9 G10  [VIP] 💺
H1 H2 H3 H4 H5 H6 H7 H8 H9 H10  [VIP] 💺
```

---

### 3.4. SHOWTIMES (60+ lịch chiếu)

**Công thức:**
```
7 ngày × 3 phim × 3 suất chiếu = 63 showtimes
```

**Khung giờ chiếu:**
- Suất 1: **10:00 - 12:00**
- Suất 2: **14:30 - 16:30**
- Suất 3: **19:00 - 21:00**

**Ví dụ lịch chiếu ngày 24/10/2025:**

| Giờ | Phim | Rạp | Phòng | Giá Standard | Giá VIP |
|-----|------|-----|-------|--------------|---------|
| 10:00 | Avatar | CGV Vincom | Phòng 1 | 80.000đ | 120.000đ |
| 10:00 | Mai | Galaxy Nguyễn Du | Phòng 2 | 80.000đ | 120.000đ |
| 10:00 | Deadpool | Lotte Đà Nẵng | Phòng 3 | 80.000đ | 120.000đ |
| 14:30 | Avatar | BHD Star | Phòng 1 | 80.000đ | 120.000đ |
| 14:30 | Mai | CGV Vincom | Phòng 2 | 80.000đ | 120.000đ |
| 14:30 | Deadpool | Galaxy Nguyễn Du | Phòng 3 | 80.000đ | 120.000đ |
| 19:00 | Avatar | Lotte Đà Nẵng | Phòng 1 | 80.000đ | 120.000đ |
| 19:00 | Mai | BHD Star | Phòng 2 | 80.000đ | 120.000đ |
| 19:00 | Deadpool | CGV Vincom | Phòng 3 | 80.000đ | 120.000đ |

*(Lặp lại pattern này cho 7 ngày)*

---

## 🔍 PHẦN 4: Kiểm Tra và Xác Nhận Dữ Liệu

### 4.1. Kiểm tra trong App (Realtime)

Sau khi seed xong, bạn có thể thấy ngay:

1. **Màn hình Home**:
   - Banner carousel hiển thị phim
   - Section "Phim đang chiếu" có 4 phim
   - Section "Phim sắp chiếu" có 1 phim

2. **Màn hình Movies**:
   - Tab "Đang chiếu": 4 phim
   - Tab "Sắp chiếu": 1 phim

3. **Màn hình Theaters**:
   - Danh sách 4 rạp với địa chỉ đầy đủ

4. **Màn hình Movie Detail** (click vào một phim):
   - Thông tin chi tiết phim
   - Danh sách lịch chiếu (nếu có)

---

### 4.2. Kiểm tra trên Firebase Console

#### **Bước 1: Mở Firebase Console**
1. Truy cập: https://console.firebase.google.com/
2. Chọn project của bạn: `cinema-flutter-app`
3. Click vào **Firestore Database** ở menu bên trái

#### **Bước 2: Xem Collections**

Bạn sẽ thấy:

```
📂 Root Collections:
   ├── 📁 movies (5 documents)
   ├── 📁 theaters (4 documents)
   ├── 📁 screens (12 documents)
   ├── 📁 showtimes (63 documents)
   ├── 📁 bookings (0 documents - chưa có)
   ├── 📁 payments (0 documents - chưa có)
   └── 📁 users (số lượng = số user đã đăng ký)
```

#### **Bước 3: Kiểm tra chi tiết một Movie**

Click vào `movies` → Click vào một document → Bạn sẽ thấy:

```
Document ID: abc123xyz (auto-generated)

Fields:
┌─────────────┬────────────────────────────────┐
│ Field       │ Value                          │
├─────────────┼────────────────────────────────┤
│ title       │ Avatar: The Way of Water       │
│ genre       │ Sci-Fi, Adventure              │
│ duration    │ 192                            │
│ rating      │ 8.5                            │
│ posterUrl   │ https://image.tmdb.org/...     │
│ status      │ now_showing                    │
│ releaseDate │ 16/12/2022                     │
│ description │ Jake Sully và Neytiri...       │
│ trailerUrl  │ https://www.youtube.com/...    │
└─────────────┴────────────────────────────────┘
```

#### **Bước 4: Kiểm tra Showtimes**

Click vào `showtimes` → Click vào một document:

```
Document ID: def456uvw

Fields:
┌─────────────────┬────────────────────────────────┐
│ Field           │ Value                          │
├─────────────────┼────────────────────────────────┤
│ movieId         │ abc123xyz                      │
│ screenId        │ ghi789rst                      │
│ theaterId       │ jkl012mno                      │
│ startTime       │ October 24, 2025 at 10:00:00 AM│
│ endTime         │ October 24, 2025 at 12:00:00 PM│
│ basePrice       │ 80000                          │
│ vipPrice        │ 120000                         │
│ availableSeats  │ 80                             │
│ bookedSeats     │ [ ] (empty array)              │
│ status          │ active                         │
└─────────────────┴────────────────────────────────┘
```

#### **Bước 5: Kiểm tra Screens**

Click vào `screens` → Click vào một document:

```
Document ID: ghi789rst

Fields:
┌─────────────┬────────────────────────────────┐
│ Field       │ Value                          │
├─────────────┼────────────────────────────────┤
│ theaterId   │ jkl012mno                      │
│ name        │ Phòng 1                        │
│ totalSeats  │ 80                             │
│ rows        │ 8                              │
│ columns     │ 10                             │
│ seats       │ [Array - 80 items]            │
└─────────────┴────────────────────────────────┘

// Click vào seats array:
0: {id: "A1", type: "standard", isAvailable: true}
1: {id: "A2", type: "standard", isAvailable: true}
2: {id: "A3", type: "standard", isAvailable: true}
...
79: {id: "H10", type: "vip", isAvailable: true}
```

---

### 4.3. Kiểm tra bằng Flutter DevTools

1. Chạy app với `flutter run`
2. Mở DevTools (link hiện trong terminal)
3. Tab **Network** → Xem requests tới Firestore
4. Tab **Logging** → Xem các log prints từ seed service

---

### 4.4. Test Query trong App

Bạn có thể test ngay trong app:

```dart
// Test lấy movies
final movies = await FirestoreService().getMoviesStream().first;
print('Số lượng phim: ${movies.length}'); // Should be 5

// Test lấy theaters
final theaters = await FirestoreService().getTheatersStream().first;
print('Số lượng rạp: ${theaters.length}'); // Should be 4

// Test lấy showtimes của một phim
final showtimes = await FirestoreService()
    .getShowtimesByMovie(movies[0].id)
    .first;
print('Số lịch chiếu của ${movies[0].title}: ${showtimes.length}');
```

---

## 🗑️ XÓA TẤT CẢ DỮ LIỆU

### Cách 1: Dùng nút "Xóa tất cả dữ liệu" trong UI Admin

```dart
// Trong seed_data_screen.dart
OutlinedButton.icon(
  onPressed: _isLoading ? null : _clearAllData,
  icon: const Icon(Icons.delete_forever),
  label: const Text('Xóa tất cả dữ liệu'),
)

Future<void> _clearAllData() async {
  // Hiển thị dialog xác nhận
  final confirm = await showDialog<bool>(...);
  
  if (confirm == true) {
    await _seedService.clearAllData();
  }
}
```

**Service xử lý:**
```dart
// lib/services/seed_data_service.dart
Future<void> clearAllData() async {
  print('🗑️ Đang xóa tất cả dữ liệu...');
  
  final collections = [
    'movies', 
    'theaters', 
    'screens', 
    'showtimes', 
    'bookings', 
    'payments'
  ];
  
  for (var collection in collections) {
    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .get();
    
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    
    print('✅ Đã xóa collection: $collection');
  }
  
  print('🎉 Hoàn thành xóa dữ liệu!');
}
```

### Cách 2: Xóa thủ công trên Firebase Console

1. Vào Firebase Console → Firestore Database
2. Click vào collection (vd: `movies`)
3. Click vào menu 3 chấm → **Delete collection**
4. Nhập tên collection để xác nhận
5. Lặp lại cho các collections khác

⚠️ **Lưu ý:** Xóa collection có nhiều documents có thể mất thời gian và cost. Nên dùng batch delete hoặc Firebase CLI cho production.

---

## ⏱️ THỜI GIAN SEED

| Collection | Số lượng | Thời gian ước tính |
|-----------|----------|-------------------|
| Movies | 5 | ~5 giây |
| Theaters | 4 | ~4 giây |
| Screens | 12 | ~15 giây |
| Showtimes | 63 | ~60 giây |
| **TỔNG** | **84 documents** | **~90 giây (1.5 phút)** |

---

## 🐛 TROUBLESHOOTING

### Lỗi 1: "Firebase not initialized"
```
❌ [ERROR] FirebaseException: [core/no-app]
```

**Giải pháp:**
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ THÊM DÒNG NÀY
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

---

### Lỗi 2: "Permission denied"
```
❌ [cloud_firestore/permission-denied] Missing or insufficient permissions
```

**Giải pháp:**
1. Vào Firebase Console → Firestore Database → Rules
2. Tạm thời cho phép write (CHỈ DÙNG TRONG DEVELOPMENT):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // ⚠️ Chỉ dùng khi develop!
    }
  }
}
```
3. Click **Publish**
4. Sau khi seed xong, đổi lại rules production (xem USAGE_GUIDE.md)

---

### Lỗi 3: "Seed data thêm bị trùng"

**Giải pháp:**
1. Nhấn nút "Xóa tất cả dữ liệu" trước
2. Sau đó nhấn "Thêm dữ liệu mẫu" lại

---

### Lỗi 4: "App crash khi seed"

**Kiểm tra:**
```dart
// Check Firebase initialization
print('Firebase initialized: ${Firebase.apps.isNotEmpty}');

// Check network
print('Has network: ${await Connectivity().checkConnectivity()}');
```

---

## ✅ CHECKLIST SAU KHI SEED

- [ ] Vào Firebase Console và thấy 5 collections (movies, theaters, screens, showtimes, users)
- [ ] Click vào `movies` và thấy 5 documents
- [ ] Click vào `theaters` và thấy 4 documents
- [ ] Click vào `screens` và thấy 12 documents
- [ ] Click vào `showtimes` và thấy 60+ documents
- [ ] Mở app và thấy phim hiển thị ở Home screen
- [ ] Vào màn hình Movies và thấy danh sách phim
- [ ] Vào màn hình Theaters và thấy danh sách rạp
- [ ] Click vào một phim và thấy lịch chiếu (nếu có)

---

## 🎯 KẾT LUẬN

**Bây giờ bạn đã có:**
- ✅ Nút Admin trên Home screen
- ✅ UI Admin hoàn chỉnh để seed data
- ✅ 5 phim + 4 rạp + 12 phòng chiếu + 60+ lịch chiếu
- ✅ Dữ liệu sẵn sàng để test booking flow

**Bước tiếp theo:**
1. Test các màn hình Movies, Theaters
2. Implement booking flow (chọn phim → lịch → ghế → thanh toán)
3. Test end-to-end từ chọn phim đến hoàn thành booking

---

**🎉 Chúc bạn thành công!** 🚀
