# 🎬 KIẾN TRÚC DỮ LIỆU - Cinema Flutter App

## 📊 Tổng quan Collections

```
Firestore Database
├── 🎬 movies/                    (Phim)
│   └── {movieId}
│
├── 🏢 theaters/                  (Rạp chiếu)
│   └── {theaterId}
│
├── 🪑 screens/                   (Phòng chiếu)
│   └── {screenId}
│
├── ⏰ showtimes/                 (Lịch chiếu)
│   └── {showtimeId}
│
├── 🎟️ bookings/                 (Đặt vé)
│   └── {bookingId}
│
├── 👤 users/                     (Người dùng)
│   └── {userId}
│
└── 💳 payments/                  (Thanh toán)
    └── {paymentId}
```

## 🔗 Mối quan hệ giữa các Collections

### 1️⃣ Movies → Showtimes (1-N)
- Một phim có nhiều lịch chiếu
- `showtimes.movieId` tham chiếu đến `movies.id`

### 2️⃣ Theaters → Screens (1-N)
- Một rạp có nhiều phòng chiếu
- `screens.theaterId` tham chiếu đến `theaters.id`

### 3️⃣ Showtimes → Movies + Screens (N-1)
- Một lịch chiếu thuộc về 1 phim và 1 phòng chiếu
- `showtimes.movieId` → `movies.id`
- `showtimes.screenId` → `screens.id`

### 4️⃣ Bookings → Users + Showtimes (N-1)
- Một booking thuộc về 1 user và 1 showtime
- `bookings.userId` → `users.id`
- `bookings.showtimeId` → `showtimes.id`

### 5️⃣ Payments → Bookings (1-1)
- Mỗi booking có 1 payment
- `payments.bookingId` → `bookings.id`

## 📁 Cấu trúc thư mục đề xuất

```
lib/
├── models/
│   ├── movie.dart              ✅ (đã có)
│   ├── theater_model.dart      ✅ (đã có)
│   ├── screen_model.dart       ✅ (đã có)
│   ├── showtime_model.dart     🔄 (cần cập nhật)
│   ├── booking_model.dart      ➕ (cần tạo)
│   ├── payment_model.dart      ➕ (cần tạo)
│   └── user_model.dart         ✅ (đã có)
│
├── services/
│   ├── firestore_service.dart  ✅ (đã có, cần mở rộng)
│   └── seed_data_service.dart  ➕ (cần tạo - thêm dữ liệu mẫu)
│
└── screens/
    └── admin/
        └── seed_data_screen.dart ➕ (màn hình admin thêm data)
```

## 🚀 Cách thêm dữ liệu

### Phương pháp 1: Từ code Flutter (Khuyến nghị)
```dart
// Sử dụng SeedDataService
await SeedDataService().seedAllData();
```

### Phương pháp 2: Firebase Console
- Vào Firebase Console → Firestore Database
- Thêm collection và document thủ công

### Phương pháp 3: Import JSON (nâng cao)
- Sử dụng Firebase Admin SDK
- Không khuyến nghị cho mobile app

## ⚡ Tối ưu Firestore

### Index cần tạo:
1. `showtimes` → compound index: `movieId + date + time`
2. `showtimes` → compound index: `screenId + date + time`
3. `bookings` → compound index: `userId + createdAt`
4. `bookings` → compound index: `showtimeId + status`

### Security Rules mẫu:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Movies - Public read, admin write
    match /movies/{movieId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Bookings - User only see their own
    match /bookings/{bookingId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                       resource.data.userId == request.auth.uid;
    }
    
    // Users - Only own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📝 Ghi chú quan trọng

1. **Timestamp**: Luôn dùng `FieldValue.serverTimestamp()` thay vì `DateTime.now()`
2. **References**: Có thể dùng `DocumentReference` hoặc `String ID` (khuyến nghị dùng String ID cho đơn giản)
3. **Subcollections**: Tránh dùng cho quan hệ N-N, dùng flat structure với ID references
4. **Batch writes**: Dùng `batch.commit()` khi thêm nhiều documents cùng lúc
5. **Real-time updates**: Dùng `snapshots()` thay vì `get()` khi cần live data
