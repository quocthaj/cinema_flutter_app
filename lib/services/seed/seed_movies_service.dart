// lib/services/seed/seed_movies_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'movie_seed_data.dart';

/// Service để seed Movies
class SeedMoviesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🎬 Thêm dữ liệu mẫu cho Movies
  Future<List<String>> seedMovies() async {
    print('🎬 Bắt đầu thêm Movies...');
    
    final movies = MovieSeedData.movies;
    List<String> movieIds = [];
    
    try {
      for (var movieData in movies) {
        final docRef = await _db.collection('movies').add(movieData);
        movieIds.add(docRef.id);
        print('✅ Đã thêm phim: ${movieData['title']}');
        
        // Thêm delay nhỏ để tránh quá tải
        await Future.delayed(Duration(milliseconds: 100));
      }

      print('🎉 Hoàn thành thêm ${movieIds.length} phim!\n');
      return movieIds;
    } catch (e) {
      print('❌ Lỗi khi seed movies: $e');
      rethrow;
    }
  }

  /// 📝 Thêm một movie đơn lẻ
  Future<String> addSingleMovie(Map<String, dynamic> movieData) async {
    try {
      final docRef = await _db.collection('movies').add(movieData);
      print('✅ Đã thêm phim: ${movieData['title']}');
      return docRef.id;
    } catch (e) {
      print('❌ Lỗi khi thêm phim: $e');
      rethrow;
    }
  }

  /// 🗑️ Xóa tất cả movies
  Future<void> clearMovies() async {
    print('🗑️ Đang xóa tất cả movies...');
    
    try {
      await _deleteCollection('movies');
      print('✅ Đã xóa tất cả movies\n');
    } catch (e) {
      print('❌ Lỗi khi xóa movies: $e');
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
