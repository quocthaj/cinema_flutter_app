// lib/services/seed/sync_seed_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'hardcoded_movies_data.dart';
import 'hardcoded_theaters_data.dart';
import 'hardcoded_screens_data.dart';
import 'hardcoded_showtimes_data.dart';
import 'hardcoded_showtimes_hcm_data.dart';
import 'hardcoded_showtimes_danang_data.dart';
import 'hardcoded_news_data.dart';

/// Service seed data với logic SYNC thông minh
/// 
/// ✅ LOGIC MỚI - KHÔNG MẤT DỮ LIỆU:
/// 1. Nếu bản ghi đã tồn tại (dựa vào externalId) → **SO SÁNH và UPDATE nếu khác**
/// 2. Nếu chưa tồn tại → **INSERT mới**
/// 3. Nếu có thêm bản ghi mới trong code → **THÊM không trùng ID**
/// 4. **KHÔNG XÓA** dữ liệu bookings, payments, users
/// 
/// ✅ ƯU ĐIỂM:
/// - Có thể chạy nhiều lần mà không mất dữ liệu user (bookings)
/// - Update được metadata phim khi có thay đổi (poster, rating, etc.)
/// - Thêm được phim/rạp mới mà không ảnh hưởng dữ liệu cũ
/// 
/// USAGE:
/// ```dart
/// final service = SyncSeedService();
/// 
/// // Sync tất cả (an toàn, không mất booking)
/// await service.syncAll();
/// 
/// // Hoặc sync từng phần
/// await service.syncMovies();
/// await service.syncTheaters();
/// ```
class SyncSeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Function(double progress, String message)? onProgress;
  
  /// ✅ Sync tất cả dữ liệu (movies, theaters, screens, showtimes)
  Future<SyncReport> syncAll() async {
    print('\n' + '='*60);
    print('🔄 BẮT ĐẦU SYNC DỮ LIỆU (SMART MODE)');
    print('='*60 + '\n');
    
    final report = SyncReport();
    
    try {
      // 1. Sync movies
      onProgress?.call(0.0, 'Đang sync movies...');
      print('🎬 1. Sync Movies...');
      final movieResult = await syncMovies();
      report.movies = movieResult;
      print('   ✅ ${movieResult.summary}\n');
      onProgress?.call(0.25, 'Đã sync ${movieResult.total} movies');
      
  // 1.5 Sync news/promotions
  onProgress?.call(0.26, 'Đang sync news/promotions...');
  print('📰 1.5. Sync News/Promotions...');
  final newsResult = await syncNews();
  report.news = newsResult;
  print('   ✅ ${newsResult.summary}\n');
  onProgress?.call(0.30, 'Đã sync ${newsResult.total} news');
      
      // 2. Sync theaters
      onProgress?.call(0.25, 'Đang sync theaters...');
      print('🏢 2. Sync Theaters...');
      final theaterResult = await syncTheaters();
      report.theaters = theaterResult;
      print('   ✅ ${theaterResult.summary}\n');
      onProgress?.call(0.5, 'Đã sync ${theaterResult.total} theaters');
      
      // 3. Sync screens
      onProgress?.call(0.5, 'Đang sync screens...');
      print('🪑 3. Sync Screens...');
      final screenResult = await syncScreens();
      report.screens = screenResult;
      print('   ✅ ${screenResult.summary}\n');
      onProgress?.call(0.75, 'Đã sync ${screenResult.total} screens');
      
      // 4. Sync showtimes
      onProgress?.call(0.75, 'Đang sync showtimes...');
      print('⏰ 4. Sync Showtimes...');
      final showtimeResult = await syncShowtimes();
      report.showtimes = showtimeResult;
      print('   ✅ ${showtimeResult.summary}\n');
      onProgress?.call(1.0, 'Hoàn thành!');
      
      // Print summary
      report.printSummary();
      
      return report;
      
    } catch (e, stackTrace) {
      print('❌ LỖI SYNC: $e');
      print('Stack trace: $stackTrace');
      onProgress?.call(0.0, 'Lỗi: $e');
      rethrow;
    }
  }
  
  /// ✅ Sync movies - So sánh và update/insert
  Future<SyncResult> syncMovies() async {
    final result = SyncResult(collectionName: 'movies');
    
    try {
      // Lấy tất cả movies hiện có
      final snapshot = await _db.collection('movies').get();
      final existingMovies = <String, String>{}; // externalId → firestoreId
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final externalId = data['externalId'] as String?;
        if (externalId != null) {
          existingMovies[externalId] = doc.id;
        }
      }
      
      // Sync từng movie
      for (var movieData in HardcodedMoviesData.allMovies) {
        final externalId = movieData['externalId'] as String;
        
        if (existingMovies.containsKey(externalId)) {
          // Movie đã tồn tại → so sánh và update nếu cần
          final firestoreId = existingMovies[externalId]!;
          final needsUpdate = await _needsUpdate(
            'movies',
            firestoreId,
            movieData,
          );
          
          if (needsUpdate) {
            await _db.collection('movies').doc(firestoreId).update({
              ...movieData,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            result.updated++;
            print('   📝 Updated: ${movieData['title']}');
          } else {
            result.unchanged++;
          }
        } else {
          // Movie mới → insert
          await _db.collection('movies').add({
            ...movieData,
            'createdAt': FieldValue.serverTimestamp(),
          });
          result.inserted++;
          print('   ➕ Inserted: ${movieData['title']}');
        }
      }
      
    } catch (e) {
      print('❌ Lỗi sync movies: $e');
      result.error = e.toString();
    }
    
    return result;
  }

  /// ✅ Sync news & promotions from hardcoded data
  Future<SyncResult> syncNews() async {
    final result = SyncResult(collectionName: 'news');

    try {
      // Lấy tất cả news hiện có
      final snapshot = await _db.collection('news').get();
      final existing = <String, String>{}; // externalId -> firestoreId

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final externalId = data['externalId'] as String?;
        if (externalId != null) existing[externalId] = doc.id;
      }

      for (var news in HardcodedNewsData.getAllNews()) {
        final externalId = news.id;
        final payload = {
          ...news.toMap(),
          'externalId': externalId,
        };

        if (existing.containsKey(externalId)) {
          final firestoreId = existing[externalId]!;
          final needsUpdate = await _needsUpdate('news', firestoreId, payload);
          if (needsUpdate) {
            await _db.collection('news').doc(firestoreId).update({
              ...payload,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            result.updated++;
            print('   📝 Updated news: ${news.title}');
          } else {
            result.unchanged++;
          }
        } else {
          await _db.collection('news').add({
            ...payload,
            'createdAt': FieldValue.serverTimestamp(),
          });
          result.inserted++;
          print('   ➕ Inserted news: ${news.title}');
        }
      }
    } catch (e) {
      print('❌ Lỗi sync news: $e');
      result.error = e.toString();
    }

    return result;
  }
  
  /// ✅ Sync theaters
  Future<SyncResult> syncTheaters() async {
    final result = SyncResult(collectionName: 'theaters');
    
    try {
      final snapshot = await _db.collection('theaters').get();
      final existingTheaters = <String, String>{}; // externalId → firestoreId
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final externalId = data['externalId'] as String?;
        if (externalId != null) {
          existingTheaters[externalId] = doc.id;
        }
      }
      
      for (var theaterData in HardcodedTheatersData.allTheaters) {
        final externalId = theaterData['externalId'] as String;
        
        if (existingTheaters.containsKey(externalId)) {
          final firestoreId = existingTheaters[externalId]!;
          
          // Luôn keep screens hiện tại (để không ảnh hưởng relation)
          final currentDoc = await _db.collection('theaters').doc(firestoreId).get();
          final currentScreens = currentDoc.data()?['screens'] ?? [];
          
          final needsUpdate = await _needsUpdate(
            'theaters',
            firestoreId,
            theaterData,
            excludeFields: ['screens'], // Không so sánh screens
          );
          
          if (needsUpdate) {
            await _db.collection('theaters').doc(firestoreId).update({
              'name': theaterData['name'],
              'address': theaterData['address'],
              'city': theaterData['city'],
              'phone': theaterData['phone'],
              'screens': currentScreens, // Giữ nguyên
              'updatedAt': FieldValue.serverTimestamp(),
            });
            result.updated++;
            print('   📝 Updated: ${theaterData['name']}');
          } else {
            result.unchanged++;
          }
        } else {
          await _db.collection('theaters').add({
            'name': theaterData['name'],
            'address': theaterData['address'],
            'city': theaterData['city'],
            'phone': theaterData['phone'],
            'screens': [],
            'externalId': externalId,
            'createdAt': FieldValue.serverTimestamp(),
          });
          result.inserted++;
          print('   ➕ Inserted: ${theaterData['name']}');
        }
      }
      
    } catch (e) {
      print('❌ Lỗi sync theaters: $e');
      result.error = e.toString();
    }
    
    return result;
  }
  
  /// ✅ Sync screens
  Future<SyncResult> syncScreens() async {
    final result = SyncResult(collectionName: 'screens');
    
    try {
      // Get theater mapping
      final theaterSnapshot = await _db.collection('theaters').get();
      final theaterMap = <String, String>{}; // externalId → firestoreId
      
      for (var doc in theaterSnapshot.docs) {
        final externalId = doc.data()['externalId'] as String?;
        if (externalId != null) {
          theaterMap[externalId] = doc.id;
        }
      }
      
      // Get existing screens
      final screenSnapshot = await _db.collection('screens').get();
      final existingScreens = <String, String>{}; // externalId → firestoreId
      final theaterScreens = <String, List<String>>{}; // theaterId → [screenIds]
      
      for (var doc in screenSnapshot.docs) {
        final data = doc.data();
        final externalId = data['externalId'] as String?;
        if (externalId != null) {
          existingScreens[externalId] = doc.id;
        }
        
        final theaterId = data['theaterId'] as String?;
        if (theaterId != null) {
          theaterScreens.putIfAbsent(theaterId, () => []);
          theaterScreens[theaterId]!.add(doc.id);
        }
      }
      
      // Sync screens
      for (var screenData in HardcodedScreensData.allScreens) {
        final screenExternalId = screenData['externalId'] as String;
        final theaterExternalId = screenData['theaterExternalId'] as String;
        final theaterFirestoreId = theaterMap[theaterExternalId];
        
        if (theaterFirestoreId == null) {
          print('   ⚠️ Theater không tồn tại: $theaterExternalId');
          continue;
        }
        
        if (existingScreens.containsKey(screenExternalId)) {
          final firestoreId = existingScreens[screenExternalId]!;
          final needsUpdate = await _needsUpdate(
            'screens',
            firestoreId,
            screenData,
            excludeFields: ['theaterExternalId'], // Field này không có trong Firestore
          );
          
          if (needsUpdate) {
            await _db.collection('screens').doc(firestoreId).update({
              'name': screenData['name'],
              'totalSeats': screenData['totalSeats'],
              'rows': screenData['rows'],
              'columns': screenData['columns'],
              'seats': screenData['seats'],
              'updatedAt': FieldValue.serverTimestamp(),
            });
            result.updated++;
          } else {
            result.unchanged++;
          }
        } else {
          // Insert new screen
          final docRef = await _db.collection('screens').add({
            'theaterId': theaterFirestoreId,
            'name': screenData['name'],
            'totalSeats': screenData['totalSeats'],
            'rows': screenData['rows'],
            'columns': screenData['columns'],
            'seats': screenData['seats'],
            'externalId': screenExternalId,
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          theaterScreens.putIfAbsent(theaterFirestoreId, () => []);
          theaterScreens[theaterFirestoreId]!.add(docRef.id);
          
          result.inserted++;
          print('   ➕ Inserted: ${screenData['name']}');
        }
      }
      
      // Update theater.screens arrays
      for (var entry in theaterScreens.entries) {
        await _db.collection('theaters').doc(entry.key).update({
          'screens': entry.value,
        });
      }
      
    } catch (e) {
      print('❌ Lỗi sync screens: $e');
      result.error = e.toString();
    }
    
    return result;
  }
  
  /// ✅ Sync showtimes - CHÍNH SÁCH ĐẶC BIỆT
  /// 
  /// Showtimes cũ (đã qua) → KHÔNG XÓA (để giữ booking history)
  /// Showtimes tương lai → Sync theo externalId pattern
  Future<SyncResult> syncShowtimes() async {
    final result = SyncResult(collectionName: 'showtimes');
    
    try {
      // Get mappings
      final movieMap = await _getExternalIdMap('movies');
      final theaterMap = await _getExternalIdMap('theaters');
      final screenMap = await _getExternalIdMap('screens');
      
      // Get existing future showtimes
      final now = Timestamp.now();
      final snapshot = await _db
          .collection('showtimes')
          .where('startTime', isGreaterThan: now)
          .get();
      
      // Track existing by composite key: screenId-date-time
      final existingShowtimes = <String, String>{}; // key → firestoreId
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final screenId = data['screenId'] as String?;
        final startTime = (data['startTime'] as Timestamp?)?.toDate();
        
        if (screenId != null && startTime != null) {
          final key = _buildShowtimeKey(screenId, startTime);
          existingShowtimes[key] = doc.id;
        }
      }
      
      // Prepare all showtime templates
      final allShowtimes = [
        ...HardcodedShowtimesData.allHanoiShowtimes,
        ...HardcodedShowtimesHCMData.allHCMShowtimes,
        ...HardcodedShowtimesDanangData.allDaNangShowtimes,
      ];
      
      // Sync for 7 days
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
        onProgress?.call(0.75 + (i / dates.length) * 0.25, 'Sync showtimes $dateStr');
        
        for (var showtimeData in allShowtimes) {
          final movieExternalId = showtimeData['movieExternalId'] as String;
          final theaterExternalId = showtimeData['theaterExternalId'] as String;
          final screenExternalId = showtimeData['screenExternalId'] as String;
          final time = showtimeData['time'] as String;
          
          final movieId = movieMap[movieExternalId];
          final theaterId = theaterMap[theaterExternalId];
          final screenId = screenMap[screenExternalId];
          
          if (movieId == null || theaterId == null || screenId == null) {
            continue;
          }
          
          final startTime = DateTime.parse('$dateStr $time:00');
          final endTime = startTime.add(Duration(minutes: 120));
          final key = _buildShowtimeKey(screenId, startTime);
          
          if (existingShowtimes.containsKey(key)) {
            // Đã tồn tại → update prices nếu cần
            final firestoreId = existingShowtimes[key]!;
            await _db.collection('showtimes').doc(firestoreId).update({
              'basePrice': showtimeData['basePrice'],
              'vipPrice': showtimeData['vipPrice'],
              'updatedAt': FieldValue.serverTimestamp(),
            });
            result.updated++;
          } else {
            // Insert new
            await _db.collection('showtimes').add({
              'movieId': movieId,
              'theaterId': theaterId,
              'screenId': screenId,
              'startTime': Timestamp.fromDate(startTime),
              'endTime': Timestamp.fromDate(endTime),
              'basePrice': showtimeData['basePrice'],
              'vipPrice': showtimeData['vipPrice'],
              'availableSeats': 80,
              'bookedSeats': [],
              'status': 'active',
              'createdAt': FieldValue.serverTimestamp(),
            });
            result.inserted++;
          }
        }
      }
      
    } catch (e) {
      print('❌ Lỗi sync showtimes: $e');
      result.error = e.toString();
    }
    
    return result;
  }
  
  /// Helper: Kiểm tra document cần update không
  Future<bool> _needsUpdate(
    String collection,
    String docId,
    Map<String, dynamic> newData, {
    List<String>? excludeFields,
  }) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();
      if (!doc.exists) return true;
      
      final currentData = doc.data()!;
      
      for (var entry in newData.entries) {
        final key = entry.key;
        final newValue = entry.value;
        
        // Skip excluded fields
        if (excludeFields != null && excludeFields.contains(key)) {
          continue;
        }
        
        // Skip metadata fields
        if (key == 'createdAt' || key == 'updatedAt') {
          continue;
        }
        
        final currentValue = currentData[key];
        
        // So sánh value
        if (_isDifferent(currentValue, newValue)) {
          return true;
        }
      }
      
      return false;
      
    } catch (e) {
      return true; // Nếu lỗi thì cứ update
    }
  }
  
  /// So sánh 2 giá trị có khác nhau không
  bool _isDifferent(dynamic a, dynamic b) {
    if (a == null && b == null) return false;
    if (a == null || b == null) return true;
    
    // So sánh List
    if (a is List && b is List) {
      if (a.length != b.length) return true;
      for (var i = 0; i < a.length; i++) {
        if (_isDifferent(a[i], b[i])) return true;
      }
      return false;
    }
    
    // So sánh Map
    if (a is Map && b is Map) {
      final keysA = a.keys.toSet();
      final keysB = b.keys.toSet();
      if (keysA.length != keysB.length) return true;
      
      for (var key in keysA) {
        if (!keysB.contains(key)) return true;
        if (_isDifferent(a[key], b[key])) return true;
      }
      return false;
    }
    
    // So sánh primitive
    return a != b;
  }
  
  /// Lấy mapping externalId → firestoreId
  Future<Map<String, String>> _getExternalIdMap(String collection) async {
    final snapshot = await _db.collection(collection).get();
    final map = <String, String>{};
    
    for (var doc in snapshot.docs) {
      final externalId = doc.data()['externalId'] as String?;
      if (externalId != null) {
        map[externalId] = doc.id;
      }
    }
    
    return map;
  }
  
  /// Build unique key cho showtime
  String _buildShowtimeKey(String screenId, DateTime startTime) {
    final date = '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}';
    final time = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    return '$screenId-$date-$time';
  }
}

/// ========================================
/// MODELS
/// ========================================

class SyncReport {
  SyncResult? movies;
  SyncResult? theaters;
  SyncResult? screens;
  SyncResult? showtimes;
  SyncResult? news;
  
  void printSummary() {
    print('='*60);
    print('📊 TỔNG KẾT SYNC');
    print('='*60);
    print('🎬 Movies:    ${movies?.summary ?? "Chưa sync"}');
    print('🏢 Theaters:  ${theaters?.summary ?? "Chưa sync"}');
    print('🪑 Screens:   ${screens?.summary ?? "Chưa sync"}');
    print('⏰ Showtimes: ${showtimes?.summary ?? "Chưa sync"}');
    print('📰 News:      ${news?.summary ?? "Chưa sync"}');
    print('='*60);
  }
}

class SyncResult {
  final String collectionName;
  int inserted = 0;
  int updated = 0;
  int unchanged = 0;
  String? error;
  
  SyncResult({required this.collectionName});
  
  int get total => inserted + updated + unchanged;
  
  String get summary {
    if (error != null) {
      return 'Lỗi: $error';
    }
    return '$total total (➕ $inserted new, 📝 $updated updated, ✓ $unchanged unchanged)';
  }
}
