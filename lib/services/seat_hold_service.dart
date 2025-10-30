// lib/services/seat_hold_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service quản lý giữ chỗ tạm thời (Seat Hold)
/// 
/// ✅ NGHIỆP VỤ:
/// 1. User chọn ghế → Hold trong X phút (default 10 phút)
/// 2. Nếu không thanh toán trong thời gian → Tự động release
/// 3. Sau khi thanh toán thành công → Confirm booking (không release)
/// 4. User có thể cancel hold thủ công
/// 
/// ✅ CÁCH HOẠT ĐỘNG:
/// - Tạo document trong collection `seat_holds`
/// - Document có `expiresAt` timestamp
/// - Background timer tự động xóa expired holds
/// - Khi create booking, check holds để validate
/// 
/// USAGE:
/// ```dart
/// final holdService = SeatHoldService();
/// 
/// // 1. Hold ghế khi user chọn
/// final holdId = await holdService.holdSeats(
///   showtimeId: 'showtime-1',
///   seats: ['A1', 'A2'],
///   userId: user.uid,
///   holdDurationMinutes: 10,
/// );
/// 
/// // 2. Confirm hold khi thanh toán thành công
/// await holdService.confirmHold(holdId);
/// 
/// // 3. Hoặc release nếu user cancel
/// await holdService.releaseHold(holdId);
/// ```
class SeatHoldService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  /// Thời gian hold mặc định (phút)
  static const int defaultHoldDurationMinutes = 10;
  
  /// Timer để cleanup expired holds
  Timer? _cleanupTimer;
  
  /// ✅ Khởi động auto-cleanup service
  /// 
  /// Gọi 1 lần khi app khởi động
  void startAutoCleanup() {
    // Cleanup mỗi 1 phút
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(Duration(minutes: 1), (_) {
      cleanupExpiredHolds();
    });
  }
  
  /// Dừng auto-cleanup
  void stopAutoCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
  
  /// ✅ Giữ chỗ ghế tạm thời
  /// 
  /// @param showtimeId ID lịch chiếu
  /// @param seats Danh sách ghế cần hold
  /// @param userId ID người dùng
  /// @param holdDurationMinutes Thời gian hold (phút)
  /// @return Hold ID nếu thành công, null nếu thất bại
  Future<String?> holdSeats({
    required String showtimeId,
    required List<String> seats,
    required String userId,
    int holdDurationMinutes = defaultHoldDurationMinutes,
  }) async {
    try {
      // 1. Kiểm tra ghế đã được hold hoặc booked chưa
      final conflicts = await _checkSeatAvailability(showtimeId, seats);
      
      if (conflicts.isNotEmpty) {
        print('❌ Không thể hold: Ghế ${conflicts.join(", ")} đã được giữ/đặt');
        return null;
      }
      
      // 2. Tạo hold document
      final expiresAt = DateTime.now().add(Duration(minutes: holdDurationMinutes));
      
      final holdData = {
        'showtimeId': showtimeId,
        'seats': seats,
        'userId': userId,
        'status': 'active', // active | confirmed | released
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'holdDurationMinutes': holdDurationMinutes,
      };
      
      final docRef = await _db.collection('seat_holds').add(holdData);
      
      print('✅ Hold ghế thành công: ${seats.join(", ")}');
      print('   Hold ID: ${docRef.id}');
      print('   Hết hạn lúc: ${expiresAt.hour}:${expiresAt.minute}');
      
      return docRef.id;
      
    } catch (e) {
      print('❌ Lỗi hold ghế: $e');
      return null;
    }
  }
  
  /// ✅ Kiểm tra ghế có available không (chưa hold và chưa booked)
  /// 
  /// @return Danh sách ghế bị conflict
  Future<List<String>> _checkSeatAvailability(
    String showtimeId,
    List<String> seats,
  ) async {
    final conflicts = <String>[];
    
    // 1. Check ghế đã được hold chưa (active holds)
    final holdsSnapshot = await _db
        .collection('seat_holds')
        .where('showtimeId', isEqualTo: showtimeId)
        .where('status', isEqualTo: 'active')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .get();
    
    final heldSeats = <String>{};
    for (var doc in holdsSnapshot.docs) {
      final data = doc.data();
      final seatList = List<String>.from(data['seats'] ?? []);
      heldSeats.addAll(seatList);
    }
    
    // 2. Check ghế đã được booked chưa
    final showtimeDoc = await _db.collection('showtimes').doc(showtimeId).get();
    final bookedSeats = showtimeDoc.exists
        ? List<String>.from(showtimeDoc.data()?['bookedSeats'] ?? [])
        : <String>[];
    
    // 3. Tìm conflicts
    for (var seat in seats) {
      if (heldSeats.contains(seat) || bookedSeats.contains(seat)) {
        conflicts.add(seat);
      }
    }
    
    return conflicts;
  }
  
  /// ✅ Confirm hold (sau khi thanh toán thành công)
  /// 
  /// Hold sẽ được đánh dấu 'confirmed' và không tự động xóa
  Future<bool> confirmHold(String holdId) async {
    try {
      await _db.collection('seat_holds').doc(holdId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Đã confirm hold: $holdId');
      return true;
      
    } catch (e) {
      print('❌ Lỗi confirm hold: $e');
      return false;
    }
  }
  
  /// ✅ Release hold (user cancel hoặc timeout)
  /// 
  /// @param holdId ID của hold
  /// @param reason Lý do release (optional)
  Future<bool> releaseHold(String holdId, {String reason = 'user_cancel'}) async {
    try {
      await _db.collection('seat_holds').doc(holdId).update({
        'status': 'released',
        'releasedAt': FieldValue.serverTimestamp(),
        'releaseReason': reason,
      });
      
      print('✅ Đã release hold: $holdId (reason: $reason)');
      return true;
      
    } catch (e) {
      print('❌ Lỗi release hold: $e');
      return false;
    }
  }
  
  /// ✅ Cleanup các hold đã hết hạn
  /// 
  /// Tự động chạy bởi timer hoặc gọi thủ công
  Future<int> cleanupExpiredHolds() async {
    try {
      final now = Timestamp.now();
      
      // Tìm tất cả active holds đã hết hạn
      final snapshot = await _db
          .collection('seat_holds')
          .where('status', isEqualTo: 'active')
          .where('expiresAt', isLessThanOrEqualTo: now)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return 0;
      }
      
      // Release tất cả expired holds
      final batch = _db.batch();
      
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': 'released',
          'releasedAt': FieldValue.serverTimestamp(),
          'releaseReason': 'expired',
        });
      }
      
      await batch.commit();
      
      print('🧹 Đã cleanup ${snapshot.docs.length} expired holds');
      return snapshot.docs.length;
      
    } catch (e) {
      print('❌ Lỗi cleanup: $e');
      return 0;
    }
  }
  
  /// ✅ Lấy danh sách ghế đang được hold của một showtime
  /// 
  /// Dùng để hiển thị UI (ghế màu vàng = đang hold)
  /// 
  /// @param showtimeId ID lịch chiếu
  /// @param excludeUserId Loại trừ holds của user này (để user thấy ghế mình đang hold)
  /// @return Set của seat IDs
  Future<Set<String>> getHeldSeats(
    String showtimeId, 
    {String? excludeUserId}
  ) async {
    try {
      var query = _db
          .collection('seat_holds')
          .where('showtimeId', isEqualTo: showtimeId)
          .where('status', isEqualTo: 'active')
          .where('expiresAt', isGreaterThan: Timestamp.now());
      
      final snapshot = await query.get();
      
      final heldSeats = <String>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        
        // Skip holds của chính user này
        if (excludeUserId != null && userId == excludeUserId) {
          continue;
        }
        
        final seats = List<String>.from(data['seats'] ?? []);
        heldSeats.addAll(seats);
      }
      
      return heldSeats;
      
    } catch (e) {
      print('❌ Lỗi lấy held seats: $e');
      return {};
    }
  }
  
  /// ✅ Lấy thông tin hold của user cho showtime cụ thể
  /// 
  /// @return Hold document hoặc null
  Future<Map<String, dynamic>?> getUserActiveHold(
    String userId,
    String showtimeId,
  ) async {
    try {
      final snapshot = await _db
          .collection('seat_holds')
          .where('userId', isEqualTo: userId)
          .where('showtimeId', isEqualTo: showtimeId)
          .where('status', isEqualTo: 'active')
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final doc = snapshot.docs.first;
      return {
        'id': doc.id,
        ...doc.data(),
      };
      
    } catch (e) {
      print('❌ Lỗi lấy user hold: $e');
      return null;
    }
  }
  
  /// ✅ Extend hold time (gia hạn thêm thời gian)
  /// 
  /// Dùng khi user cần thêm thời gian
  Future<bool> extendHold(String holdId, int additionalMinutes) async {
    try {
      final doc = await _db.collection('seat_holds').doc(holdId).get();
      
      if (!doc.exists) {
        print('❌ Hold không tồn tại');
        return false;
      }
      
      final data = doc.data()!;
      final currentExpiresAt = (data['expiresAt'] as Timestamp).toDate();
      final newExpiresAt = currentExpiresAt.add(Duration(minutes: additionalMinutes));
      
      await _db.collection('seat_holds').doc(holdId).update({
        'expiresAt': Timestamp.fromDate(newExpiresAt),
        'extendedAt': FieldValue.serverTimestamp(),
        'extendedMinutes': additionalMinutes,
      });
      
      print('✅ Đã gia hạn hold $holdId thêm $additionalMinutes phút');
      return true;
      
    } catch (e) {
      print('❌ Lỗi extend hold: $e');
      return false;
    }
  }
  
  /// ✅ Lấy thời gian còn lại của hold (seconds)
  /// 
  /// @return Số giây còn lại, hoặc 0 nếu đã hết hạn
  Future<int> getHoldRemainingSeconds(String holdId) async {
    try {
      final doc = await _db.collection('seat_holds').doc(holdId).get();
      
      if (!doc.exists) return 0;
      
      final data = doc.data()!;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final remaining = expiresAt.difference(DateTime.now()).inSeconds;
      
      return remaining > 0 ? remaining : 0;
      
    } catch (e) {
      print('❌ Lỗi: $e');
      return 0;
    }
  }
  
  /// ✅ Stream theo dõi hold (real-time countdown)
  /// 
  /// Dùng để hiển thị countdown timer trong UI
  Stream<HoldStatus> watchHold(String holdId) {
    return _db.collection('seat_holds').doc(holdId).snapshots().map((doc) {
      if (!doc.exists) {
        return HoldStatus(
          isActive: false,
          remainingSeconds: 0,
          seats: [],
        );
      }
      
      final data = doc.data()!;
      final status = data['status'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final seats = List<String>.from(data['seats'] ?? []);
      final remaining = expiresAt.difference(DateTime.now()).inSeconds;
      
      return HoldStatus(
        isActive: status == 'active' && remaining > 0,
        remainingSeconds: remaining > 0 ? remaining : 0,
        seats: seats,
        status: status,
      );
    });
  }
  
  /// ✅ Cleanup tất cả holds (dùng khi testing)
  Future<void> clearAllHolds() async {
    try {
      final snapshot = await _db.collection('seat_holds').get();
      final batch = _db.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('🗑️ Đã xóa ${snapshot.docs.length} holds');
      
    } catch (e) {
      print('❌ Lỗi clear holds: $e');
    }
  }
}

/// ========================================
/// MODELS
/// ========================================

/// Trạng thái hold (cho UI stream)
class HoldStatus {
  final bool isActive;
  final int remainingSeconds;
  final List<String> seats;
  final String? status;
  
  HoldStatus({
    required this.isActive,
    required this.remainingSeconds,
    required this.seats,
    this.status,
  });
  
  /// Format countdown (mm:ss)
  String get countdownText {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Còn dưới 1 phút
  bool get isUrgent => remainingSeconds < 60;
  
  /// Còn dưới 30 giây
  bool get isCritical => remainingSeconds < 30;
}
