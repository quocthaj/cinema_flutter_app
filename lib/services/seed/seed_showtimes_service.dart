// lib/services/seed/seed_showtimes_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Service để seed Showtimes
class SeedShowtimesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ⏰ Thêm dữ liệu mẫu cho Showtimes
  Future<void> seedShowtimes(
    List<String> movieIds, 
    List<String> theaterIds, 
    List<String> screenIds
  ) async {
    print('⏰ Bắt đầu thêm Showtimes...');
    
    int count = 0;
    final now = DateTime.now();

    try {
      // Tạo lịch chiếu cho 7 ngày tới
      for (int day = 0; day < 7; day++) {
        final date = now.add(Duration(days: day));
        
        // Lấy 5 phim đầu tiên để tạo lịch chiếu
        final moviesToSchedule = movieIds.take(5).toList();
        
        for (var movieId in moviesToSchedule) {
          // Mỗi phim có 4 suất chiếu/ngày
          for (var timeSlot in ['09:30', '13:00', '16:30', '20:00']) {
            final timeParts = timeSlot.split(':');
            final startTime = DateTime(
              date.year, date.month, date.day,
              int.parse(timeParts[0]), int.parse(timeParts[1])
            );
            final endTime = startTime.add(Duration(minutes: 120)); // 2 giờ

            // Random một screen
            final screenId = screenIds[count % screenIds.length];
            
            // Tìm theaterId từ screenId
            final screenDoc = await _db.collection('screens').doc(screenId).get();
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

            await _db.collection('showtimes').add(showtimeData);
            count++;
            
            // Thêm delay nhỏ
            if (count % 10 == 0) {
              print('  ↳ Đã thêm $count lịch chiếu...');
              await Future.delayed(Duration(milliseconds: 200));
            }
          }
        }
      }

      print('🎉 Hoàn thành thêm $count lịch chiếu!\n');
    } catch (e) {
      print('❌ Lỗi khi seed showtimes: $e');
      rethrow;
    }
  }

  /// 🗑️ Xóa tất cả showtimes
  Future<void> clearShowtimes() async {
    print('🗑️ Đang xóa tất cả showtimes...');
    
    try {
      await _deleteCollection('showtimes');
      print('✅ Đã xóa tất cả showtimes\n');
    } catch (e) {
      print('❌ Lỗi khi xóa showtimes: $e');
      rethrow;
    }
  }

  /// Xóa collection với batch
  Future<void> _deleteCollection(String collectionName) async {
    final collection = _db.collection(collectionName);
    const batchSize = 500;
    
    while (true) {
      final snapshot = await collection.limit(batchSize).get();
      
      if (snapshot.docs.isEmpty) {
        break;
      }
      
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('  ↳ Đã xóa ${snapshot.docs.length} documents từ $collectionName');
      
      if (snapshot.docs.length < batchSize) {
        break;
      }
    }
  }
}
