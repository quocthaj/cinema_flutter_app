// Script kiểm tra data integrity
// Chạy: dart run lib/scripts/check_data_integrity.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../services/showtime_validation_service.dart';

Future<void> main() async {
  print('\n' + '='*70);
  print('🔍 KIỂM TRA DATA INTEGRITY - CINEMA FLUTTER APP');
  print('='*70 + '\n');

  try {
    // Initialize Firebase
    print('📱 Đang kết nối Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Đã kết nối Firebase\n');

    final firestore = FirebaseFirestore.instance;
    final validator = ShowtimeValidationService();

    // 1. Kiểm tra số lượng data
    print('📊 1. KIỂM TRA SỐ LƯỢNG DATA:');
    print('-' * 70);
    
    final moviesCount = await firestore.collection('movies').count().get();
    final theatersCount = await firestore.collection('theaters').count().get();
    final screensCount = await firestore.collection('screens').count().get();
    final showtimesCount = await firestore.collection('showtimes').count().get();
    final bookingsCount = await firestore.collection('bookings').count().get();
    final paymentsCount = await firestore.collection('payments').count().get();
    final seatHoldsCount = await firestore.collection('seat_holds').count().get();

    print('   🎬 Movies:     ${moviesCount.count} documents');
    print('   🏢 Theaters:   ${theatersCount.count} documents');
    print('   🪑 Screens:    ${screensCount.count} documents');
    print('   ⏰ Showtimes:  ${showtimesCount.count} documents');
    print('   📝 Bookings:   ${bookingsCount.count} documents');
    print('   💰 Payments:   ${paymentsCount.count} documents');
    print('   🔒 Seat Holds: ${seatHoldsCount.count} documents');
    print('');

    // 2. Kiểm tra showtimes conflicts
    print('🔍 2. KIỂM TRA SHOWTIME CONFLICTS:');
    print('-' * 70);
    
    final conflictMap = await validator.validateAllShowtimes();
    
    if (conflictMap.isEmpty) {
      print('   ✅ KHÔNG CÓ CONFLICT!');
      print('   ✅ Tất cả ${showtimesCount.count} showtimes đều hợp lệ');
    } else {
      print('   ❌ PHÁT HIỆN CONFLICTS!');
      print('   ⚠️  Số showtimes có conflict: ${conflictMap.length}');
      print('');
      
      // Hiển thị chi tiết top 5 conflicts
      int displayCount = 0;
      for (var entry in conflictMap.entries) {
        if (displayCount >= 5) break;
        
        final showtimeId = entry.key;
        final conflicts = entry.value;
        
        print('   Showtime ID: $showtimeId');
        print('   - Có ${conflicts.length} conflicts:');
        
        for (var i = 0; i < conflicts.length && i < 2; i++) {
          final conflict = conflicts[i];
          print('     ${i + 1}. Conflicts với: ${conflict.conflictingShowtimeId}');
          print('        Time: ${_formatDateTime(conflict.conflictingStartTime)} - ${_formatDateTime(conflict.conflictingEndTime)}');
          print('        Reason: ${conflict.reason}');
        }
        
        if (conflicts.length > 2) {
          print('     ... và ${conflicts.length - 2} conflicts khác');
        }
        print('');
        
        displayCount++;
      }
      
      if (conflictMap.length > 5) {
        print('   ... và ${conflictMap.length - 5} showtimes khác có conflicts');
        print('');
      }
    }

    // 3. Kiểm tra orphaned data
    print('🔗 3. KIỂM TRA DATA INTEGRITY (RELATIONSHIPS):');
    print('-' * 70);
    
    // Check showtimes có movieId hợp lệ
    final showtimes = await firestore.collection('showtimes').get();
    final movies = await firestore.collection('movies').get();
    final movieIds = movies.docs.map((doc) => doc.id).toSet();
    
    int orphanedShowtimes = 0;
    for (var showtime in showtimes.docs) {
      final movieId = showtime.data()['movieId'];
      if (!movieIds.contains(movieId)) {
        orphanedShowtimes++;
      }
    }
    
    if (orphanedShowtimes == 0) {
      print('   ✅ Tất cả showtimes có movieId hợp lệ');
    } else {
      print('   ⚠️  Có $orphanedShowtimes showtimes với movieId không tồn tại');
    }

    // Check showtimes có screenId hợp lệ
    final screens = await firestore.collection('screens').get();
    final screenIds = screens.docs.map((doc) => doc.id).toSet();
    
    int orphanedScreens = 0;
    for (var showtime in showtimes.docs) {
      final screenId = showtime.data()['screenId'];
      if (!screenIds.contains(screenId)) {
        orphanedScreens++;
      }
    }
    
    if (orphanedScreens == 0) {
      print('   ✅ Tất cả showtimes có screenId hợp lệ');
    } else {
      print('   ⚠️  Có $orphanedScreens showtimes với screenId không tồn tại');
    }
    
    // Check bookings có showtimeId hợp lệ
    final bookings = await firestore.collection('bookings').get();
    final showtimeIds = showtimes.docs.map((doc) => doc.id).toSet();
    
    int orphanedBookings = 0;
    for (var booking in bookings.docs) {
      final showtimeId = booking.data()['showtimeId'];
      if (!showtimeIds.contains(showtimeId)) {
        orphanedBookings++;
      }
    }
    
    if (orphanedBookings == 0) {
      print('   ✅ Tất cả bookings có showtimeId hợp lệ');
    } else {
      print('   ⚠️  Có $orphanedBookings bookings với showtimeId không tồn tại');
    }

    print('');

    // 4. Kiểm tra seat holds expired
    print('🔒 4. KIỂM TRA SEAT HOLDS:');
    print('-' * 70);
    
    if (seatHoldsCount.count == 0) {
      print('   ℹ️  Chưa có seat holds (collection chưa được tạo)');
      print('   → Sẽ tự động tạo khi dùng SeatHoldService lần đầu');
    } else {
      final seatHolds = await firestore.collection('seat_holds').get();
      int activeHolds = 0;
      int expiredHolds = 0;
      int confirmedHolds = 0;
      
      final now = DateTime.now();
      
      for (var hold in seatHolds.docs) {
        final data = hold.data();
        final status = data['status'] ?? 'active';
        final expiresAt = (data['expiresAt'] as Timestamp).toDate();
        
        if (status == 'confirmed') {
          confirmedHolds++;
        } else if (status == 'released') {
          // Already released
        } else if (expiresAt.isBefore(now)) {
          expiredHolds++;
        } else {
          activeHolds++;
        }
      }
      
      print('   ✅ Active holds: $activeHolds');
      print('   ⏰ Expired holds (cần cleanup): $expiredHolds');
      print('   ✅ Confirmed holds: $confirmedHolds');
    }

    print('');

    // 5. Tổng kết
    print('='*70);
    print('📋 TỔNG KẾT KIỂM TRA:');
    print('='*70);
    
    bool hasIssues = conflictMap.isNotEmpty ||
                     orphanedShowtimes > 0 || 
                     orphanedScreens > 0 || 
                     orphanedBookings > 0;
    
    if (!hasIssues) {
      print('');
      print('   ✅ ✅ ✅ DATA HOÀN TOÀN OK! ✅ ✅ ✅');
      print('');
      print('   → Không cần reseed data');
      print('   → Có thể bắt đầu integrate UI với services mới');
      print('   → Collection seat_holds sẽ tự tạo khi dùng');
      print('');
    } else {
      print('');
      print('   ⚠️  PHÁT HIỆN VẤN ĐỀ!');
      print('');
      
      if (conflictMap.isNotEmpty) {
        print('   ❌ Có ${conflictMap.length} showtimes có conflicts');
        print('   → Khuyến nghị: Chạy SyncSeedService để fix');
      }
      
      if (orphanedShowtimes > 0 || orphanedScreens > 0) {
        print('   ⚠️  Có data orphaned (references không hợp lệ)');
        print('   → Khuyến nghị: Reseed data hoặc fix manual');
      }
      
      if (orphanedBookings > 0) {
        print('   ⚠️  Có $orphanedBookings bookings với showtimeId không tồn tại');
        print('   → Khuyến nghị: Fix manual hoặc xóa bookings lỗi');
      }
      
      print('');
    }
    
    print('='*70);
    print('🏁 HOÀN TẤT KIỂM TRA');
    print('='*70 + '\n');

  } catch (e, stackTrace) {
    print('❌ LỖI KHI KIỂM TRA:');
    print(e);
    print('\nStack trace:');
    print(stackTrace);
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
