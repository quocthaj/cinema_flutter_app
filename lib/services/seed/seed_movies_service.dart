// lib/services/seed/seed_movies_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'movie_seed_data.dart';
import 'sync_result.dart';

/// Service để seed Movies với khả năng sync (Update/Add/Delete)
class SeedMoviesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔄 Sync dữ liệu Movies (Update/Add/Delete)
  /// 
  /// - Update: Cập nhật các bản ghi đã có nếu có thay đổi
  /// - Add: Thêm mới các bản ghi còn thiếu
  /// - Delete: Xóa các bản ghi không còn trong seed data
  /// 
  /// [dryRun] = true: Chỉ kiểm tra, không thực hiện thay đổi
  Future<SyncResult> syncMovies({bool dryRun = false}) async {
    print('🔄 Bắt đầu sync Movies...');
    if (dryRun) {
      print('   [DRY RUN MODE - Không thực hiện thay đổi]');
    }

    int added = 0, updated = 0, deleted = 0, unchanged = 0;
    List<String> errors = [];
    List<String> addedIds = [], updatedIds = [], deletedIds = [];

    try {
      final seedMovies = MovieSeedData.movies;
      
      // Lấy tất cả movies hiện có từ Firestore
      final existingSnapshot = await _db.collection('movies').get();
      final existingMoviesMap = <String, QueryDocumentSnapshot>{};
      
      for (var doc in existingSnapshot.docs) {
        final externalId = doc.data()['externalId'] as String?;
        if (externalId != null) {
          existingMoviesMap[externalId] = doc;
        }
      }

      // Batch để xử lý operations
      WriteBatch? batch = dryRun ? null : _db.batch();
      int batchCount = 0;
      const batchLimit = 500;

      // SET 1: Update và Add
      for (var seedMovie in seedMovies) {
        final externalId = seedMovie['externalId'] as String?;
        
        if (externalId == null) {
          errors.add('Movie thiếu externalId: ${seedMovie['title']}');
          continue;
        }

        final existingDoc = existingMoviesMap[externalId];

        if (existingDoc == null) {
          // ADD: Thêm mới
          if (!dryRun) {
            final docRef = _db.collection('movies').doc(externalId);
            batch!.set(docRef, seedMovie);
            batchCount++;
            addedIds.add(externalId);
          }
          added++;
          print('  ➕ [ADD] ${seedMovie['title']}');
        } else {
          // So sánh để quyết định UPDATE hay UNCHANGED
          final existingData = existingDoc.data() as Map<String, dynamic>;
          
          if (_hasChanges(existingData, seedMovie)) {
            // UPDATE: Có thay đổi
            if (!dryRun) {
              batch!.update(existingDoc.reference, seedMovie);
              batchCount++;
              updatedIds.add(externalId);
            }
            updated++;
            print('  🔄 [UPDATE] ${seedMovie['title']}');
          } else {
            // UNCHANGED: Không đổi
            unchanged++;
          }
          
          // Đánh dấu đã xử lý
          existingMoviesMap.remove(externalId);
        }

        // Commit batch nếu đạt giới hạn
        if (!dryRun && batchCount >= batchLimit) {
          await batch!.commit();
          batch = _db.batch();
          batchCount = 0;
        }
      }

      // SET 2: Delete (các movie không còn trong seed)
      for (var remainingDoc in existingMoviesMap.values) {
        final data = remainingDoc.data() as Map<String, dynamic>?;
        final externalId = data?['externalId'] as String?;
        final title = data?['title'] ?? 'Unknown';
        
        if (!dryRun) {
          batch!.delete(remainingDoc.reference);
          batchCount++;
          if (externalId != null) deletedIds.add(externalId);
        }
        deleted++;
        print('  🗑️  [DELETE] $title');
      }

      // Commit batch cuối cùng
      if (!dryRun && batchCount > 0) {
        await batch!.commit();
      }

      final result = SyncResult(
        added: added,
        updated: updated,
        deleted: deleted,
        unchanged: unchanged,
        errors: errors,
        addedIds: addedIds,
        updatedIds: updatedIds,
        deletedIds: deletedIds,
      );

      print('\n${result.toString()}');
      
      if (dryRun) {
        print('💡 Chạy lại với dryRun=false để áp dụng thay đổi.\n');
      } else {
        print('✅ Hoàn thành sync Movies!\n');
      }

      return result;
      
    } catch (e) {
      print('❌ Lỗi khi sync movies: $e');
      errors.add('Exception: $e');
      return SyncResult(
        added: added,
        updated: updated,
        deleted: deleted,
        unchanged: unchanged,
        errors: errors,
      );
    }
  }

  /// So sánh sâu 2 map để phát hiện thay đổi
  /// Bỏ qua các metadata fields (createdAt, updatedAt, etc.)
  bool _hasChanges(Map<String, dynamic> existing, Map<String, dynamic> seed) {
    // Danh sách các field cần so sánh
    const fieldsToCompare = [
      'externalId', 'title', 'genre', 'duration', 'rating', 'status',
      'releaseDate', 'description', 'posterUrl', 'trailerUrl',
      'director', 'cast', 'language', 'ageRating'
    ];

    for (var field in fieldsToCompare) {
      final existingValue = existing[field];
      final seedValue = seed[field];
      
      // So sánh với deep equality
      if (!DeepCollectionEquality().equals(existingValue, seedValue)) {
        return true;
      }
    }

    return false;
  }

  /// 🎬 [LEGACY] Thêm dữ liệu mẫu cho Movies (giữ lại để backward compatible)
  Future<List<String>> seedMovies() async {
    print('🎬 Bắt đầu thêm Movies (Legacy mode - chỉ ADD)...');
    
    final movies = MovieSeedData.movies;
    List<String> movieIds = [];
    
    try {
      for (var movieData in movies) {
        final externalId = movieData['externalId'] as String?;
        if (externalId == null) continue;
        
        final docRef = _db.collection('movies').doc(externalId);
        await docRef.set(movieData);
        movieIds.add(externalId);
        print('✅ Đã thêm phim: ${movieData['title']}');
        
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
      final externalId = movieData['externalId'] as String?;
      if (externalId == null) {
        throw Exception('Movie phải có externalId');
      }
      
      final docRef = _db.collection('movies').doc(externalId);
      await docRef.set(movieData);
      print('✅ Đã thêm phim: ${movieData['title']}');
      return externalId;
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
