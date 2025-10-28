// lib/services/seed/seed_theaters_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'theater_seed_data.dart';
import 'sync_result.dart';

/// Service để seed Theaters với khả năng sync (Update/Add/Delete)
class SeedTheatersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔄 Sync dữ liệu Theaters (Update/Add/Delete)
  /// 
  /// - Update: Cập nhật các bản ghi đã có nếu có thay đổi
  /// - Add: Thêm mới các bản ghi còn thiếu
  /// - Delete: Xóa các bản ghi không còn trong seed data
  /// 
  /// [dryRun] = true: Chỉ kiểm tra, không thực hiện thay đổi
  Future<SyncResult> syncTheaters({bool dryRun = false}) async {
    print('🔄 Bắt đầu sync Theaters...');
    if (dryRun) {
      print('   [DRY RUN MODE - Không thực hiện thay đổi]');
    }

    int added = 0, updated = 0, deleted = 0, unchanged = 0;
    List<String> errors = [];
    List<String> addedIds = [], updatedIds = [], deletedIds = [];

    try {
      final seedTheaters = TheaterSeedData.theaters;
      
      // Lấy tất cả theaters hiện có từ Firestore
      final existingSnapshot = await _db.collection('theaters').get();
      final existingTheatersMap = <String, QueryDocumentSnapshot>{};
      
      for (var doc in existingSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final externalId = data?['externalId'] as String?;
        if (externalId != null) {
          existingTheatersMap[externalId] = doc;
        }
      }

      // Batch để xử lý operations
      WriteBatch? batch = dryRun ? null : _db.batch();
      int batchCount = 0;
      const batchLimit = 500;

      // SET 1: Update và Add
      for (var seedTheater in seedTheaters) {
        final externalId = seedTheater['externalId'] as String?;
        
        if (externalId == null) {
          errors.add('Theater thiếu externalId: ${seedTheater['name']}');
          continue;
        }

        final existingDoc = existingTheatersMap[externalId];

        if (existingDoc == null) {
          // ADD: Thêm mới
          if (!dryRun) {
            final docRef = _db.collection('theaters').doc(externalId);
            batch!.set(docRef, seedTheater);
            batchCount++;
            addedIds.add(externalId);
          }
          added++;
          print('  ➕ [ADD] ${seedTheater['name']}');
        } else {
          // So sánh để quyết định UPDATE hay UNCHANGED
          final existingData = existingDoc.data() as Map<String, dynamic>;
          
          if (_hasChanges(existingData, seedTheater)) {
            // UPDATE: Có thay đổi
            if (!dryRun) {
              batch!.update(existingDoc.reference, seedTheater);
              batchCount++;
              updatedIds.add(externalId);
            }
            updated++;
            print('  🔄 [UPDATE] ${seedTheater['name']}');
          } else {
            // UNCHANGED: Không đổi
            unchanged++;
          }
          
          // Đánh dấu đã xử lý
          existingTheatersMap.remove(externalId);
        }

        // Commit batch nếu đạt giới hạn
        if (!dryRun && batchCount >= batchLimit) {
          await batch!.commit();
          batch = _db.batch();
          batchCount = 0;
        }
      }

      // SET 2: Delete (các theater không còn trong seed)
      for (var remainingDoc in existingTheatersMap.values) {
        final data = remainingDoc.data() as Map<String, dynamic>?;
        final externalId = data?['externalId'] as String?;
        final name = data?['name'] ?? 'Unknown';
        
        if (!dryRun) {
          batch!.delete(remainingDoc.reference);
          batchCount++;
          if (externalId != null) deletedIds.add(externalId);
        }
        deleted++;
        print('  🗑️  [DELETE] $name');
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
        print('✅ Hoàn thành sync Theaters!\n');
      }

      return result;
      
    } catch (e) {
      print('❌ Lỗi khi sync theaters: $e');
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
  /// Bỏ qua các metadata fields và screens (sẽ được sync riêng)
  bool _hasChanges(Map<String, dynamic> existing, Map<String, dynamic> seed) {
    const fieldsToCompare = [
      'externalId', 'name', 'address', 'city', 'phone'
    ];

    for (var field in fieldsToCompare) {
      final existingValue = existing[field];
      final seedValue = seed[field];
      
      if (!DeepCollectionEquality().equals(existingValue, seedValue)) {
        return true;
      }
    }

    return false;
  }

  /// 🏢 [LEGACY] Thêm dữ liệu mẫu cho Theaters (giữ lại để backward compatible)
  Future<List<String>> seedTheaters() async {
    print('🏢 Bắt đầu thêm Theaters (Legacy mode - chỉ ADD)...');
    
    final theaters = TheaterSeedData.theaters;
    List<String> theaterIds = [];
    
    try {
      for (var theaterData in theaters) {
        final externalId = theaterData['externalId'] as String?;
        if (externalId == null) continue;
        
        final docRef = _db.collection('theaters').doc(externalId);
        await docRef.set(theaterData);
        theaterIds.add(externalId);
        print('✅ Đã thêm rạp: ${theaterData['name']}');
        
        await Future.delayed(Duration(milliseconds: 100));
      }

      print('🎉 Hoàn thành thêm ${theaterIds.length} rạp!\n');
      return theaterIds;
    } catch (e) {
      print('❌ Lỗi khi seed theaters: $e');
      rethrow;
    }
  }

  /// 📝 Thêm một theater đơn lẻ
  Future<String> addSingleTheater(Map<String, dynamic> theaterData) async {
    try {
      final externalId = theaterData['externalId'] as String?;
      if (externalId == null) {
        throw Exception('Theater phải có externalId');
      }
      
      final docRef = _db.collection('theaters').doc(externalId);
      await docRef.set(theaterData);
      print('✅ Đã thêm rạp: ${theaterData['name']}');
      return externalId;
    } catch (e) {
      print('❌ Lỗi khi thêm theater: $e');
      rethrow;
    }
  }

  /// 🗑️ Xóa tất cả theaters
  Future<void> clearTheaters() async {
    print('🗑️ Đang xóa tất cả theaters...');
    
    try {
      await _deleteCollection('theaters');
      print('✅ Đã xóa tất cả theaters\n');
    } catch (e) {
      print('❌ Lỗi khi xóa theaters: $e');
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
