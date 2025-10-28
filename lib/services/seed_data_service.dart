// lib/services/seed_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'seed/seed_movies_service.dart';
import 'seed/seed_theaters_service.dart';
import 'seed/seed_screens_service.dart';
import 'seed/seed_showtimes_service.dart';

/// Service để thêm dữ liệu mẫu vào Firestore
/// Sử dụng một lần để khởi tạo database
/// Đã được chia nhỏ thành các service riêng biệt để dễ quản lý
class SeedDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Các service con
  final _moviesService = SeedMoviesService();
  final _theatersService = SeedTheatersService();
  final _screensService = SeedScreensService();
  final _showtimesService = SeedShowtimesService();

  /// 🎬 Thêm dữ liệu mẫu cho Movies
  Future<List<String>> seedMovies() async {
    return await _moviesService.seedMovies();
  }

  /// 🏢 Thêm dữ liệu mẫu cho Theaters
  Future<List<String>> seedTheaters() async {
    return await _theatersService.seedTheaters();
  }

  /// 🪑 Thêm dữ liệu mẫu cho Screens
  Future<List<String>> seedScreens(List<String> theaterIds) async {
    return await _screensService.seedScreens(theaterIds);
  }

  /// ⏰ Thêm dữ liệu mẫu cho Showtimes
  Future<void> seedShowtimes(
    List<String> movieIds, 
    List<String> theaterIds, 
    List<String> screenIds
  ) async {
    await _showtimesService.seedShowtimes(movieIds, theaterIds, screenIds);
  }

  /// 🚀 Thêm tất cả dữ liệu mẫu
  Future<void> seedAllData() async {
    try {
      print('\n🚀 BẮT ĐẦU SEED DỮ LIỆU...\n');
      print('⏳ Quá trình này có thể mất vài phút...\n');

      // 1. Thêm movies
      final movieIds = await seedMovies();
      await Future.delayed(Duration(seconds: 1));

      // 2. Thêm theaters
      final theaterIds = await seedTheaters();
      await Future.delayed(Duration(seconds: 1));

      // 3. Thêm screens
      final screenIds = await seedScreens(theaterIds);
      await Future.delayed(Duration(seconds: 1));

      // 4. Thêm showtimes
      await seedShowtimes(movieIds, theaterIds, screenIds);

      print('\n✅ HOÀN THÀNH SEED DỮ LIỆU!');
      print('📊 Tổng kết:');
      print('   - ${movieIds.length} phim');
      print('   - ${theaterIds.length} rạp');
      print('   - ${screenIds.length} phòng chiếu');
      print('   - Nhiều lịch chiếu trong 7 ngày tới');
      print('\n🎉 Bạn có thể vào Firebase Console để kiểm tra!\n');
      
    } catch (e) {
      print('❌ Lỗi khi seed dữ liệu: $e');
      rethrow;
    }
  }

  /// 🗑️ Xóa tất cả dữ liệu (dùng để reset)
  Future<void> clearAllData() async {
    print('🗑️ Đang xóa tất cả dữ liệu...');
    
    final collections = ['bookings', 'payments', 'showtimes', 'screens', 'theaters', 'movies'];
    
    for (var collectionName in collections) {
      try {
        await _deleteCollection(collectionName);
        print('✅ Đã xóa collection: $collectionName');
      } catch (e) {
        print('❌ Lỗi khi xóa $collectionName: $e');
        rethrow;
      }
    }
    
    print('🎉 Hoàn thành xóa dữ liệu!\n');
  }

  /// 🗑️ Xóa một collection cụ thể (với batch delete để tránh timeout)
  Future<void> _deleteCollection(String collectionName) async {
    final collection = _db.collection(collectionName);
    const batchSize = 500;
    
    while (true) {
      final snapshot = await collection.limit(batchSize).get();
      
      if (snapshot.docs.isEmpty) {
        break;
      }
      
      // Sử dụng batch để xóa nhanh hơn
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('  ↳ Đã xóa ${snapshot.docs.length} documents từ $collectionName');
      
      // Nếu số lượng < batchSize => đã xóa hết
      if (snapshot.docs.length < batchSize) {
        break;
      }
    }
  }

  /// 🗑️ Xóa một collection cụ thể (public method - có thể gọi từ UI)
  Future<void> clearCollection(String collectionName) async {
    print('🗑️ Đang xóa collection: $collectionName...');
    await _deleteCollection(collectionName);
    print('✅ Đã xóa collection: $collectionName\n');
  }

  /// 📝 Thêm một movie đơn lẻ
  Future<String> addSingleMovie(Map<String, dynamic> movieData) async {
    return await _moviesService.addSingleMovie(movieData);
  }

  /// 📝 Thêm một theater đơn lẻ
  Future<String> addSingleTheater(Map<String, dynamic> theaterData) async {
    return await _theatersService.addSingleTheater(theaterData);
  }
}
