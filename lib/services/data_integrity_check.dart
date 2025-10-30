// lib/services/data_integrity_check.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Service kiểm tra tính toàn vẹn dữ liệu
/// 
/// Sử dụng để phát hiện các lỗi:
/// - Theater-Screen mapping không khớp
/// - Dữ liệu orphan (không có reference)
/// - Ràng buộc khóa ngoại bị vi phạm
class DataIntegrityCheck {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔍 Kiểm tra toàn bộ dữ liệu
  Future<IntegrityReport> checkAll() async {
    print('🔍 BẮT ĐẦU KIỂM TRA TÍNH TOÀN VẸN DỮ LIỆU...\n');
    
    final report = IntegrityReport();
    
    // 1. Kiểm tra theater-screen mapping
    await _checkTheaterScreenMapping(report);
    
    // 2. Kiểm tra showtimes
    await _checkShowtimes(report);
    
    // 3. Kiểm tra bookings
    await _checkBookings(report);
    
    // Tổng kết
    report.printSummary();
    
    return report;
  }

  /// Kiểm tra: Mỗi screen phải thuộc đúng 1 theater
  Future<void> _checkTheaterScreenMapping(IntegrityReport report) async {
    print('📊 1. Kiểm tra Theater-Screen Mapping...');
    
    try {
      // Lấy tất cả theaters
      final theatersSnapshot = await _db.collection('theaters').get();
      final theaterIds = theatersSnapshot.docs.map((doc) => doc.id).toSet();
      
      // Lấy tất cả screens
      final screensSnapshot = await _db.collection('screens').get();
      
      for (var screenDoc in screensSnapshot.docs) {
        final screenData = screenDoc.data();
        final theaterId = screenData['theaterId'] as String?;
        
        if (theaterId == null) {
          report.addError(
            'Screen ${screenDoc.id} không có theaterId',
            'screens/${screenDoc.id}',
          );
        } else if (!theaterIds.contains(theaterId)) {
          report.addError(
            'Screen ${screenDoc.id} tham chiếu đến theater không tồn tại: $theaterId',
            'screens/${screenDoc.id}',
          );
        }
      }
      
      print('   ✅ Đã kiểm tra ${screensSnapshot.docs.length} screens');
      
    } catch (e) {
      report.addError('Lỗi khi kiểm tra theater-screen: $e', 'system');
    }
  }

  /// Kiểm tra: Showtimes phải có theater-screen khớp
  Future<void> _checkShowtimes(IntegrityReport report) async {
    print('📊 2. Kiểm tra Showtimes...');
    
    try {
      // Build theater-screen map
      final Map<String, List<String>> theaterScreensMap = {};
      final Map<String, String> screenTheaterMap = {}; // screenId → theaterId
      
      final screensSnapshot = await _db.collection('screens').get();
      for (var screenDoc in screensSnapshot.docs) {
        final screenData = screenDoc.data();
        final theaterId = screenData['theaterId'] as String?;
        
        if (theaterId != null) {
          screenTheaterMap[screenDoc.id] = theaterId;
          theaterScreensMap[theaterId] ??= [];
          theaterScreensMap[theaterId]!.add(screenDoc.id);
        }
      }
      
      // Kiểm tra tất cả showtimes
      final showtimesSnapshot = await _db.collection('showtimes').get();
      
      int checkedCount = 0;
      for (var showtimeDoc in showtimesSnapshot.docs) {
        final showtimeData = showtimeDoc.data();
        final theaterId = showtimeData['theaterId'] as String?;
        final screenId = showtimeData['screenId'] as String?;
        final movieId = showtimeData['movieId'] as String?;
        
        // Check 1: Thiếu trường bắt buộc
        if (theaterId == null) {
          report.addError(
            'Showtime ${showtimeDoc.id} không có theaterId',
            'showtimes/${showtimeDoc.id}',
          );
          continue;
        }
        
        if (screenId == null) {
          report.addError(
            'Showtime ${showtimeDoc.id} không có screenId',
            'showtimes/${showtimeDoc.id}',
          );
          continue;
        }
        
        if (movieId == null) {
          report.addError(
            'Showtime ${showtimeDoc.id} không có movieId',
            'showtimes/${showtimeDoc.id}',
          );
          continue;
        }
        
        // Check 2: Screen có tồn tại không?
        if (!screenTheaterMap.containsKey(screenId)) {
          report.addError(
            'Showtime ${showtimeDoc.id} tham chiếu đến screen không tồn tại: $screenId',
            'showtimes/${showtimeDoc.id}',
          );
          continue;
        }
        
        // Check 3: Theater-Screen mapping có khớp không?
        final actualTheaterId = screenTheaterMap[screenId];
        if (actualTheaterId != theaterId) {
          report.addError(
            'Showtime ${showtimeDoc.id}: Theater-Screen KHÔNG KHỚP! '
            'theaterId=$theaterId nhưng screen $screenId thuộc theater $actualTheaterId',
            'showtimes/${showtimeDoc.id}',
          );
        }
        
        checkedCount++;
      }
      
      print('   ✅ Đã kiểm tra $checkedCount showtimes');
      
    } catch (e) {
      report.addError('Lỗi khi kiểm tra showtimes: $e', 'system');
    }
  }

  /// Kiểm tra: Bookings phải tham chiếu đúng showtime
  Future<void> _checkBookings(IntegrityReport report) async {
    print('📊 3. Kiểm tra Bookings...');
    
    try {
      // Lấy tất cả showtimeIds
      final showtimesSnapshot = await _db.collection('showtimes').get();
      final showtimeIds = showtimesSnapshot.docs.map((doc) => doc.id).toSet();
      
      // Kiểm tra bookings
      final bookingsSnapshot = await _db.collection('bookings').get();
      
      for (var bookingDoc in bookingsSnapshot.docs) {
        final bookingData = bookingDoc.data();
        final showtimeId = bookingData['showtimeId'] as String?;
        
        if (showtimeId == null) {
          report.addError(
            'Booking ${bookingDoc.id} không có showtimeId',
            'bookings/${bookingDoc.id}',
          );
        } else if (!showtimeIds.contains(showtimeId)) {
          report.addError(
            'Booking ${bookingDoc.id} tham chiếu đến showtime không tồn tại: $showtimeId',
            'bookings/${bookingDoc.id}',
          );
        }
      }
      
      print('   ✅ Đã kiểm tra ${bookingsSnapshot.docs.length} bookings');
      
    } catch (e) {
      report.addError('Lỗi khi kiểm tra bookings: $e', 'system');
    }
  }

  /// 🔍 Kiểm tra nhanh một showtime cụ thể
  Future<void> checkShowtime(String showtimeId) async {
    print('🔍 Kiểm tra showtime: $showtimeId\n');
    
    try {
      final showtimeDoc = await _db.collection('showtimes').doc(showtimeId).get();
      
      if (!showtimeDoc.exists) {
        print('❌ Showtime không tồn tại!');
        return;
      }
      
      final showtimeData = showtimeDoc.data()!;
      final theaterId = showtimeData['theaterId'] as String?;
      final screenId = showtimeData['screenId'] as String?;
      final movieId = showtimeData['movieId'] as String?;
      
      print('📄 Thông tin showtime:');
      print('   Theater ID: $theaterId');
      print('   Screen ID: $screenId');
      print('   Movie ID: $movieId');
      
      // Kiểm tra theater
      if (theaterId != null) {
        final theaterDoc = await _db.collection('theaters').doc(theaterId).get();
        if (theaterDoc.exists) {
          print('   ✅ Theater: ${theaterDoc.data()?['name']}');
        } else {
          print('   ❌ Theater không tồn tại!');
        }
      }
      
      // Kiểm tra screen
      if (screenId != null) {
        final screenDoc = await _db.collection('screens').doc(screenId).get();
        if (screenDoc.exists) {
          final screenData = screenDoc.data()!;
          final screenTheaterId = screenData['theaterId'];
          print('   Screen: ${screenData['name']}');
          print('   Screen thuộc theater: $screenTheaterId');
          
          if (screenTheaterId == theaterId) {
            print('   ✅ Theater-Screen mapping ĐÚNG!');
          } else {
            print('   ❌ Theater-Screen mapping SAI! Showtime có theater=$theaterId nhưng screen thuộc theater=$screenTheaterId');
          }
        } else {
          print('   ❌ Screen không tồn tại!');
        }
      }
      
      // Kiểm tra movie
      if (movieId != null) {
        final movieDoc = await _db.collection('movies').doc(movieId).get();
        if (movieDoc.exists) {
          print('   ✅ Movie: ${movieDoc.data()?['title']}');
        } else {
          print('   ❌ Movie không tồn tại!');
        }
      }
      
    } catch (e) {
      print('❌ Lỗi: $e');
    }
  }

  /// 🔍 Tìm tất cả showtimes bị lỗi theater-screen mapping
  Future<List<String>> findBrokenShowtimes() async {
    print('🔍 Tìm tất cả showtimes bị lỗi...\n');
    
    final brokenShowtimeIds = <String>[];
    
    try {
      // Build screen-theater map
      final Map<String, String> screenTheaterMap = {}; // screenId → theaterId
      final screensSnapshot = await _db.collection('screens').get();
      
      for (var screenDoc in screensSnapshot.docs) {
        final screenData = screenDoc.data();
        final theaterId = screenData['theaterId'] as String?;
        if (theaterId != null) {
          screenTheaterMap[screenDoc.id] = theaterId;
        }
      }
      
      // Kiểm tra tất cả showtimes
      final showtimesSnapshot = await _db.collection('showtimes').get();
      
      print('Đang kiểm tra ${showtimesSnapshot.docs.length} showtimes...');
      
      for (var showtimeDoc in showtimesSnapshot.docs) {
        final showtimeData = showtimeDoc.data();
        final theaterId = showtimeData['theaterId'] as String?;
        final screenId = showtimeData['screenId'] as String?;
        
        if (theaterId == null || screenId == null) {
          brokenShowtimeIds.add(showtimeDoc.id);
          continue;
        }
        
        final actualTheaterId = screenTheaterMap[screenId];
        if (actualTheaterId != theaterId) {
          brokenShowtimeIds.add(showtimeDoc.id);
          
          // In ra 10 lỗi đầu tiên để debug
          if (brokenShowtimeIds.length <= 10) {
            print('❌ Lỗi #${brokenShowtimeIds.length}: ${showtimeDoc.id}');
            print('   Showtime.theaterId = $theaterId');
            print('   Screen.theaterId = $actualTheaterId');
          }
        }
      }
      
      print('\n📊 Kết quả:');
      print('   Tổng số showtimes: ${showtimesSnapshot.docs.length}');
      print('   Số showtimes bị lỗi: ${brokenShowtimeIds.length}');
      print('   Tỷ lệ lỗi: ${(brokenShowtimeIds.length * 100 / showtimesSnapshot.docs.length).toStringAsFixed(1)}%');
      
      if (brokenShowtimeIds.isEmpty) {
        print('   ✅ Không có lỗi!');
      } else {
        print('   ❌ CẦN FIX: Chạy lại seed để sửa!');
      }
      
    } catch (e) {
      print('❌ Lỗi: $e');
    }
    
    return brokenShowtimeIds;
  }
}

/// Report kết quả kiểm tra
class IntegrityReport {
  final List<IntegrityError> errors = [];
  
  void addError(String message, String path) {
    errors.add(IntegrityError(message, path));
  }
  
  bool get hasErrors => errors.isNotEmpty;
  
  void printSummary() {
    print('\n${'='*60}');
    print('📊 KẾT QUẢ KIỂM TRA TÍNH TOÀN VẸN DỮ LIỆU');
    print('='*60);
    
    if (hasErrors) {
      print('❌ Tìm thấy ${errors.length} lỗi:\n');
      
      // Group errors by type
      final errorsByPath = <String, List<IntegrityError>>{};
      for (var error in errors) {
        final pathPrefix = error.path.split('/').first;
        errorsByPath[pathPrefix] ??= [];
        errorsByPath[pathPrefix]!.add(error);
      }
      
      errorsByPath.forEach((pathPrefix, pathErrors) {
        print('📁 $pathPrefix: ${pathErrors.length} lỗi');
        for (var error in pathErrors.take(5)) {
          print('   ❌ ${error.message}');
        }
        if (pathErrors.length > 5) {
          print('   ... và ${pathErrors.length - 5} lỗi khác');
        }
        print('');
      });
      
      print('❌ CẦN HÀNH ĐỘNG: Chạy lại seed để fix dữ liệu!');
    } else {
      print('✅✅✅ HOÀN HẢO! Không có lỗi nào ✅✅✅');
      print('✅ Tất cả dữ liệu đều nhất quán và toàn vẹn');
    }
    
    print('='*60 + '\n');
  }
}

/// Một lỗi toàn vẹn dữ liệu
class IntegrityError {
  final String message;
  final String path;
  
  IntegrityError(this.message, this.path);
  
  @override
  String toString() => '$path: $message';
}
