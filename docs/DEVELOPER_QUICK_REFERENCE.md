# 🎯 DEVELOPER QUICK REFERENCE

**Project:** Cinema Flutter App  
**Last Updated:** October 24, 2025  
**Status:** ✅ Production Ready

---

## 📁 PROJECT STRUCTURE

```
lib/
├── models/
│   ├── movie.dart                  # Movie entity
│   ├── theater_model.dart          # Theater entity
│   ├── screen_model.dart           # Screen with seats
│   ├── showtime.dart               # Showtime schedule
│   ├── booking_model.dart          # Booking entity
│   ├── payment_model.dart          # Payment record
│   └── user_model.dart             # User profile
│
├── services/
│   ├── firestore_service.dart      # 400+ lines, all CRUD ops
│   └── seed_data_service.dart      # Seed database
│
├── screens/
│   ├── home/
│   │   └── home_screen.dart        # ✅ Firestore
│   ├── movie/
│   │   ├── movie_screen.dart       # ✅ Firestore
│   │   └── movie_detail_screen.dart
│   ├── theater/
│   │   ├── theaters_screen.dart    # ✅ Firestore
│   │   └── theater_detail_screen.dart # ✅ Firestore
│   ├── bookings/
│   │   └── booking_screen.dart     # ✅ Firestore (700+ lines)
│   ├── ticket/
│   │   └── ticket_screen.dart      # ✅ Firestore (350+ lines)
│   └── admin/
│       └── seed_data_screen.dart   # Admin panel
│
└── config/
    ├── app_routes.dart             # Navigation
    └── theme.dart                  # App theme
```

---

## 🔥 FIRESTORE SERVICE API

### **Movies:**
```dart
final service = FirestoreService();

// Read
Stream<List<Movie>> getMoviesStream()
Future<Movie?> getMovieById(String id)
Stream<List<Movie>> getMoviesByStatus(String status)

// Write
Future<String> addMovie(Movie movie)
Future<void> updateMovie(String id, Movie movie)
```

### **Theaters:**
```dart
// Read
Stream<List<Theater>> getTheatersStream()
Future<Theater?> getTheaterById(String id)

// Write
Future<String> addTheater(Theater theater)
Future<void> updateTheater(String id, Theater theater)
```

### **Screens:**
```dart
// Read
Stream<List<Screen>> getScreensByTheater(String theaterId)
Future<Screen?> getScreenById(String id)

// Write
Future<String> addScreen(Screen screen)
```

### **Showtimes:**
```dart
// Read
Stream<List<Showtime>> getShowtimesByMovie(String movieId)
Stream<List<Showtime>> getShowtimesByTheater(String theaterId)
Future<Showtime?> getShowtimeById(String id)

// Write
Future<String> addShowtime(Showtime showtime)
Future<void> updateBookedSeats(String showtimeId, List<String> bookedSeats)
```

### **Bookings (Critical):**
```dart
// Read
Stream<List<Booking>> getBookingsByUser(String userId)
Future<Booking?> getBookingById(String bookingId)

// Write (Transaction-based)
Future<String> createBooking(Booking booking)  // Atomic
Future<void> cancelBooking(String bookingId)   // Atomic
Future<void> updateBookingStatus(String bookingId, String status)
```

---

## 🎯 COMMON PATTERNS

### **1. Load Data with StreamBuilder:**

```dart
StreamBuilder<List<Movie>>(
  stream: FirestoreService().getMoviesStream(),
  builder: (context, snapshot) {
    // Loading
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    // Error
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    // Empty
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('No data');
    }
    
    // Success
    final movies = snapshot.data!;
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) => MovieCard(movies[index]),
    );
  },
)
```

### **2. Load Nested Data:**

```dart
Future<Map<String, dynamic>> _loadDetails() async {
  final results = await Future.wait([
    service.getMovieById(movieId),
    service.getShowtimeById(showtimeId),
    service.getTheaterById(theaterId),
  ]);
  
  return {
    'movie': results[0],
    'showtime': results[1],
    'theater': results[2],
  };
}
```

### **3. Create Booking (Transaction):**

```dart
Future<void> _createBooking() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // Show login prompt
    return;
  }
  
  final booking = Booking(
    id: '',
    userId: user.uid,
    showtimeId: selectedShowtime.id,
    movieId: movie.id,
    theaterId: showtime.theaterId,
    screenId: showtime.screenId,
    selectedSeats: selectedSeats,
    seatTypes: seatTypes,
    totalPrice: totalPrice,
    status: 'pending',
    createdAt: DateTime.now(),
  );
  
  try {
    final bookingId = await service.createBooking(booking);
    // Success
    print('Booking created: $bookingId');
  } catch (e) {
    // Error
    if (e.toString().contains('đã được đặt')) {
      print('Seat already booked');
    } else {
      print('Error: $e');
    }
  }
}
```

### **4. Cancel Booking:**

```dart
Future<void> _cancelBooking(String bookingId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Xác nhận hủy vé'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Không'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Hủy vé'),
        ),
      ],
    ),
  );
  
  if (confirm != true) return;
  
  try {
    await service.cancelBooking(bookingId);
    print('Booking cancelled');
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## 🧪 TESTING COMMANDS

### **Development:**
```bash
# Run app
flutter run

# Hot reload
r

# Hot restart
R

# Clean build
flutter clean
flutter pub get
flutter run
```

### **Testing:**
```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Coverage
flutter test --coverage

# Format code
flutter format lib/
```

### **Build:**
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 🔧 DEBUGGING

### **Check Firestore Data:**

```bash
# Open Firebase Console
open https://console.firebase.google.com

# Or use Firestore Emulator
firebase emulators:start --only firestore
```

### **Common Issues:**

| Issue | Solution |
|-------|----------|
| No data showing | Run seed data via Admin Panel |
| Can't create booking | Check Firebase Auth enabled |
| Compilation errors | `flutter clean && flutter pub get` |
| "Ghế đã được đặt" | Transaction working correctly |
| Empty ticket list | Login first, then book tickets |

### **Debug Prints:**

```dart
// Add debug info
print('Showtimes: ${showtimes.length}');
print('Selected seats: $selectedSeats');
print('Total price: $totalPrice');
print('User ID: ${FirebaseAuth.instance.currentUser?.uid}');
```

---

## 📊 DATA MODELS

### **Booking Model:**

```dart
class Booking {
  final String id;
  final String userId;
  final String showtimeId;
  final String movieId;
  final String theaterId;
  final String screenId;
  final List<String> selectedSeats;    // ["A1", "A2"]
  final Map<String, String> seatTypes;  // {"A1": "vip", "A2": "standard"}
  final double totalPrice;
  final String status;                  // pending | confirmed | cancelled | completed
  final DateTime createdAt;
  
  // Methods
  bool canCancel() => status == 'pending' || status == 'confirmed';
  String get seatsString => selectedSeats.join(', ');
}
```

### **Showtime Model:**

```dart
class Showtime {
  final String id;
  final String movieId;
  final String screenId;
  final String theaterId;
  final DateTime startTime;
  final DateTime endTime;
  final double basePrice;
  final double vipPrice;
  final int availableSeats;
  final List<String> bookedSeats;
  final String status;
  
  // Helper methods
  String getDate() => '${startTime.day}/${startTime.month}/${startTime.year}';
  String getTime() => '${startTime.hour}:${startTime.minute}';
}
```

---

## 🎨 UI COMPONENTS

### **Loading State:**
```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  return Center(child: CircularProgressIndicator());
}
```

### **Error State:**
```dart
if (snapshot.hasError) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.error_outline, size: 60),
        Text('Error: ${snapshot.error}'),
        ElevatedButton(
          onPressed: () => setState(() {}),
          child: Text('Retry'),
        ),
      ],
    ),
  );
}
```

### **Empty State:**
```dart
if (!snapshot.hasData || snapshot.data!.isEmpty) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.inbox, size: 60),
        Text('No data available'),
      ],
    ),
  );
}
```

---

## 🔐 FIREBASE AUTH

### **Check Login:**
```dart
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  // Not logged in
  Navigator.pushNamed(context, '/login');
  return;
}

// Logged in
final userId = user.uid;
final email = user.email;
```

### **Sign Out:**
```dart
await FirebaseAuth.instance.signOut();
```

---

## 📝 QUICK TASKS

### **Add New Movie:**
```dart
final movie = Movie(
  id: '',
  title: 'New Movie',
  genre: 'Action',
  duration: 120,
  posterUrl: 'https://...',
  status: 'now_showing',
  // ... other fields
);

await FirestoreService().addMovie(movie);
```

### **Add New Showtime:**
```dart
final showtime = Showtime(
  id: '',
  movieId: 'movie_id',
  screenId: 'screen_id',
  theaterId: 'theater_id',
  startTime: DateTime(2025, 10, 25, 19, 0),
  endTime: DateTime(2025, 10, 25, 21, 0),
  basePrice: 80000,
  vipPrice: 120000,
  availableSeats: 50,
  bookedSeats: [],
  status: 'active',
);

await FirestoreService().addShowtime(showtime);
```

### **Query Bookings:**
```dart
// Get all user bookings
final userId = FirebaseAuth.instance.currentUser!.uid;
StreamBuilder<List<Booking>>(
  stream: FirestoreService().getBookingsByUser(userId),
  builder: (context, snapshot) { ... }
)

// Get single booking
final booking = await FirestoreService().getBookingById(bookingId);
```

---

## 🚀 DEPLOYMENT CHECKLIST

- [ ] Run `flutter analyze` (no errors)
- [ ] Run `flutter test` (all pass)
- [ ] Test on Android device
- [ ] Test on iOS device (if available)
- [ ] Check Firebase Console (data correct)
- [ ] Check Firestore Rules (secure)
- [ ] Update version in `pubspec.yaml`
- [ ] Build release APK/IPA
- [ ] Test release build
- [ ] Deploy to store

---

## 📚 DOCUMENTATION INDEX

1. [FIRESTORE_ARCHITECTURE.md](FIRESTORE_ARCHITECTURE.md) - Database structure
2. [FIRESTORE_MIGRATION_GUIDE.md](FIRESTORE_MIGRATION_GUIDE.md) - Migration guide
3. [BOOKING_TESTING_GUIDE.md](BOOKING_TESTING_GUIDE.md) - Testing scenarios
4. [FINAL_MIGRATION_SUMMARY.md](FINAL_MIGRATION_SUMMARY.md) - Complete summary
5. [README.md](README.md) - Project overview

---

## ⚡ PRODUCTIVITY TIPS

### **VS Code Shortcuts:**
```
Ctrl+Space          - Auto-complete
Ctrl+.              - Quick fix
F2                  - Rename symbol
Ctrl+Shift+R        - Refactor
Ctrl+/              - Comment line
```

### **Flutter Shortcuts:**
```
r                   - Hot reload
R                   - Hot restart
p                   - Toggle performance overlay
```

### **Dart Snippets:**
```dart
// Create StatelessWidget
stless + Tab

// Create StatefulWidget
stful + Tab

// Create async method
asyncmethod + Tab
```

---

**🎯 Keep this reference handy for quick lookups! 🚀**
