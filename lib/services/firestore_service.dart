// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/movie.dart';
import '/models/theater_model.dart';
import '/models/screen_model.dart';
import '/models/showtime.dart';
import '/models/booking_model.dart';
import '/models/payment_model.dart';
import '/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========================================
  // 🎬 QUẢN LÝ PHIM (MOVIES)
  // ========================================

  /// Lấy danh sách phim theo real-time
  Stream<List<Movie>> getMoviesStream() {
    return _db
        .collection('movies')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Movie.fromFirestore(doc))
            .toList());
  }

  /// Lấy phim theo trạng thái
  Stream<List<Movie>> getMoviesByStatus(String status) {
    return _db
        .collection('movies')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Movie.fromFirestore(doc))
            .toList());
  }

  /// Lấy chi tiết một phim
  Future<Movie?> getMovieById(String movieId) async {
    final doc = await _db.collection('movies').doc(movieId).get();
    if (doc.exists) {
      return Movie.fromFirestore(doc);
    }
    return null;
  }

  /// Thêm phim mới
  Future<String> addMovie(Movie movie) async {
    final docRef = await _db.collection('movies').add(movie.toMap());
    return docRef.id;
  }

  /// Cập nhật phim
  Future<void> updateMovie(String movieId, Map<String, dynamic> data) async {
    await _db.collection('movies').doc(movieId).update(data);
  }

  /// Xóa phim
  Future<void> deleteMovie(String movieId) async {
    await _db.collection('movies').doc(movieId).delete();
  }

  // ========================================
  // 🏢 QUẢN LÝ RẠP CHIẾU (THEATERS)
  // ========================================

  /// Lấy danh sách rạp theo real-time
  Stream<List<Theater>> getTheatersStream() {
    return _db
        .collection('theaters')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Theater.fromFirestore(doc))
            .toList());
  }

  /// Lấy danh sách rạp theo thành phố
  Stream<List<Theater>> getTheatersByCity(String city) {
    return _db
        .collection('theaters')
        .where('city', isEqualTo: city)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Theater.fromFirestore(doc))
            .toList());
  }

  /// Lấy chi tiết một rạp
  Future<Theater?> getTheaterById(String theaterId) async {
    final doc = await _db.collection('theaters').doc(theaterId).get();
    if (doc.exists) {
      return Theater.fromFirestore(doc);
    }
    return null;
  }

  /// Thêm rạp mới
  Future<String> addTheater(Theater theater) async {
    final docRef = await _db.collection('theaters').add(theater.toMap());
    return docRef.id;
  }

  // ========================================
  // 🪑 QUẢN LÝ PHÒNG CHIẾU (SCREENS)
  // ========================================

  /// Lấy danh sách phòng chiếu của một rạp
  Stream<List<Screen>> getScreensByTheater(String theaterId) {
    return _db
        .collection('screens')
        .where('theaterId', isEqualTo: theaterId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Screen.fromFirestore(doc))
            .toList());
  }

  /// Lấy chi tiết một phòng chiếu
  Future<Screen?> getScreenById(String screenId) async {
    final doc = await _db.collection('screens').doc(screenId).get();
    if (doc.exists) {
      return Screen.fromFirestore(doc);
    }
    return null;
  }

  /// Thêm phòng chiếu mới
  Future<String> addScreen(Screen screen) async {
    final docRef = await _db.collection('screens').add(screen.toMap());
    return docRef.id;
  }

  // ========================================
  // ⏰ QUẢN LÝ LỊCH CHIẾU (SHOWTIMES)
  // ========================================

  /// Lấy lịch chiếu theo phim
  Stream<List<Showtime>> getShowtimesByMovie(String movieId) {
    return _db
        .collection('showtimes')
        .where('movieId', isEqualTo: movieId)
        .where('status', isEqualTo: 'active')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Showtime.fromFirestore(doc))
            .toList());
  }

  /// Lấy lịch chiếu theo rạp và ngày
  Stream<List<Showtime>> getShowtimesByTheaterAndDate(
    String theaterId, 
    DateTime date
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return _db
        .collection('showtimes')
        .where('theaterId', isEqualTo: theaterId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: 'active')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Showtime.fromFirestore(doc))
            .toList());
  }

  /// Lấy chi tiết một lịch chiếu
  Future<Showtime?> getShowtimeById(String showtimeId) async {
    final doc = await _db.collection('showtimes').doc(showtimeId).get();
    if (doc.exists) {
      return Showtime.fromFirestore(doc);
    }
    return null;
  }

  /// Thêm lịch chiếu mới
  Future<String> addShowtime(Showtime showtime) async {
    final docRef = await _db.collection('showtimes').add(showtime.toMap());
    return docRef.id;
  }

  /// Cập nhật ghế đã đặt trong showtime
  Future<void> updateBookedSeats(String showtimeId, List<String> bookedSeats) async {
    await _db.collection('showtimes').doc(showtimeId).update({
      'bookedSeats': bookedSeats,
      'availableSeats': FieldValue.increment(-bookedSeats.length),
    });
  }

  // ========================================
  // 🎟️ QUẢN LÝ ĐẶT VÉ (BOOKINGS)
  // ========================================

  /// Tạo booking mới
  Future<String> createBooking(Booking booking) async {
    // Sử dụng transaction để đảm bảo tính nhất quán
    return await _db.runTransaction((transaction) async {
      // 1. Kiểm tra ghế còn trống
      final showtimeRef = _db.collection('showtimes').doc(booking.showtimeId);
      final showtimeDoc = await transaction.get(showtimeRef);
      
      if (!showtimeDoc.exists) {
        throw Exception('Lịch chiếu không tồn tại');
      }

      final bookedSeats = List<String>.from(showtimeDoc.data()?['bookedSeats'] ?? []);
      
      // Kiểm tra ghế đã được đặt chưa
      for (var seat in booking.selectedSeats) {
        if (bookedSeats.contains(seat)) {
          throw Exception('Ghế $seat đã được đặt');
        }
      }

      // 2. Tạo booking
      final bookingRef = _db.collection('bookings').doc();
      transaction.set(bookingRef, booking.toMap());

      // 3. Cập nhật ghế đã đặt trong showtime
      final newBookedSeats = [...bookedSeats, ...booking.selectedSeats];
      transaction.update(showtimeRef, {
        'bookedSeats': newBookedSeats,
        'availableSeats': FieldValue.increment(-booking.selectedSeats.length),
      });

      return bookingRef.id;
    });
  }

  /// Lấy danh sách booking của user
  Stream<List<Booking>> getBookingsByUser(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(doc))
            .toList());
  }

  /// Lấy chi tiết một booking
  Future<Booking?> getBookingById(String bookingId) async {
    final doc = await _db.collection('bookings').doc(bookingId).get();
    if (doc.exists) {
      return Booking.fromFirestore(doc);
    }
    return null;
  }

  /// Cập nhật trạng thái booking
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Hủy booking
  Future<void> cancelBooking(String bookingId) async {
    return await _db.runTransaction((transaction) async {
      final bookingRef = _db.collection('bookings').doc(bookingId);
      final bookingDoc = await transaction.get(bookingRef);

      if (!bookingDoc.exists) {
        throw Exception('Booking không tồn tại');
      }

      final booking = Booking.fromFirestore(bookingDoc);
      
      // 1. Cập nhật trạng thái booking
      transaction.update(bookingRef, {
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Trả lại ghế cho showtime
      final showtimeRef = _db.collection('showtimes').doc(booking.showtimeId);
      final showtimeDoc = await transaction.get(showtimeRef);
      
      if (showtimeDoc.exists) {
        final bookedSeats = List<String>.from(showtimeDoc.data()?['bookedSeats'] ?? []);
        bookedSeats.removeWhere((seat) => booking.selectedSeats.contains(seat));
        
        transaction.update(showtimeRef, {
          'bookedSeats': bookedSeats,
          'availableSeats': FieldValue.increment(booking.selectedSeats.length),
        });
      }
    });
  }

  // ========================================
  // 💳 QUẢN LÝ THANH TOÁN (PAYMENTS)
  // ========================================

  /// Tạo payment mới
  Future<String> createPayment(Payment payment) async {
    final docRef = await _db.collection('payments').add(payment.toMap());
    
    // Cập nhật paymentId vào booking
    await _db.collection('bookings').doc(payment.bookingId).update({
      'paymentId': docRef.id,
    });
    
    return docRef.id;
  }

  /// Lấy payment theo booking
  Future<Payment?> getPaymentByBooking(String bookingId) async {
    final snapshot = await _db
        .collection('payments')
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Payment.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  /// Cập nhật trạng thái payment
  Future<void> updatePaymentStatus(
    String paymentId, 
    String status, 
    {String? transactionId}
  ) async {
    final data = <String, dynamic>{
      'status': status,
    };

    if (status == 'success') {
      data['completedAt'] = FieldValue.serverTimestamp();
    }

    if (transactionId != null) {
      data['transactionId'] = transactionId;
    }

    await _db.collection('payments').doc(paymentId).update(data);
  }

  // ========================================
  // 👤 QUẢN LÝ NGƯỜI DÙNG (USERS)
  // ========================================

  /// Tạo hoặc cập nhật user document
  /// 🔥 ADMIN: Tạo user document với auto-promote nếu trong whitelist
  Future<void> createUserDocument(User user, [String? displayName, String? role]) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.displayName ?? 'User',
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'favoriteMovies': [],
        'phoneNumber': null,
        'membershipLevel': 'Đồng',
        'points': 0,
        'role': role ?? 'user', // 🔥 ADMIN: Set role (mặc định 'user')
      });
    }
  }

  /// Lấy thông tin user
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// Cập nhật thông tin user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  /// Lấy thông tin chi tiết của người dùng từ Firestore
  Future<UserModel?> getUserDocument(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Cập nhật thông tin người dùng trên Firestore
  Future<void> updateUserData(
      String uid, Map<String, dynamic> dataToUpdate) async {
    if (uid.isEmpty) return;
    try {
      await _db.collection('users').doc(uid).update(dataToUpdate);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy stream bookings của user
  Stream<QuerySnapshot> getUserBookingsStream(String userId) {
    if (userId.isEmpty) {
      return const Stream.empty();
    }
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingTime', descending: true)
        .snapshots();
  }

  /// Thêm phim yêu thích
  Future<void> addFavoriteMovie(String userId, String movieId) async {
    await _db.collection('users').doc(userId).update({
      'favoriteMovies': FieldValue.arrayUnion([movieId]),
    });
  }

  /// Xóa phim yêu thích
  Future<void> removeFavoriteMovie(String userId, String movieId) async {
    await _db.collection('users').doc(userId).update({
      'favoriteMovies': FieldValue.arrayRemove([movieId]),
    });
  }
}
