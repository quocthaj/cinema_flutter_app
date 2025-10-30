# 📖 HƯỚNG DẪN SỬ DỤNG - Cinema Flutter App

## 🚀 Cách thêm dữ liệu vào Firestore

### Phương pháp 1: Sử dụng Seed Data Screen (Khuyến nghị)

#### Bước 1: Thêm route vào app_routes.dart
```dart
// lib/config/app_routes.dart
import '../screens/admin/seed_data_screen.dart';

class AppRoutes {
  static const String seedData = '/seed-data';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case seedData:
        return MaterialPageRoute(builder: (_) => const SeedDataScreen());
      // ... các routes khác
    }
  }
}
```

#### Bước 2: Tạo nút truy cập (trong Development)
```dart
// Thêm FloatingActionButton vào màn hình home
FloatingActionButton(
  onPressed: () {
    Navigator.pushNamed(context, '/seed-data');
  },
  child: const Icon(Icons.admin_panel_settings),
)
```

#### Bước 3: Chạy seed data
1. Mở app và vào màn hình Seed Data
2. Nhấn nút "Thêm tất cả dữ liệu mẫu"
3. Đợi vài phút cho quá trình hoàn tất
4. Kiểm tra Firebase Console

### Phương pháp 2: Gọi trực tiếp từ code

```dart
// lib/main.dart hoặc bất kỳ đâu
import 'services/seed_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // CHỈ CHẠY 1 LẦN
  // await SeedDataService().seedAllData();
  
  runApp(const MyApp());
}
```

### Phương pháp 3: Thêm dữ liệu thủ công

```dart
import 'services/firestore_service.dart';
import 'models/movie.dart';

final firestoreService = FirestoreService();

// Thêm 1 phim
final movieData = {
  'title': 'Tên phim',
  'genre': 'Hành động',
  'duration': 120,
  'rating': 8.5,
  'posterUrl': 'https://...',
  'status': 'now_showing',
  'releaseDate': '01/01/2024',
  'description': 'Mô tả phim',
  'trailerUrl': 'https://youtube.com/...',
};

await SeedDataService().addSingleMovie(movieData);
```

## 📊 Cấu trúc dữ liệu Firestore

### Collection: movies
```javascript
{
  "title": "Avatar: The Way of Water",
  "genre": "Sci-Fi, Adventure",
  "duration": 192,
  "rating": 8.5,
  "posterUrl": "https://...",
  "status": "now_showing", // hoặc "coming_soon"
  "releaseDate": "16/12/2022",
  "description": "...",
  "trailerUrl": "https://..."
}
```

### Collection: theaters
```javascript
{
  "name": "CGV Vincom Center",
  "address": "191 Bà Triệu, Hai Bà Trưng",
  "city": "Hà Nội",
  "phone": "1900 6017",
  "screens": ["screen_id_1", "screen_id_2"]
}
```

### Collection: screens
```javascript
{
  "theaterId": "theater_id",
  "name": "Phòng 1",
  "totalSeats": 80,
  "rows": 8,
  "columns": 10,
  "seats": [
    {
      "id": "A1",
      "type": "standard", // hoặc "vip"
      "isAvailable": true
    }
  ]
}
```

### Collection: showtimes
```javascript
{
  "movieId": "movie_id",
  "screenId": "screen_id",
  "theaterId": "theater_id",
  "startTime": Timestamp,
  "endTime": Timestamp,
  "basePrice": 80000,
  "vipPrice": 120000,
  "availableSeats": 80,
  "bookedSeats": [],
  "status": "active" // hoặc "cancelled", "completed"
}
```

### Collection: bookings
```javascript
{
  "userId": "user_id",
  "showtimeId": "showtime_id",
  "movieId": "movie_id",
  "theaterId": "theater_id",
  "screenId": "screen_id",
  "selectedSeats": ["A1", "A2"],
  "seatTypes": {
    "A1": "standard",
    "A2": "vip"
  },
  "totalPrice": 200000,
  "status": "confirmed", // pending, confirmed, cancelled, completed
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "paymentId": "payment_id"
}
```

### Collection: payments
```javascript
{
  "bookingId": "booking_id",
  "userId": "user_id",
  "amount": 200000,
  "method": "momo", // momo, vnpay, zalopay, credit_card, cash
  "status": "success", // pending, success, failed, refunded
  "createdAt": Timestamp,
  "completedAt": Timestamp,
  "transactionId": "TXN123456",
  "errorMessage": null
}
```

### Collection: users
```javascript
{
  "uid": "user_uid",
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "createdAt": Timestamp,
  "favoriteMovies": ["movie_id_1", "movie_id_2"]
}
```

## 💡 Ví dụ sử dụng FirestoreService

### Lấy danh sách phim
```dart
final firestoreService = FirestoreService();

// Lấy tất cả phim (real-time)
StreamBuilder<List<Movie>>(
  stream: firestoreService.getMoviesStream(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final movies = snapshot.data!;
      return ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return MovieCard(movie: movies[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)

// Lấy phim đang chiếu
StreamBuilder<List<Movie>>(
  stream: firestoreService.getMoviesByStatus('now_showing'),
  builder: (context, snapshot) {
    // ...
  },
)
```

### Lấy lịch chiếu
```dart
// Lấy lịch chiếu của một phim
StreamBuilder<List<Showtime>>(
  stream: firestoreService.getShowtimesByMovie(movieId),
  builder: (context, snapshot) {
    // ...
  },
)

// Lấy lịch chiếu theo rạp và ngày
final showtimes = firestoreService.getShowtimesByTheaterAndDate(
  theaterId, 
  DateTime.now()
);
```

### Tạo booking
```dart
try {
  final booking = Booking(
    id: '', // Firestore sẽ tự generate
    userId: currentUser.uid,
    showtimeId: selectedShowtime.id,
    movieId: movie.id,
    theaterId: theater.id,
    screenId: screen.id,
    selectedSeats: ['A1', 'A2'],
    seatTypes: {'A1': 'standard', 'A2': 'vip'},
    totalPrice: 200000,
    status: 'pending',
    createdAt: DateTime.now(),
  );

  final bookingId = await firestoreService.createBooking(booking);
  print('Booking created: $bookingId');
  
} catch (e) {
  print('Error: $e'); // Ví dụ: "Ghế A1 đã được đặt"
}
```

### Thanh toán
```dart
final payment = Payment(
  id: '',
  bookingId: bookingId,
  userId: currentUser.uid,
  amount: 200000,
  method: 'momo',
  status: 'pending',
  createdAt: DateTime.now(),
);

final paymentId = await firestoreService.createPayment(payment);

// Sau khi thanh toán thành công
await firestoreService.updatePaymentStatus(
  paymentId, 
  'success',
  transactionId: 'TXN123456'
);

await firestoreService.updateBookingStatus(bookingId, 'confirmed');
```

### Lấy booking của user
```dart
StreamBuilder<List<Booking>>(
  stream: firestoreService.getBookingsByUser(currentUser.uid),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final bookings = snapshot.data!;
      return ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return BookingCard(booking: bookings[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

### Hủy booking
```dart
try {
  await firestoreService.cancelBooking(bookingId);
  print('Booking cancelled successfully');
} catch (e) {
  print('Error: $e');
}
```

## 🔐 Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Movies - Public read
    match /movies/{movieId} {
      allow read: if true;
      allow write: if false; // Chỉ admin mới được write
    }
    
    // Theaters - Public read
    match /theaters/{theaterId} {
      allow read: if true;
      allow write: if false;
    }
    
    // Screens - Public read
    match /screens/{screenId} {
      allow read: if true;
      allow write: if false;
    }
    
    // Showtimes - Public read
    match /showtimes/{showtimeId} {
      allow read: if true;
      allow write: if false;
    }
    
    // Bookings - User chỉ xem được booking của mình
    match /bookings/{bookingId} {
      allow read: if isSignedIn() && 
                     resource.data.userId == request.auth.uid;
      allow create: if isSignedIn() && 
                       request.resource.data.userId == request.auth.uid;
      allow update: if isOwner(resource.data.userId);
      allow delete: if false;
    }
    
    // Payments - User chỉ xem được payment của mình
    match /payments/{paymentId} {
      allow read: if isSignedIn() && 
                     resource.data.userId == request.auth.uid;
      allow create: if isSignedIn() && 
                       request.resource.data.userId == request.auth.uid;
      allow update: if isOwner(resource.data.userId);
      allow delete: if false;
    }
    
    // Users - User chỉ xem/sửa được profile của mình
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId);
    }
  }
}
```

## 📌 Index cần tạo trong Firestore

Vào Firebase Console → Firestore Database → Indexes và tạo:

### Composite Indexes:
1. **showtimes**
   - movieId (Ascending)
   - status (Ascending)
   - startTime (Ascending)

2. **showtimes**
   - theaterId (Ascending)
   - startTime (Ascending)
   - status (Ascending)

3. **bookings**
   - userId (Ascending)
   - createdAt (Descending)

4. **bookings**
   - showtimeId (Ascending)
   - status (Ascending)

## 🐛 Troubleshooting

### Lỗi: "Missing or insufficient permissions"
→ Kiểm tra Security Rules trong Firebase Console

### Lỗi: "The query requires an index"
→ Click vào link trong error message để tạo index tự động

### Lỗi: "Ghế đã được đặt"
→ Đây là behavior bình thường, nghĩa là có người đặt ghế đó trước

### Seed data không hoạt động
→ Kiểm tra kết nối Firebase và rules

## 📚 Tài liệu tham khảo

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Cloud Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
