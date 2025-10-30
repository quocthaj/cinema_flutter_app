// lib/scripts/fix_screen_names.dart
// Script kiểm tra và fix tên phòng chiếu bị sai trong Firebase

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

void main() async {
  print('🔧 FIX SCREEN NAMES - BẮT ĐẦU\n');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // 1. Kiểm tra tất cả screens
    print('=' * 60);
    print('📊 KIỂM TRA TẤT CẢ SCREENS');
    print('=' * 60);
    
    final screensSnapshot = await firestore.collection('screens').get();
    print('✅ Tìm thấy ${screensSnapshot.docs.length} screens\n');
    
    // Group by theater
    final Map<String, List<Map<String, dynamic>>> screensByTheater = {};
    
    for (var screenDoc in screensSnapshot.docs) {
      final data = screenDoc.data();
      final theaterId = data['theaterId'] ?? 'unknown';
      
      screensByTheater.putIfAbsent(theaterId, () => []).add({
        'id': screenDoc.id,
        'name': data['name'],
        'totalSeats': data['totalSeats'],
      });
    }
    
    // 2. Hiển thị chi tiết từng theater
    print('🎭 CHI TIẾT TỪNG THEATER:\n');
    
    int theaterIndex = 0;
    for (var entry in screensByTheater.entries) {
      theaterIndex++;
      
      // Get theater name
      final theaterDoc = await firestore.collection('theaters').doc(entry.key).get();
      String theaterName;
      if (theaterDoc.exists) {
        final data = theaterDoc.data();
        theaterName = data?['name'] ?? 'Unknown';
      } else {
        theaterName = '❌ NOT FOUND';
      }
      
      print('$theaterIndex. 🎭 $theaterName (ID: ${entry.key})');
      print('   Số phòng: ${entry.value.length}');
      
      // Check for duplicates
      final Map<String, int> nameCount = {};
      for (var screen in entry.value) {
        final name = screen['name'] as String;
        nameCount[name] = (nameCount[name] ?? 0) + 1;
      }
      
      // Hiển thị screens
      for (var screen in entry.value) {
        final name = screen['name'] as String;
        final isDuplicate = nameCount[name]! > 1;
        
        if (isDuplicate) {
          print('   ❌ ${screen['name']} (${screen['totalSeats']} ghế) - DUPLICATE! [ID: ${screen['id']}]');
        } else {
          print('   ✅ ${screen['name']} (${screen['totalSeats']} ghế) [ID: ${screen['id']}]');
        }
      }
      
      // Warning if có duplicate
      if (nameCount.values.any((count) => count > 1)) {
        print('   ⚠️  WARNING: Theater này có tên phòng bị trùng!');
      }
      
      // Warning if không đủ 4 phòng
      if (entry.value.length != 4) {
        print('   ⚠️  WARNING: Theater này có ${entry.value.length} phòng (cần 4 phòng)');
      }
      
      print('');
      
      // Chỉ hiển thị 5 theaters đầu
      if (theaterIndex >= 5) {
        print('... và ${screensByTheater.length - 5} theaters khác\n');
        break;
      }
    }
    
    // 3. Thống kê tổng quan
    print('=' * 60);
    print('📊 THỐNG KÊ TỔNG QUAN');
    print('=' * 60);
    
    int totalScreens = 0;
    int theatersWithIssues = 0;
    int totalDuplicates = 0;
    
    for (var entry in screensByTheater.entries) {
      totalScreens += entry.value.length;
      
      final Map<String, int> nameCount = {};
      for (var screen in entry.value) {
        final name = screen['name'] as String;
        nameCount[name] = (nameCount[name] ?? 0) + 1;
      }
      
      final hasDuplicates = nameCount.values.any((count) => count > 1);
      final hasWrongCount = entry.value.length != 4;
      
      if (hasDuplicates || hasWrongCount) {
        theatersWithIssues++;
      }
      
      for (var count in nameCount.values) {
        if (count > 1) {
          totalDuplicates += count - 1;
        }
      }
    }
    
    print('Tổng số theaters: ${screensByTheater.length}');
    print('Tổng số screens: $totalScreens');
    print('Theaters có vấn đề: $theatersWithIssues');
    print('Tổng số tên bị trùng: $totalDuplicates');
    
    if (theatersWithIssues > 0) {
      print('\n⚠️  CÓ ${theatersWithIssues} THEATERS BỊ LỖI!');
      print('📝 KHUYẾN NGHỊ: Chạy lại seed data để fix:');
      print('   1. Vào app → Admin → Seed Data');
      print('   2. Hoặc chạy: dart run lib/scripts/reseed_all.dart');
    } else {
      print('\n✅ TẤT CẢ SCREENS ĐỀU ĐÚNG!');
    }
    
    // 4. Kiểm tra 5 screenIds từ log
    print('\n' + '=' * 60);
    print('🔍 KIỂM TRA 5 SCREEN IDS TỪ LOG');
    print('=' * 60);
    
    final problemScreenIds = [
      'M7cpOGDeOBPpFeE1kK2I',
      'ZYL2mFJhKG0a2HoeSTPV',
      'V5ByOgPaJTnbqp1D990j',
      '0jXKOP4pArNFzMYqTWOZ',
      'wkfbbG8jDiAYDTo6YsRV',
    ];
    
    for (var screenId in problemScreenIds) {
      final screenDoc = await firestore.collection('screens').doc(screenId).get();
      
      if (screenDoc.exists) {
        final data = screenDoc.data()!;
        final name = data['name'];
        final theaterId = data['theaterId'];
        
        // Get theater name
        final theaterDoc = await firestore.collection('theaters').doc(theaterId).get();
        String theaterName;
        if (theaterDoc.exists) {
          final data = theaterDoc.data();
          theaterName = data?['name'] ?? 'Unknown';
        } else {
          theaterName = 'NOT FOUND';
        }
        
        print('$screenId:');
        print('  Name: $name');
        print('  Theater: $theaterName');
        print('  TotalSeats: ${data['totalSeats']}');
        print('');
      } else {
        print('$screenId: ❌ NOT FOUND');
      }
    }
    
  } catch (e, stackTrace) {
    print('\n❌ LỖI: $e');
    print('Stack trace: $stackTrace');
  }
}
