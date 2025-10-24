# 🚀 Quick Start: Mock → Firestore Migration

## ✅ ĐÃ HOÀN THÀNH (Theaters)

### 1. Run Admin Panel để seed data:
```bash
# 1. Mở app Flutter
flutter run

# 2. Nhấn nút FAB màu đỏ ở góc dưới phải home screen
# 3. Nhấn "Seed All Data" → Đợi "Success"
# 4. Kiểm tra Firestore Console
```

### 2. Test Theaters Screen:
```bash
# Vào mục "Rạp chiếu" trong bottom navigation
# Kết quả mong đợi:
✅ Loading indicator hiện → Danh sách 4 rạp hiện ra
✅ Click vào 1 rạp → Xem thông tin chi tiết (tên, địa chỉ, thành phố, SĐT)
✅ Data update real-time từ Firestore
```

---

## 🔄 ĐANG LÀM TIẾP (Booking & Tickets)

### 🎯 Priority 1: Booking Screen (booking_screen.dart)

#### Vấn đề hiện tại:
```dart
// ❌ Hardcoded dates
final List<String> availableDates = ["11/10", "12/10", "13/10", "14/10", "15/10"];

// ❌ Hardcoded times  
final List<String> availableTimes = ["10:00", "13:00", "16:00", "19:00", "21:30"];

// ❌ Fake booking
await Future.delayed(const Duration(seconds: 2)); // Không save gì cả
```

#### ✅ Giải pháp (từ FIRESTORE_MIGRATION_GUIDE.md):
1. **Load Showtimes** từ Firestore theo movieId
2. **Load Screen** để biết ghế nào available
3. **Check bookedSeats** từ Showtime để disable ghế đã bán
4. **Save Booking** với `firestoreService.createBooking()`

#### Code cần thay:
```dart
// Step 1: Add to BookingScreen constructor
class BookingScreen extends StatefulWidget {
  final Movie movie;
  final Showtime? initialShowtime; // ← Thêm này (optional)
  
  const BookingScreen({
    required this.movie,
    this.initialShowtime,
  });
}

// Step 2: Replace hardcoded dates with StreamBuilder
StreamBuilder<List<Showtime>>(
  stream: _firestoreService.getShowtimesByMovie(widget.movie.id),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final showtimes = snapshot.data!;
    // Group by date/time và build UI
    return _buildShowtimeSelector(showtimes);
  },
)

// Step 3: Load real seats from Screen
FutureBuilder<Screen?>(
  future: _firestoreService.getScreenById(selectedShowtime.screenId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final screen = snapshot.data!;
    final allSeats = screen.seats; // ← Seat layout thật
    final bookedSeats = selectedShowtime.bookedSeats; // ← Ghế đã bán
    
    return _buildSeatGrid(allSeats, bookedSeats);
  },
)

// Step 4: Real booking creation
Future<void> _confirmBooking() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('Chưa login');
  
  // Calculate price
  double totalPrice = 0.0;
  final seatTypes = <String, String>{};
  
  for (var seatId in selectedSeats) {
    final seat = screen.seats.firstWhere((s) => s.id == seatId);
    seatTypes[seatId] = seat.type;
    totalPrice += (seat.type == 'vip') ? showtime.vipPrice : showtime.basePrice;
  }
  
  // Create booking object
  final booking = Booking(
    id: '',
    userId: user.uid,
    showtimeId: selectedShowtime.id,
    movieId: widget.movie.id,
    theaterId: showtime.theaterId,
    screenId: showtime.screenId,
    selectedSeats: selectedSeats,
    seatTypes: seatTypes,
    totalPrice: totalPrice,
    status: 'pending',
    createdAt: DateTime.now(),
  );
  
  // ✅ Save to Firestore (with transaction)
  final bookingId = await _firestoreService.createBooking(booking);
  
  print('Booking created: $bookingId');
}
```

---

### 🎯 Priority 2: Ticket Screen (ticket_screen.dart)

#### Vấn đề hiện tại:
```dart
// ❌ Empty list
final List<Ticket> userTickets = [];
```

#### ✅ Giải pháp:
```dart
// Step 1: Get current user
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  return Center(child: Text('Vui lòng đăng nhập'));
}

// Step 2: Load bookings with StreamBuilder
StreamBuilder<List<Booking>>(
  stream: _firestoreService.getBookingsByUser(user.uid),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final bookings = snapshot.data!;
    
    if (bookings.isEmpty) {
      return Center(
        child: Text('Bạn chưa có vé nào'),
      );
    }
    
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        
        // Step 3: Load nested data
        return FutureBuilder<Map<String, dynamic>>(
          future: _loadBookingDetails(booking),
          builder: (context, detailSnapshot) {
            if (!detailSnapshot.hasData) return CircularProgressIndicator();
            
            final movie = detailSnapshot.data!['movie'] as Movie;
            final showtime = detailSnapshot.data!['showtime'] as Showtime;
            final theater = detailSnapshot.data!['theater'] as Theater;
            
            return _buildTicketCard(booking, movie, showtime, theater);
          },
        );
      },
    );
  },
)

// Helper to load nested data
Future<Map<String, dynamic>> _loadBookingDetails(Booking booking) async {
  final results = await Future.wait([
    _firestoreService.getMovieById(booking.movieId),
    _firestoreService.getShowtimeById(booking.showtimeId),
    _firestoreService.getTheaterById(booking.theaterId),
  ]);
  
  return {
    'movie': results[0],
    'showtime': results[1],
    'theater': results[2],
  };
}
```

---

## 📋 Migration Checklist

### ✅ Phase 1: Theaters (DONE)
- [x] `theaters_screen.dart` → StreamBuilder with Firestore
- [x] `theater_detail_screen.dart` → Real Theater model
- [x] Loading/Error/Empty states
- [x] No compilation errors

### 🔄 Phase 2: Booking (IN PROGRESS)
- [ ] Replace hardcoded dates with Firestore showtimes
- [ ] Replace hardcoded seats with Screen model
- [ ] Show real booked seats
- [ ] Implement real booking creation (createBooking)
- [ ] Add transaction handling
- [ ] Error handling & validation

### 🔜 Phase 3: Tickets (TODO)
- [ ] Load user bookings from Firestore
- [ ] Display booking details with movie/showtime/theater
- [ ] Show booking status
- [ ] Implement cancel booking
- [ ] Add empty state UI

### 🔜 Phase 4: Cleanup (TODO)
- [ ] Delete `mock_theaters.dart`
- [ ] Delete `mock_Data.dart` (already commented)
- [ ] Update all navigation to pass correct data
- [ ] Test end-to-end flow
- [ ] Performance optimization

---

## 🛠️ Tools & Services Available

### FirestoreService Methods:
```dart
// Movies
Stream<List<Movie>> getMoviesStream()
Future<Movie?> getMovieById(String id)
Stream<List<Movie>> getMoviesByStatus(String status)

// Theaters
Stream<List<Theater>> getTheatersStream()
Future<Theater?> getTheaterById(String id)

// Screens
Stream<List<Screen>> getScreensByTheater(String theaterId)
Future<Screen?> getScreenById(String id)

// Showtimes
Stream<List<Showtime>> getShowtimesByMovie(String movieId)
Stream<List<Showtime>> getShowtimesByTheater(String theaterId)
Future<Showtime?> getShowtimeById(String id)

// Bookings (CRITICAL for migration)
Stream<List<Booking>> getBookingsByUser(String userId) // ← For Ticket Screen
Stream<List<Booking>> getBookingsByShowtime(String showtimeId)
Future<String> createBooking(Booking booking) // ← With transaction
Future<void> cancelBooking(String bookingId) // ← Returns seats

// Payments
Stream<List<Payment>> getPaymentsByUser(String userId)
Future<String> createPayment(Payment payment)
```

---

## 📊 Data Flow

```
1. Seed Data (Admin Panel)
   ↓
2. Firestore Collections
   ├── movies (5)
   ├── theaters (4)
   ├── screens (12)
   └── showtimes (60+)
   ↓
3. UI Screens
   ├── ✅ Home → movies stream
   ├── ✅ Theaters → theaters stream
   ├── 🔄 Booking → showtimes stream + screen data
   └── 🔜 Tickets → bookings stream + nested data
```

---

## 🐛 Common Errors & Fixes

### Error 1: "The getter 'logoUrl' isn't defined"
```dart
// ❌ WRONG
Image.network(theater.logoUrl)

// ✅ CORRECT (Theater model doesn't have logoUrl)
Icon(Icons.theaters, color: Colors.red)
```

### Error 2: "StreamBuilder is not closed"
```dart
// ❌ WRONG
StreamBuilder(...) {
  return ListView.builder(...);
  // Missing closing brace

// ✅ CORRECT
StreamBuilder(...) {
  return ListView.builder(...);
  },
) // ← Close StreamBuilder here
```

### Error 3: "Null check operator used on null value"
```dart
// ❌ WRONG
final movie = await getMovieById(id);
Text(movie.title); // Crash if null

// ✅ CORRECT
final movie = await getMovieById(id);
if (movie == null) {
  return Text('Movie not found');
}
Text(movie.title);
```

---

## 📚 Documentation Files

- **FIRESTORE_ARCHITECTURE.md** - Chi tiết về collections, fields, relationships
- **FIRESTORE_MIGRATION_GUIDE.md** - Hướng dẫn migration đầy đủ với code examples
- **QUICK_START_MIGRATION.md** - Tài liệu này (quick reference)
- **USAGE_GUIDE.md** - Hướng dẫn sử dụng admin panel

---

## 🎯 Next Actions

### Immediate (Today):
1. ✅ Review theater screens migration (DONE)
2. 🔄 Start `booking_screen.dart` refactor:
   - Replace hardcoded dates with Firestore query
   - Load screen seats from Firestore
   - Implement real booking creation

### Short-term (This Week):
3. 🔜 Refactor `ticket_screen.dart`:
   - Load user bookings
   - Display booking details
   - Add cancel functionality

### Long-term (Next Week):
4. 🔜 Cleanup:
   - Delete mock files
   - Add error handling
   - Performance optimization
   - End-to-end testing

---

## 💡 Pro Tips

### 1. Testing Firestore Data:
```bash
# Open Firebase Console
# Go to: Firestore Database
# Check collections: movies, theaters, screens, showtimes
# Should see data after running "Seed All Data"
```

### 2. Debugging Streams:
```dart
StreamBuilder<List<Movie>>(
  stream: firestoreService.getMoviesStream(),
  builder: (context, snapshot) {
    print('Connection: ${snapshot.connectionState}'); // DEBUG
    print('Has data: ${snapshot.hasData}'); // DEBUG
    print('Data length: ${snapshot.data?.length}'); // DEBUG
    
    if (!snapshot.hasData) return CircularProgressIndicator();
    return ListView(...);
  },
)
```

### 3. Force Refresh Data:
```dart
// In Admin Panel
await seedDataService.clearAllData(); // Delete everything
await seedDataService.seedAllData();  // Re-create data
```

---

## 📞 Support

- **Full Guide:** `FIRESTORE_MIGRATION_GUIDE.md` (17 sections, 500+ lines)
- **Architecture:** `FIRESTORE_ARCHITECTURE.md`
- **Usage:** `USAGE_GUIDE.md`

---

**🚀 Ready? Start with `booking_screen.dart` migration!**

**Estimated Time:** 
- Booking Screen: 4-6 hours
- Ticket Screen: 2-3 hours
- Testing: 2 hours

**Good luck! 🎬🍿**
