// lib/services/seed/seed_theaters_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'theater_seed_data.dart';

/// Service để seed Theaters
class SeedTheatersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🏢 Thêm dữ liệu mẫu cho Theaters
  Future<List<String>> seedTheaters() async {
    print('🏢 Bắt đầu thêm Theaters...');
    
    final theaters = TheaterSeedData.theaters;
    List<String> theaterIds = [];
    
    try {
      for (var theaterData in theaters) {
        final docRef = await _db.collection('theaters').add(theaterData);
        theaterIds.add(docRef.id);
        print('✅ Đã thêm rạp: ${theaterData['name']}');
        
        // Thêm delay nhỏ để tránh quá tải
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
      final docRef = await _db.collection('theaters').add(theaterData);
      print('✅ Đã thêm rạp: ${theaterData['name']}');
      return docRef.id;
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
