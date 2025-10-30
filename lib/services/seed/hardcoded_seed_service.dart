// lib/services/seed/hardcoded_seed_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'hardcoded_movies_data.dart';
import 'hardcoded_theaters_data.dart';
import 'hardcoded_screens_data.dart';
import 'hardcoded_showtimes_data.dart';
import 'hardcoded_showtimes_hcm_data.dart';
import 'hardcoded_showtimes_danang_data.dart';

/// ✅ REFACTORED: Service để seed dữ liệu CỨNG vào Firestore
/// 
/// THAY ĐỔI LỚN:
/// ================
/// 1. SCREENS: Real layout với aisles
///    - Standard: 8×10 - 2 aisles = 64 ghế
///    - VIP: 6×8 - 2 aisles = 36 ghế
///    - IMAX: 10×12 - 2 aisles = 100 ghế
/// 
/// 2. DYNAMIC PRICING: 6 yếu tố
///    - Screen type: Standard/VIP/IMAX
///    - Movie type: 2D/3D
///    - Time of day: Morning/Lunch/Afternoon/Evening/Night
///    - Day of week: Weekday/Weekend
///    - Seat type: Standard/VIP
///    - Base price: 60,000 VNĐ
///    - Result: 48,000đ - 180,000đ
/// 
/// 3. SHOWTIMES: Realistic scheduling
///    - 6 time slots/day (09:00, 11:30, 14:00, 16:30, 19:00, 21:30)
///    - Movie duration + 15 min buffer
///    - Weekend pricing applied
/// 
/// DATA STRUCTURE:
/// ================
/// - 15 phim
/// - 11 rạp (4 HN + 4 HCM + 3 ĐN)
/// - 47 phòng chiếu (17 HN + 18 HCM + 12 ĐN)
///   + 4 IMAX (1 HN + 3 HCM)
///   + 11 VIP
///   + 32 Standard
/// - ~282 suất/ngày × 7 ngày = ~1,974 suất tổng
class HardcodedSeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Callback để báo cáo tiến trình
  Function(double progress, String message)? onProgress;

  /// 🚀 Seed tất cả dữ liệu cứng
  Future<void> seedAll() async {
    print('\n' + '='*60);
    print('🚀 BẮT ĐẦU SEED DỮ LIỆU CỨNG MỚI (KHÔNG TRÙNG)');
    print('='*60 + '\n');
    
    try {
      // 1. Seed movies (5% tổng)
      onProgress?.call(0.0, '🎬 Đang seed movies...');
      print('🎬 1. Đang seed movies...');
      final movieIds = await _seedMovies();
      print('   ✅ Đã seed ${movieIds.length} phim\n');
      onProgress?.call(0.05, 'Đã seed ${movieIds.length} phim');
      await Future.delayed(Duration(milliseconds: 500));

      // 2. Seed theaters (10% tổng)
      onProgress?.call(0.05, '🏢 Đang seed theaters...');
      print('🏢 2. Đang seed theaters...');
      final theaterIds = await _seedTheaters();
      print('   ✅ Đã seed ${theaterIds.length} rạp\n');
      onProgress?.call(0.10, 'Đã seed ${theaterIds.length} rạp');
      await Future.delayed(Duration(milliseconds: 500));

      // 3. Seed screens (15% tổng)
      onProgress?.call(0.10, '🪑 Đang seed screens...');
      print('🪑 3. Đang seed screens...');
      final screenIds = await _seedScreens(theaterIds);
      print('   ✅ Đã seed ${screenIds.length} phòng chiếu\n');
      onProgress?.call(0.15, 'Đã seed ${screenIds.length} phòng chiếu');
      await Future.delayed(Duration(milliseconds: 500));

      // 4. Seed showtimes (15% -> 100%, chiếm 85% tổng)
      onProgress?.call(0.15, '⏰ Đang seed showtimes (7 ngày)...');
      print('⏰ 4. Đang seed showtimes (7 ngày: 29/10 - 04/11/2025)...');
      final showtimeCount = await _seedShowtimes(movieIds, theaterIds, screenIds);
      print('   ✅ Đã seed $showtimeCount suất chiếu\n');
      onProgress?.call(1.0, '✅ Hoàn thành!');

      // Summary
      print('='*60);
      print('🎉 HOÀN THÀNH SEED DỮ LIỆU REFACTORED!');
      print('='*60);
      print('📊 TỔNG KẾT:');
      print('   📽️  ${movieIds.length} phim');
      print('   🎭 ${theaterIds.length} rạp chiếu');
      print('   🪑 ${screenIds.length} phòng chiếu');
      print('   ⏰ $showtimeCount suất chiếu (7 ngày)');
      print('');
      print('💡 ĐẶC ĐIỂM MỚI:');
      print('   ✅ Layout thực tế: Standard (64), VIP (36), IMAX (100) ghế');
      print('   ✅ Có lối đi giữa (aisles) - giống rạp thật');
      print('   ✅ Dynamic pricing (6 yếu tố)');
      print('   ✅ Weekend pricing (+15%)');
      print('   ✅ Time-based pricing (Sáng -20%, Tối +20%)');
      print('   ✅ Screen type pricing (IMAX +50%, VIP +20%)');
      print('   ✅ Movie type pricing (3D +30%)');
      print('   ✅ Price range: 48,000đ - 180,000đ');
      print('='*60 + '\n');

    } catch (e, stackTrace) {
      onProgress?.call(0.0, '❌ Lỗi: $e');
      print('❌ LỖI KHI SEED: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 🎬 Seed movies
  Future<Map<String, String>> _seedMovies() async {
    final movieIds = <String, String>{}; // externalId -> firestoreId
    final batch = _db.batch();
    int count = 0;

    for (var movieData in HardcodedMoviesData.allMovies) {
      final externalId = movieData['externalId'] as String;
      final docRef = _db.collection('movies').doc();
      
      batch.set(docRef, {
        ...movieData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      movieIds[externalId] = docRef.id;
      count++;

      if (count % 500 == 0) {
        await batch.commit();
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    await batch.commit();
    return movieIds;
  }

  /// 🏢 Seed theaters
  Future<Map<String, String>> _seedTheaters() async {
    final theaterIds = <String, String>{}; // externalId -> firestoreId
    final batch = _db.batch();
    int count = 0;

    for (var theaterData in HardcodedTheatersData.allTheaters) {
      final externalId = theaterData['externalId'] as String;
      final docRef = _db.collection('theaters').doc();
      
      batch.set(docRef, {
        'name': theaterData['name'],
        'address': theaterData['address'],
        'city': theaterData['city'],
        'phone': theaterData['phone'],
        'screens': [], // Sẽ update sau khi tạo screens
        'createdAt': FieldValue.serverTimestamp(),
      });

      theaterIds[externalId] = docRef.id;
      count++;

      if (count % 500 == 0) {
        await batch.commit();
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    await batch.commit();
    return theaterIds;
  }

  /// 🪑 Seed screens
  Future<Map<String, String>> _seedScreens(Map<String, String> theaterIds) async {
    final screenIds = <String, String>{}; // externalId -> firestoreId
    final theaterScreens = <String, List<String>>{}; // theaterId -> [screenIds]
    
    var batch = _db.batch();
    int count = 0;

    for (var screenData in HardcodedScreensData.allScreens) {
      final screenExternalId = screenData['externalId'] as String;
      final theaterExternalId = screenData['theaterExternalId'] as String;
      final theaterFirestoreId = theaterIds[theaterExternalId];

      if (theaterFirestoreId == null) {
        print('⚠️  Không tìm thấy theater: $theaterExternalId');
        continue;
      }

      final docRef = _db.collection('screens').doc();
      
      batch.set(docRef, {
        'theaterId': theaterFirestoreId,
        'name': screenData['name'],
        'totalSeats': screenData['totalSeats'],
        'rows': screenData['rows'],
        'columns': screenData['columns'],
        'seats': screenData['seats'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      screenIds[screenExternalId] = docRef.id;

      // Track screens cho theater
      theaterScreens.putIfAbsent(theaterFirestoreId, () => []);
      theaterScreens[theaterFirestoreId]!.add(docRef.id);

      count++;

      if (count % 500 == 0) {
        await batch.commit();
        batch = _db.batch();
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    await batch.commit();

    // Update theaters với danh sách screens
    batch = _db.batch();
    for (var entry in theaterScreens.entries) {
      final theaterRef = _db.collection('theaters').doc(entry.key);
      batch.update(theaterRef, {'screens': entry.value});
    }
    await batch.commit();

    return screenIds;
  }

  /// 🔄 Xáo trộn showtimes theo ngày để tạo sự đa dạng
  /// Mỗi ngày sẽ có pattern phim khác nhau trong cùng 1 rạp
  List<Map<String, dynamic>> _rotateShowtimesByDay(
    List<Map<String, dynamic>> showtimes,
    int dayIndex,
  ) {
    // Nhóm showtimes theo theater + screen
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var showtime in showtimes) {
      final key = '${showtime['theaterExternalId']}-${showtime['screenExternalId']}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(showtime);
    }
    
    // Xáo trộn movies trong mỗi screen theo dayIndex
    final List<Map<String, dynamic>> rotated = [];
    
    for (var entry in grouped.entries) {
      final showtimesInScreen = entry.value;
      
      // Lấy danh sách unique movies
      final movieIds = showtimesInScreen
          .map((s) => s['movieExternalId'] as String)
          .toSet()
          .toList();
      
      // Rotate movies theo dayIndex
      final rotatedMovieIds = _rotateList(movieIds, dayIndex);
      
      // Tạo map từ movie cũ -> movie mới
      final movieMapping = <String, String>{};
      for (var i = 0; i < movieIds.length; i++) {
        movieMapping[movieIds[i]] = rotatedMovieIds[i];
      }
      
      // Apply mapping vào showtimes
      for (var showtime in showtimesInScreen) {
        final oldMovieId = showtime['movieExternalId'] as String;
        final newMovieId = movieMapping[oldMovieId] ?? oldMovieId;
        
        rotated.add({
          ...showtime,
          'movieExternalId': newMovieId,
        });
      }
    }
    
    return rotated;
  }

  /// Rotate list theo offset
  List<T> _rotateList<T>(List<T> list, int offset) {
    if (list.isEmpty) return list;
    final actualOffset = offset % list.length;
    return [...list.sublist(actualOffset), ...list.sublist(0, actualOffset)];
  }

  /// ⏰ Seed showtimes (7 ngày)
  Future<int> _seedShowtimes(
    Map<String, String> movieIds,
    Map<String, String> theaterIds,
    Map<String, String> screenIds,
  ) async {
    int count = 0;

    // Tất cả showtime templates
    final allShowtimes = [
      ...HardcodedShowtimesData.allHanoiShowtimes,
      ...HardcodedShowtimesHCMData.allHCMShowtimes,
      ...HardcodedShowtimesDanangData.allDaNangShowtimes,
    ];

    print('   📋 Tổng số templates: ${allShowtimes.length}');

    // 7 ngày: 29/10 - 04/11/2025
    final dates = [
      "2025-10-29",
      "2025-10-30",
      "2025-10-31",
      "2025-11-01",
      "2025-11-02",
      "2025-11-03",
      "2025-11-04",
    ];

    for (var i = 0; i < dates.length; i++) {
      final dateStr = dates[i];
      // Progress từ 15% -> 100% (85% cho showtimes)
      final progressStart = 0.15 + (i / dates.length) * 0.85;
      onProgress?.call(progressStart, '⏰ Seed ngày ${i + 1}/7: $dateStr');
      print('   📅 Đang seed ngày $dateStr...');
      var batch = _db.batch();
      int batchCount = 0;
      int dailyCount = 0;

      // ✅ Xáo trộn showtimes theo ngày để mỗi ngày khác nhau
      // Rotate danh sách theo index ngày (i)
      final rotatedShowtimes = _rotateShowtimesByDay(allShowtimes, i);

      for (var showtimeData in rotatedShowtimes) {
        final movieExternalId = showtimeData['movieExternalId'] as String;
        final theaterExternalId = showtimeData['theaterExternalId'] as String;
        final screenExternalId = showtimeData['screenExternalId'] as String;
        final screenType = showtimeData['screenType'] as String;
        final time = showtimeData['time'] as String;
        final duration = showtimeData['duration'] as int;

        // Resolve IDs
        final movieFirestoreId = movieIds[movieExternalId];
        final theaterFirestoreId = theaterIds[theaterExternalId];
        final screenFirestoreId = screenIds[screenExternalId];

        if (movieFirestoreId == null || theaterFirestoreId == null || screenFirestoreId == null) {
          print('      ⚠️  Bỏ qua: movie=$movieExternalId, theater=$theaterExternalId, screen=$screenExternalId');
          continue;
        }

        // Parse time và tạo DateTime
        final startTime = DateTime.parse('$dateStr $time:00');
        final endTime = startTime.add(Duration(minutes: duration + 15)); // Movie + 15 min buffer

        // Determine isWeekend
        final isWeekend = startTime.weekday == DateTime.saturday || 
                         startTime.weekday == DateTime.sunday;

        // Recalculate prices for this specific date (weekend pricing)
        final movieType = HardcodedShowtimesData.movieTypes[movieExternalId] ?? '2d';
        final basePrice = HardcodedShowtimesData.calculatePrice(
          screenType: screenType,
          movieType: movieType,
          time: time,
          isWeekend: isWeekend,
          isVipSeat: false,
        );
        
        final vipPrice = HardcodedShowtimesData.calculatePrice(
          screenType: screenType,
          movieType: movieType,
          time: time,
          isWeekend: isWeekend,
          isVipSeat: true,
        );

        // Determine total seats based on screen type
        int totalSeats;
        if (screenType == 'imax') {
          totalSeats = 100; // 10×12 - 2 aisles
        } else if (screenType == 'vip') {
          totalSeats = 36; // 6×8 - 2 aisles
        } else {
          totalSeats = 64; // 8×10 - 2 aisles (standard)
        }

        final docRef = _db.collection('showtimes').doc();
        batch.set(docRef, {
          'movieId': movieFirestoreId,
          'theaterId': theaterFirestoreId,
          'screenId': screenFirestoreId,
          'startTime': Timestamp.fromDate(startTime),
          'endTime': Timestamp.fromDate(endTime),
          'basePrice': basePrice,
          'vipPrice': vipPrice,
          'availableSeats': totalSeats,
          'totalSeats': totalSeats,
          'bookedSeats': [],
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });

        count++;
        dailyCount++;
        batchCount++;

        if (batchCount >= 500) {
          await batch.commit();
          batch = _db.batch();
          batchCount = 0;
          await Future.delayed(Duration(milliseconds: 100));
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      print('      ✅ Đã seed $dailyCount suất cho ngày $dateStr');
      
      // Update progress sau mỗi ngày
      final progressEnd = 0.15 + ((i + 1) / dates.length) * 0.85;
      onProgress?.call(progressEnd, 'Hoàn thành ngày ${i + 1}/7');
    }

    return count;
  }

  /// 🗑️ Xóa tất cả dữ liệu
  Future<void> clearAll() async {
    onProgress?.call(0.0, '🗑️ Đang xóa dữ liệu...');
    print('🗑️ Đang xóa tất cả dữ liệu...\n');
    
    final collections = ['bookings', 'payments', 'showtimes', 'screens', 'theaters', 'movies'];
    
    for (var i = 0; i < collections.length; i++) {
      final collectionName = collections[i];
      final progress = (i + 1) / collections.length;
      onProgress?.call(progress, 'Xóa $collectionName...');
      try {
        await _deleteCollection(collectionName);
        print('✅ Đã xóa collection: $collectionName');
      } catch (e) {
        print('❌ Lỗi khi xóa $collectionName: $e');
      }
    }
    
    onProgress?.call(1.0, '✅ Đã xóa xong!');
    print('\n🎉 Hoàn thành xóa dữ liệu!\n');
  }

  /// 🗑️ Xóa một collection cụ thể
  Future<void> clearCollection(String collectionName) async {
    print('🗑️ Đang xóa collection: $collectionName...');
    await _deleteCollection(collectionName);
    print('✅ Đã xóa collection: $collectionName\n');
  }

  /// Helper: Xóa collection với batch
  Future<void> _deleteCollection(String collectionName) async {
    final collection = _db.collection(collectionName);
    const batchSize = 500;
    
    while (true) {
      final snapshot = await collection.limit(batchSize).get();
      
      if (snapshot.docs.isEmpty) break;
      
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      if (snapshot.docs.length < batchSize) break;
    }
  }
}
