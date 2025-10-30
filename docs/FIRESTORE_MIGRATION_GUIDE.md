# 🔄 MIGRATION GUIDE: Mock Data → Firebase Firestore

## 📋 PHẦN 1: Danh Sách Files Đang Dùng Mock Data

### ❌ **CRITICAL** (Cần thay thế ngay):

| File | Status | Mock Type | Impact | Priority |
|------|--------|-----------|--------|----------|
| `booking_screen.dart` | 🔴 Hardcoded | Dates, times, seats, soldSeats | HIGH - Không có booking thực | P0 |
| `ticket_screen.dart` | 🔴 Empty List | `final List<Ticket> userTickets = []` | HIGH - User không thấy vé | P0 |
| `theaters_screen.dart` | ✅ FIXED | ~~`mockTheaters`~~ → Now uses Firestore | DONE | - |
| `theater_detail_screen.dart` | ✅ FIXED | ~~Mock Theater model~~ → Real model | DONE | - |

### ✅ **GOOD** (Đã dùng Firestore):
- ✅ `home_screen.dart` - `FirestoreService().getMoviesStream()`
- ✅ `movie_screen.dart` - `FirestoreService().getMoviesByStatus()`  
- ✅ `movie_detail_screen.dart` - Có thể query showtimes

### 📄 **Data Files** (Nên giữ cho reference):
- 📁 `mock_Data.dart` - ✅ Đã comment hết
- 📁 `mock_theaters.dart` - ⚠️ Có thể xóa (không dùng nữa)

---

## 🎯 PHẦN 2: Code Refactor Đã Hoàn Thành

### ✅ **A. THEATERS SCREEN** - MIGRATED

#### Changes Made:

**1. Import Changes:**
```dart
// ❌ BEFORE
import '../../data/mock_theaters.dart';

// ✅ AFTER
import '../../models/theater_model.dart';
import '../../services/firestore_service.dart';
```

**2. Added FirestoreService:**
```dart
class _TheatersScreenState extends State<TheatersScreen> {
  final _firestoreService = FirestoreService(); // ✅ NEW
  ...
}
```

**3. Replaced ListView with StreamBuilder:**
```dart
// ❌ BEFORE
body: ListView.builder(
  itemCount: mockTheaters.length,
  itemBuilder: (context, index) {
    final theater = mockTheaters[index];
    ...
  },
)

// ✅ AFTER
body: StreamBuilder<List<Theater>>(
  stream: _firestoreService.getTheatersStream(),
  builder: (context, snapshot) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (snapshot.hasError) {
      return Center(child: Column(...)); // Error UI
    }

    // Empty state
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Column(...)); // Empty UI
    }

    // Success state
    final theaters = snapshot.data!;
    return ListView.builder(
      itemCount: theaters.length,
      itemBuilder: (context, index) {
        final theater = theaters[index];
        ...
      },
    );
  },
)
```

**4. Updated UI to use real Theater model:**
```dart
// Removed: theater.logoUrl (không có trong model mới)
// Replaced with Icon
leading: CircleAvatar(
  child: Icon(Icons.theaters, color: AppTheme.primaryColor),
  radius: 28,
  backgroundColor: AppTheme.fieldColor,
),
```

### ✅ **B. THEATER DETAIL SCREEN** - MIGRATED

#### Changes Made:

**1. Import Change:**
```dart
// ❌ BEFORE
import '../../data/mock_theaters.dart';

// ✅ AFTER
import '../../models/theater_model.dart';
```

**2. Updated UI to use real Theater fields:**
```dart
// Real Theater model fields:
// - id
// - name
// - address
// - city     ← NEW
// - phone    ← NEW
// - screens  ← NEW

// Updated UI to display:
Row(
  children: [
    Icon(Icons.location_city, color: Colors.red, size: 16),
    Text(theater.city),
  ],
),
Row(
  children: [
    Icon(Icons.phone, color: Colors.red, size: 16),
    Text(theater.phone),
  ],
),
```

---

## 🔄 PHẦN 3: Code Refactor Tiếp Theo (BOOKING & TICKETS)

### 🎯 **C. BOOKING SCREEN** - TO DO

#### Current Problems:
```dart
// 🔴 Problem 1: Hardcoded dates
final List<String> availableDates = ["11/10", "12/10", "13/10", "14/10", "15/10"];

// 🔴 Problem 2: Hardcoded times
final List<String> availableTimes = ["10:00", "13:00", "16:00", "19:00", "21:30"];

// 🔴 Problem 3: Hardcoded seats
final List<String> seatList = ["A1", "A2", ..., "C5"];

// 🔴 Problem 4: Fake sold seats
final List<String> soldSeats = ["A3", "B1", "C5"];

// 🔴 Problem 5: Fake booking
await Future.delayed(const Duration(seconds: 2)); // Giả lập API
```

#### ✅ SOLUTION - Load from Firestore:

**Step 1: Accept Showtime instead of just Movie**
```dart
// ❌ CURRENT
class BookingScreen extends StatefulWidget {
  final Movie movie;
  const BookingScreen({required this.movie});
}

// ✅ BETTER
class BookingScreen extends StatefulWidget {
  final Movie movie;
  final Showtime showtime; // ← ADD THIS
  final Theater theater;   // ← ADD THIS (optional)
  final Screen screen;     // ← ADD THIS (optional)
  
  const BookingScreen({
    required this.movie,
    required this.showtime,
    this.theater,
    this.screen,
  });
}
```

**Step 2: Load Showtimes from Firestore**
```dart
class _BookingScreenState extends State<BookingScreen> {
  final _firestoreService = FirestoreService();
  
  String? selectedShowtimeId;
  List<String> selectedSeats = [];
  
  // ✅ Load showtimes dynamically
  Stream<List<Showtime>> get showtimesStream => 
      _firestoreService.getShowtimesByMovie(widget.movie.id);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đặt vé - ${widget.movie.title}")),
      body: StreamBuilder<List<Showtime>>(
        stream: showtimesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Chưa có lịch chiếu cho phim này'),
            );
          }
          
          final showtimes = snapshot.data!;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Movie info
                _buildMovieInfo(),
                
                // ✅ Select showtime (real data)
                _buildShowtimeSelection(showtimes),
                
                // ✅ Select seats (from selected showtime)
                if (selectedShowtimeId != null)
                  _buildSeatSelection(),
                
                // Confirm button
                _buildConfirmButton(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildShowtimeSelection(List<Showtime> showtimes) {
    // Group by date
    final Map<String, List<Showtime>> groupedByDate = {};
    for (var showtime in showtimes) {
      final date = showtime.getDate();
      groupedByDate.putIfAbsent(date, () => []).add(showtime);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn suất chiếu', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 12),
        
        // Date chips
        Wrap(
          spacing: 8,
          children: groupedByDate.keys.map((date) {
            return ChoiceChip(
              label: Text(date),
              selected: selectedDate == date,
              onSelected: (selected) {
                setState(() => selectedDate = selected ? date : null);
              },
            );
          }).toList(),
        ),
        
        // Time chips (filtered by selected date)
        if (selectedDate != null) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: groupedByDate[selectedDate]!.map((showtime) {
              final isSelected = selectedShowtimeId == showtime.id;
              return ChoiceChip(
                label: Column(
                  children: [
                    Text(showtime.getTime()),
                    Text(
                      '${showtime.availableSeats} ghế',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedShowtimeId = selected ? showtime.id : null;
                    selectedSeats = []; // Reset seats
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildSeatSelection() {
    return FutureBuilder<Showtime?>(
      future: _firestoreService.getShowtimeById(selectedShowtimeId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        
        final showtime = snapshot.data!;
        final bookedSeats = showtime.bookedSeats; // ✅ Real booked seats
        
        return FutureBuilder<Screen?>(
          future: _firestoreService.getScreenById(showtime.screenId),
          builder: (context, screenSnapshot) {
            if (!screenSnapshot.hasData) return const CircularProgressIndicator();
            
            final screen = screenSnapshot.data!;
            final allSeats = screen.seats; // ✅ Real seat layout
            
            return Column(
              children: [
                const Text('SCREEN', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                
                // ✅ Build seat grid from Screen model
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screen.columns + 2, // +2 for labels
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: allSeats.length,
                  itemBuilder: (context, index) {
                    final seat = allSeats[index];
                    final isBooked = bookedSeats.contains(seat.id);
                    final isSelected = selectedSeats.contains(seat.id);
                    
                    Color seatColor;
                    if (isBooked) {
                      seatColor = Colors.red[900]!;
                    } else if (isSelected) {
                      seatColor = AppTheme.primaryColor;
                    } else {
                      seatColor = AppTheme.fieldColor;
                    }
                    
                    return GestureDetector(
                      onTap: isBooked ? null : () {
                        setState(() {
                          if (isSelected) {
                            selectedSeats.remove(seat.id);
                          } else {
                            selectedSeats.add(seat.id);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: seatColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            seat.id,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                _buildSeatLegend(),
              ],
            );
          },
        );
      },
    );
  }
  
  // ✅ Real booking creation
  Future<void> _confirmBooking() async {
    if (selectedShowtimeId == null || selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn suất chiếu và ghế')),
      );
      return;
    }
    
    try {
      EasyLoading.show(status: 'Đang đặt vé...');
      
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Vui lòng đăng nhập');
      }
      
      // Get showtime info
      final showtime = await _firestoreService.getShowtimeById(selectedShowtimeId!);
      if (showtime == null) {
        throw Exception('Không tìm thấy lịch chiếu');
      }
      
      // Calculate total price
      final screen = await _firestoreService.getScreenById(showtime.screenId);
      final seatTypes = <String, String>{};
      double totalPrice = 0.0;
      
      for (var seatId in selectedSeats) {
        final seat = screen!.seats.firstWhere((s) => s.id == seatId);
        seatTypes[seatId] = seat.type;
        
        if (seat.type == 'vip') {
          totalPrice += showtime.vipPrice;
        } else {
          totalPrice += showtime.basePrice;
        }
      }
      
      // Create booking
      final booking = Booking(
        id: '', // Firestore will generate
        userId: user.uid,
        showtimeId: selectedShowtimeId!,
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
      
      EasyLoading.dismiss();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt vé thành công! ID: $bookingId'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to payment or ticket screen
      Navigator.pop(context);
      
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

### 🎯 **D. TICKET SCREEN** - TO DO

#### Current Problem:
```dart
// 🔴 Empty list
final List<Ticket> userTickets = [];
```

#### ✅ SOLUTION - Load User Bookings:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';
import '../../models/booking_model.dart';
import '../../models/movie.dart';
import '../../models/showtime.dart';
import '../../models/theater_model.dart';
import '../../services/firestore_service.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vé của tôi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 60, color: AppTheme.textSecondaryColor),
              const SizedBox(height: 16),
              const Text('Vui lòng đăng nhập để xem vé'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login
                },
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }
    
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé của tôi'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Booking>>(
        stream: firestoreService.getBookingsByUser(user.uid),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                ],
              ),
            );
          }
          
          // Empty
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }
          
          // Success - Display bookings
          final bookings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildTicketCard(context, booking, firestoreService);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_activity_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Bạn chưa có vé nào',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy bắt đầu đặt vé và trải nghiệm phim hay!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context, 
    Booking booking, 
    FirestoreService firestoreService
  ) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadBookingDetails(booking, firestoreService),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Container(
              height: 150,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final data = snapshot.data!;
        final movie = data['movie'] as Movie;
        final showtime = data['showtime'] as Showtime;
        final theater = data['theater'] as Theater;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.posterUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 120,
                            color: AppTheme.cardColor,
                            child: Icon(
                              Icons.movie_creation_outlined,
                              color: Colors.white54,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.calendar_today,
                            '${showtime.getDate()} - ${showtime.getTime()}',
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            Icons.theaters,
                            theater.name,
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            Icons.chair,
                            'Ghế: ${booking.seatsString}',
                          ),
                          const SizedBox(height: 4),
                          _buildStatusChip(booking.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng cộng:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${booking.totalPrice.toStringAsFixed(0)} VNĐ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 18,
                          ),
                    ),
                  ],
                ),
                
                // Cancel button (if applicable)
                if (booking.canCancel()) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _cancelBooking(context, booking, firestoreService),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Hủy vé'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadBookingDetails(
    Booking booking,
    FirestoreService firestoreService,
  ) async {
    final results = await Future.wait([
      firestoreService.getMovieById(booking.movieId),
      firestoreService.getShowtimeById(booking.showtimeId),
      firestoreService.getTheaterById(booking.theaterId),
    ]);

    return {
      'movie': results[0],
      'showtime': results[1],
      'theater': results[2],
    };
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondaryColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Chờ xử lý';
        break;
      case 'confirmed':
        color = Colors.green;
        label = 'Đã xác nhận';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Đã hủy';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Hoàn thành';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Future<void> _cancelBooking(
    BuildContext context,
    Booking booking,
    FirestoreService firestoreService,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy vé'),
        content: const Text('Bạn có chắc muốn hủy vé này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await firestoreService.cancelBooking(booking.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hủy vé thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

---

## 📊 PHẦN 4: Data Flow & Dependencies

### Mối quan hệ dữ liệu:

```
Booking
   ├── userId → users/{userId}
   ├── movieId → movies/{movieId}
   ├── theaterId → theaters/{theaterId}
   ├── screenId → screens/{screenId}
   └── showtimeId → showtimes/{showtimeId}

Showtime
   ├── movieId → movies/{movieId}
   ├── theaterId → theaters/{theaterId}
   └── screenId → screens/{screenId}

Screen
   └── theaterId → theaters/{theaterId}
```

### Loading Strategy:

#### **Option 1: Sequential Loading (Simple)**
```dart
final booking = await getBookingById(bookingId);
final movie = await getMovieById(booking.movieId);
final showtime = await getShowtimeById(booking.showtimeId);
final theater = await getTheaterById(booking.theaterId);
```
**Pros:** Dễ hiểu, code đơn giản  
**Cons:** Chậm (4 requests tuần tự)

#### **Option 2: Parallel Loading (Better)** ✅
```dart
final results = await Future.wait([
  getMovieById(booking.movieId),
  getShowtimeById(booking.showtimeId),
  getTheaterById(booking.theaterId),
]);

final movie = results[0];
final showtime = results[1];
final theater = results[2];
```
**Pros:** Nhanh hơn (3 requests parallel)  
**Cons:** Vẫn cần nhiều requests

#### **Option 3: Denormalization (Best for Read-Heavy)** 
```dart
// Store duplicate data in booking
class Booking {
  ...
  final String movieTitle;      // Duplicate từ movie
  final String moviePosterUrl;  // Duplicate từ movie
  final String theaterName;     // Duplicate từ theater
  final DateTime showtimeStart; // Duplicate từ showtime
  ...
}
```
**Pros:** Chỉ 1 query, rất nhanh  
**Cons:** Phức tạp hơn khi update, tốn storage

---

## 🏗️ PHẦN 5: Architecture Pattern

### Current: **Service Layer Pattern** ✅

```
UI Layer (Screens)
      ↓
Service Layer (FirestoreService)
      ↓
Data Layer (Firebase Firestore)
```

**Pros:**
- ✅ Đơn giản, dễ hiểu
- ✅ Đã implement sẵn trong `firestore_service.dart`
- ✅ Phù hợp với project vừa và nhỏ

**Cons:**
- ⚠️ Service class có thể phình to
- ⚠️ Khó test (tight coupling với Firebase)

---

### Alternative: **Repository Pattern** (Optional)

```
UI Layer (Screens)
      ↓
Repository Layer (BookingRepository, MovieRepository)
      ↓
Service Layer (FirestoreService)
      ↓
Data Layer (Firebase Firestore)
```

**Implementation Example:**
```dart
// lib/repositories/booking_repository.dart
class BookingRepository {
  final FirestoreService _firestoreService;
  
  BookingRepository(this._firestoreService);
  
  // ✅ High-level operations
  Future<BookingWithDetails> getBookingWithDetails(String bookingId) async {
    final booking = await _firestoreService.getBookingById(bookingId);
    if (booking == null) throw Exception('Booking not found');
    
    // Load all related data in parallel
    final results = await Future.wait([
      _firestoreService.getMovieById(booking.movieId),
      _firestoreService.getShowtimeById(booking.showtimeId),
      _firestoreService.getTheaterById(booking.theaterId),
      _firestoreService.getScreenById(booking.screenId),
    ]);
    
    return BookingWithDetails(
      booking: booking,
      movie: results[0]!,
      showtime: results[1]!,
      theater: results[2]!,
      screen: results[3]!,
    );
  }
  
  Stream<List<BookingWithDetails>> getUserBookingsStream(String userId) {
    return _firestoreService.getBookingsByUser(userId).asyncMap((bookings) async {
      return Future.wait(
        bookings.map((booking) => getBookingWithDetails(booking.id))
      );
    });
  }
}

// Helper model
class BookingWithDetails {
  final Booking booking;
  final Movie movie;
  final Showtime showtime;
  final Theater theater;
  final Screen screen;
  
  BookingWithDetails({
    required this.booking,
    required this.movie,
    required this.showtime,
    required this.theater,
    required this.screen,
  });
}
```

**Usage in UI:**
```dart
class TicketScreen extends StatelessWidget {
  final _bookingRepo = BookingRepository(FirestoreService());
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    
    return StreamBuilder<List<BookingWithDetails>>(
      stream: _bookingRepo.getUserBookingsStream(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        final bookingsWithDetails = snapshot.data!;
        
        return ListView.builder(
          itemCount: bookingsWithDetails.length,
          itemBuilder: (context, index) {
            final item = bookingsWithDetails[index];
            
            // ✅ All data available directly
            return TicketCard(
              movie: item.movie,
              showtime: item.showtime,
              theater: item.theater,
              booking: item.booking,
            );
          },
        );
      },
    );
  }
}
```

---

## ✅ CHECKLIST Migration

### Phase 1: Theaters ✅ DONE
- [x] `theaters_screen.dart` - Migrated to Firestore
- [x] `theater_detail_screen.dart` - Updated to use real Theater model
- [x] Remove dependency on `mock_theaters.dart`

### Phase 2: Booking Flow 🔄 IN PROGRESS
- [ ] `booking_screen.dart`
  - [ ] Load showtimes from Firestore
  - [ ] Load screen layout from Firestore
  - [ ] Show real booked seats
  - [ ] Implement real booking creation with transaction
  - [ ] Add error handling & loading states

### Phase 3: Tickets 🔜 TODO
- [ ] `ticket_screen.dart`
  - [ ] Load user bookings from Firestore
  - [ ] Load nested data (movie, showtime, theater)
  - [ ] Implement cancel booking
  - [ ] Show booking status

### Phase 4: Cleanup 🔜 TODO
- [ ] Delete `mock_theaters.dart`
- [ ] Update navigation flows
- [ ] Add analytics
- [ ] Performance optimization

---

## 🐛 Common Issues & Solutions

### Issue 1: "Null check operator used on a null value"
```dart
// ❌ WRONG
final movie = await firestoreService.getMovieById(booking.movieId);
final title = movie.title; // Crash if movie is null

// ✅ CORRECT
final movie = await firestoreService.getMovieById(booking.movieId);
if (movie == null) {
  throw Exception('Movie not found');
}
final title = movie.title;
```

### Issue 2: "Too many Firestore reads"
```dart
// ❌ WRONG - N queries in loop
for (var booking in bookings) {
  final movie = await getMovieById(booking.movieId); // Expensive!
}

// ✅ CORRECT - Batch query
final movieIds = bookings.map((b) => b.movieId).toSet();
final movies = await Future.wait(
  movieIds.map((id) => getMovieById(id))
);
```

### Issue 3: "Stream doesn't update"
```dart
// ❌ WRONG - Using Future
final bookings = await firestoreService.getBookingsByUser(userId);

// ✅ CORRECT - Using Stream
StreamBuilder<List<Booking>>(
  stream: firestoreService.getBookingsByUser(userId),
  ...
)
```

---

## 📚 Resources

- **Firestore Docs:** https://firebase.google.com/docs/firestore
- **Flutter Firebase:** https://firebase.flutter.dev/
- **Best Practices:** https://firebase.google.com/docs/firestore/best-practices

---

## 🎯 Summary

### Completed ✅:
- Theaters Screen → Real-time Firestore data
- Theater Detail Screen → Real Theater model

### Next Steps 🔜:
1. Migrate `booking_screen.dart` (Priority: HIGH)
2. Migrate `ticket_screen.dart` (Priority: HIGH)
3. Add Repository layer (Optional)
4. Performance optimization
5. Error handling improvements

### Estimated Time:
- Booking Screen: 4-6 hours
- Ticket Screen: 2-3 hours
- Testing: 2 hours
- **Total: 8-11 hours**

---

**🚀 Ready to migrate? Start with booking_screen.dart!**
