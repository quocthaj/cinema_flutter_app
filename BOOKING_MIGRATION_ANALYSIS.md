# 🔍 PHÂN TÍCH CHI TIẾT: Booking & Ticket Screens

## 📋 PHẦN 1: HIỆN TRẠNG BOOKING_SCREEN.DART

### ❌ **Vấn đề nghiêm trọng:**

#### 1. **Hardcoded Dates** (Line 18-24)
```dart
final List<String> availableDates = [
  "11/10",  // ❌ Không liên kết với Firestore
  "12/10",
  "13/10",
  "14/10",
  "15/10",
];
```
**Impact:** User chỉ thấy 5 ngày cố định, không phản ánh lịch chiếu thực tế

#### 2. **Hardcoded Times** (Line 26-32)
```dart
final List<String> availableTimes = [
  "10:00",  // ❌ Không có thông tin giá vé
  "13:00",  // ❌ Không biết phòng chiếu nào
  "16:00",  // ❌ Không biết còn ghế không
  "19:00",
  "21:30",
];
```
**Impact:** Không có thông tin showtimeId, screenId, pricing

#### 3. **Hardcoded Seats** (Line 35-51)
```dart
final List<String> seatList = [
  "A1", "A2", "A3", "A4", "A5",
  "B1", "B2", "B3", "B4", "B5",
  "C1", "C2", "C3", "C4", "C5",
];
```
**Impact:** Mọi phim đều có 15 ghế (3 hàng x 5 cột), không realistic

#### 4. **Fake Sold Seats** (Line 14-15)
```dart
final List<String> soldSeats = ["A3", "B1", "C5"];  // ❌ Giả lập
```
**Impact:** Ghế "đã bán" là fake, nhiều user có thể chọn cùng ghế

#### 5. **Fake Booking Creation** (Line 327-335)
```dart
try {
  // ❌ Giả lập xử lý đặt vé (gọi API)
  await Future.delayed(const Duration(seconds: 2));
  
  // ❌ Không save vào Firestore
  // ❌ Không update bookedSeats trong showtime
  // ❌ Không tạo Booking document
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Đặt vé thành công!"), ...)
  );
} catch (e) { ... }
```
**Impact:** User nghĩ đã đặt vé, nhưng thực tế không có gì được lưu

#### 6. **Fixed Ticket Price** (Line 298)
```dart
final double ticketPrice = 100000; // ❌ Giả sử giá vé
```
**Impact:** Không phân biệt ghế thường/VIP, không có dynamic pricing

---

## 📋 PHẦN 2: HIỆN TRẠNG TICKET_SCREEN.DART

### ❌ **Vấn đề:**

#### 1. **Empty List** (Line 11)
```dart
final List<Ticket> userTickets = [];  // ❌ Luôn rỗng
```
**Impact:** User không bao giờ thấy vé của mình

#### 2. **No Firebase Auth Integration**
```dart
// ❌ Không kiểm tra user đã login
// ❌ Không lấy userId từ FirebaseAuth
// ❌ Không query bookings từ Firestore
```

#### 3. **No Real-time Updates**
```dart
// ❌ Không dùng StreamBuilder
// ❌ Khi user đặt vé mới, phải restart app
```

---

## 🎯 PHẦN 3: YÊU CẦU THAY ĐỔI

### **A. Booking Screen - Cần refactor:**

1. ✅ **Load Showtimes từ Firestore**
   - Query: `getShowtimesByMovie(movieId)`
   - Group by date (dd/MM)
   - Show available times for selected date
   - Display: Theater name, Screen name, Available seats

2. ✅ **Load Screen Layout từ Firestore**
   - Query: `getScreenById(screenId)`
   - Get real seat layout (rows, columns, seats)
   - Seat types: standard, vip

3. ✅ **Show Booked Seats**
   - Get from `showtime.bookedSeats`
   - Disable booked seats (màu đỏ)
   - Real-time check before booking

4. ✅ **Calculate Real Price**
   - Base price: `showtime.basePrice`
   - VIP price: `showtime.vipPrice`
   - Total = Σ(seat price based on type)

5. ✅ **Create Real Booking**
   - Call `firestoreService.createBooking(booking)`
   - Use transaction to prevent double booking
   - Update showtime.bookedSeats atomically

6. ✅ **Add FirebaseAuth**
   - Check user logged in
   - Get userId for booking

### **B. Ticket Screen - Cần refactor:**

1. ✅ **Check Login Status**
   - Use `FirebaseAuth.instance.currentUser`
   - Show login prompt if null

2. ✅ **Load User Bookings**
   - Query: `getBookingsByUser(userId)`
   - Use StreamBuilder for real-time updates
   - Order by createdAt DESC (mới nhất trước)

3. ✅ **Load Nested Data**
   - For each booking, load:
     - Movie (by movieId)
     - Showtime (by showtimeId)
     - Theater (by theaterId)
   - Use `Future.wait()` để parallel loading

4. ✅ **Display Booking Cards**
   - Show: Movie poster, title, date/time, theater, seats
   - Booking status badge (pending, confirmed, cancelled)
   - Total price

5. ✅ **Implement Cancel Booking**
   - Call `firestoreService.cancelBooking(bookingId)`
   - Return seats to showtime
   - Update status to 'cancelled'

---

## 📊 PHẦN 4: DATA FLOW MỚI

### **Booking Flow:**

```
User opens BookingScreen(movie)
         ↓
Load Showtimes by movieId
         ↓
User selects Date → Filter showtimes by date
         ↓
User selects Time (Showtime) → Load Screen layout
         ↓
Display seat grid (mark booked seats red)
         ↓
User selects seats → Calculate price
         ↓
User clicks "Xác nhận"
         ↓
Check FirebaseAuth.currentUser
         ↓
Create Booking object
         ↓
firestoreService.createBooking(booking)
   ↓ (Transaction)
   ├─ Check seats still available
   ├─ Create booking document
   └─ Update showtime.bookedSeats
         ↓
Show success message
         ↓
Navigate back or to Ticket Screen
```

### **Ticket Screen Flow:**

```
User opens TicketScreen
         ↓
Check FirebaseAuth.currentUser
         ↓
If null → Show "Vui lòng đăng nhập"
         ↓
If logged in → StreamBuilder<List<Booking>>
         ↓
Query: getBookingsByUser(userId)
         ↓
For each booking:
   ├─ Load Movie (parallel)
   ├─ Load Showtime (parallel)
   └─ Load Theater (parallel)
         ↓
Display booking cards with status
         ↓
User can cancel (if status = pending/confirmed)
         ↓
Call cancelBooking(bookingId)
   ↓ (Transaction)
   ├─ Update booking.status = 'cancelled'
   └─ Return seats to showtime.bookedSeats
         ↓
Real-time update via StreamBuilder
```

---

## 🔧 PHẦN 5: DEPENDENCIES CẦN THÊM

### **Packages:**
```yaml
dependencies:
  firebase_auth: ^4.15.0  # ✅ Đã có trong pubspec.yaml?
  flutter_easyloading: ^3.0.5  # ✅ Đã có
  cloud_firestore: ^4.13.6  # ✅ Đã có
```

### **Services Available:**
```dart
✅ FirestoreService:
  - getShowtimesByMovie(movieId)
  - getScreenById(screenId)
  - getShowtimeById(showtimeId)
  - createBooking(booking)
  - getBookingsByUser(userId)
  - cancelBooking(bookingId)
  - getMovieById(movieId)
  - getTheaterById(theaterId)

✅ FirebaseAuth:
  - FirebaseAuth.instance.currentUser
  - currentUser?.uid
```

---

## 📈 METRICS & VALIDATION

### **Before Migration:**
- ❌ Hardcoded data: 100%
- ❌ Real Firestore usage: 0%
- ❌ User can actually book: No
- ❌ User can see tickets: No
- ❌ Concurrent booking handling: None
- ❌ Price calculation: Fixed 100k VNĐ

### **After Migration (Expected):**
- ✅ Hardcoded data: 0%
- ✅ Real Firestore usage: 100%
- ✅ User can actually book: Yes (with transaction)
- ✅ User can see tickets: Yes (real-time)
- ✅ Concurrent booking handling: Transaction-based
- ✅ Price calculation: Dynamic (base + VIP)

---

## 🎯 IMPLEMENTATION PRIORITY

### **Phase 1: Booking Screen - Showtimes** (2 hours)
1. Add FirestoreService import
2. Add state variables for showtimes
3. Replace hardcoded dates with StreamBuilder
4. Group showtimes by date
5. Filter by selected date

### **Phase 2: Booking Screen - Seats** (2 hours)
1. Load Screen from Firestore
2. Build dynamic seat grid (rows x columns)
3. Mark booked seats from showtime.bookedSeats
4. Calculate price based on seat types

### **Phase 3: Booking Screen - Create Booking** (1 hour)
1. Add FirebaseAuth check
2. Build Booking object
3. Call createBooking()
4. Handle success/error
5. Show confirmation

### **Phase 4: Ticket Screen** (2-3 hours)
1. Add FirebaseAuth check
2. Add StreamBuilder for bookings
3. Load nested data (movie, showtime, theater)
4. Build booking cards
5. Implement cancel booking
6. Add status badges

---

## 🚨 CRITICAL ISSUES TO HANDLE

### **1. Race Condition - Double Booking**
**Problem:** 2 users chọn cùng ghế đồng thời

**Solution:** ✅ Firestore Transaction
```dart
return await _db.runTransaction((transaction) async {
  // Check seats
  if (bookedSeats.contains(seat)) {
    throw Exception('Ghế đã được đặt');
  }
  // Book
  transaction.set(bookingRef, booking.toMap());
  transaction.update(showtimeRef, {'bookedSeats': newSeats});
});
```

### **2. User Not Logged In**
**Problem:** User chưa login nhưng vẫn vào booking

**Solution:** Check FirebaseAuth
```dart
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  // Navigate to login
  Navigator.pushNamed(context, '/login');
  return;
}
```

### **3. Showtime Expired**
**Problem:** User book vé cho suất chiếu đã qua

**Solution:** Filter showtimes
```dart
.where('startTime', isGreaterThan: Timestamp.now())
```

### **4. Too Many Firestore Reads**
**Problem:** Load movie/showtime/theater cho mỗi booking

**Solution:** Use FutureBuilder with caching
```dart
final cache = <String, Movie>{};
if (cache.containsKey(movieId)) {
  return cache[movieId]!;
}
```

---

## ✅ READY TO IMPLEMENT

**Files to modify:**
1. `booking_screen.dart` - Major refactor (~500 lines)
2. `ticket_screen.dart` - Major refactor (~300 lines)

**Files to read (no changes):**
- ✅ `booking_model.dart` - Already complete
- ✅ `showtime.dart` - Already complete
- ✅ `screen_model.dart` - Already complete
- ✅ `firestore_service.dart` - Already has all methods

**Estimated time:** 8-10 hours total

**Next action:** Start refactoring `booking_screen.dart`
