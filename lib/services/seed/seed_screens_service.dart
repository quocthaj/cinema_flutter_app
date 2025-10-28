// lib/services/seed/seed_screens_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Service để seed Screens
class SeedScreensService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🪑 Thêm dữ liệu mẫu cho Screens
  Future<List<String>> seedScreens(List<String> theaterIds) async {
    print('🪑 Bắt đầu thêm Screens...');
    
    List<String> screenIds = [];

    try {
      for (var theaterId in theaterIds) {
        // Mỗi rạp có 3-5 phòng chiếu
        final numberOfScreens = 3 + (theaterIds.indexOf(theaterId) % 3); // 3-5 phòng
        
        for (int i = 1; i <= numberOfScreens; i++) {
          final isVIPScreen = i == numberOfScreens; // Phòng cuối là VIP
          final rows = isVIPScreen ? 6 : 8;
          final columns = isVIPScreen ? 8 : 10;
          final totalSeats = rows * columns;

          // Tạo sơ đồ ghế
          List<Map<String, dynamic>> seats = [];
          for (int row = 0; row < rows; row++) {
            for (int col = 0; col < columns; col++) {
              final seatId = '${String.fromCharCode(65 + row)}${col + 1}';
              final isVIPSeat = isVIPScreen || row >= rows - 2; // 2 hàng cuối là VIP
              
              seats.add({
                'id': seatId,
                'type': isVIPSeat ? 'vip' : 'standard',
                'isAvailable': true,
              });
            }
          }

          final screenData = {
            'theaterId': theaterId,
            'name': 'Phòng $i${isVIPScreen ? ' (VIP)' : ''}',
            'totalSeats': totalSeats,
            'rows': rows,
            'columns': columns,
            'seats': seats,
          };

          final docRef = await _db.collection('screens').add(screenData);
          screenIds.add(docRef.id);
          
          // Cập nhật danh sách screens trong theater
          await _db.collection('theaters').doc(theaterId).update({
            'screens': FieldValue.arrayUnion([docRef.id])
          });

          print('✅ Đã thêm: ${screenData['name']} - Rạp ${theaterIds.indexOf(theaterId) + 1}');
          
          // Thêm delay nhỏ
          await Future.delayed(Duration(milliseconds: 50));
        }
      }

      print('🎉 Hoàn thành thêm ${screenIds.length} phòng chiếu!\n');
      return screenIds;
    } catch (e) {
      print('❌ Lỗi khi seed screens: $e');
      rethrow;
    }
  }

  /// 🗑️ Xóa tất cả screens
  Future<void> clearScreens() async {
    print('🗑️ Đang xóa tất cả screens...');
    
    try {
      await _deleteCollection('screens');
      print('✅ Đã xóa tất cả screens\n');
    } catch (e) {
      print('❌ Lỗi khi xóa screens: $e');
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
