// lib/scripts/check_screen_data.dart
// Script kiểm tra dữ liệu screens và showtimes trong Firebase

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

void main() async {
  print('🔍 KIỂM TRA DỮ LIỆU SCREENS VÀ SHOWTIMES\n');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // 1. Kiểm tra Theaters
    print('=' * 60);
    print('📍 CHECKING THEATERS');
    print('=' * 60);
    final theatersSnapshot = await firestore.collection('theaters').limit(3).get();
    print('✅ Tìm thấy ${theatersSnapshot.docs.length} theaters (showing first 3):\n');
    
    for (var theater in theatersSnapshot.docs) {
      final data = theater.data();
      print('  🎭 ${theater.id}');
      print('     Name: ${data['name']}');
      print('     City: ${data['city']}');
    }
    
    // 2. Kiểm tra Screens
    print('\n' + '=' * 60);
    print('🎬 CHECKING SCREENS');
    print('=' * 60);
    final screensSnapshot = await firestore.collection('screens').get();
    print('✅ Tìm thấy ${screensSnapshot.docs.length} screens:\n');
    
    // Group screens by theater
    final Map<String, List<Map<String, dynamic>>> screensByTheater = {};
    for (var screen in screensSnapshot.docs) {
      final data = screen.data();
      final theaterId = data['theaterId'] ?? 'unknown';
      
      screensByTheater.putIfAbsent(theaterId, () => []).add({
        'id': screen.id,
        'name': data['name'],
        'totalSeats': data['totalSeats'],
      });
    }
    
    // Hiển thị chi tiết 2 theaters đầu tiên
    int count = 0;
    for (var entry in screensByTheater.entries) {
      if (count >= 2) break;
      
      print('  🎭 Theater: ${entry.key}');
      print('     Số phòng: ${entry.value.length}');
      for (var screen in entry.value) {
        print('     - ${screen['name']} (${screen['totalSeats']} ghế) [ID: ${screen['id']}]');
      }
      print('');
      count++;
    }
    
    // 3. Kiểm tra Showtimes
    print('=' * 60);
    print('🎥 CHECKING SHOWTIMES');
    print('=' * 60);
    final showtimesSnapshot = await firestore
        .collection('showtimes')
        .where('status', isEqualTo: 'active')
        .limit(20)
        .get();
    
    print('✅ Tìm thấy ${showtimesSnapshot.docs.length} showtimes (showing first 20):\n');
    
    // Check screenId mapping
    final Set<String> uniqueScreenIds = {};
    final Map<String, int> screenIdCount = {};
    
    for (var showtime in showtimesSnapshot.docs) {
      final data = showtime.data();
      final screenId = data['screenId'] ?? 'NO_SCREEN_ID';
      
      uniqueScreenIds.add(screenId);
      screenIdCount[screenId] = (screenIdCount[screenId] ?? 0) + 1;
    }
    
    print('📊 PHÂN TÍCH:');
    print('  - Unique screenIds: ${uniqueScreenIds.length}');
    print('  - Showtimes per screen:');
    
    int index = 0;
    for (var entry in screenIdCount.entries) {
      if (index >= 5) {
        print('  ... và ${screenIdCount.length - 5} screens khác');
        break;
      }
      
      // Lookup screen name
      final screenDoc = await firestore.collection('screens').doc(entry.key).get();
      String screenName;
      if (screenDoc.exists) {
        final data = screenDoc.data();
        screenName = data?['name'] ?? 'Unknown';
      } else {
        screenName = '❌ NOT FOUND IN SCREENS COLLECTION';
      }
      
      print('  - ${entry.key}: ${entry.value} showtimes → "$screenName"');
      index++;
    }
    
    // 4. Kiểm tra chi tiết 5 showtimes đầu tiên
    print('\n' + '=' * 60);
    print('🔍 CHI TIẾT 5 SHOWTIMES ĐẦU TIÊN');
    print('=' * 60);
    
    for (int i = 0; i < 5 && i < showtimesSnapshot.docs.length; i++) {
      final showtime = showtimesSnapshot.docs[i];
      final data = showtime.data();
      
      print('\n  🎬 Showtime ${i + 1}:');
      print('     ID: ${showtime.id}');
      print('     movieId: ${data['movieId']}');
      print('     theaterId: ${data['theaterId']}');
      print('     screenId: ${data['screenId']}');
      
      // Lookup screen
      final screenId = data['screenId'] as String?;
      if (screenId != null) {
        final screenDoc = await firestore.collection('screens').doc(screenId).get();
        if (screenDoc.exists) {
          final screenData = screenDoc.data()!;
          print('     ✅ Screen found: "${screenData['name']}"');
        } else {
          print('     ❌ Screen NOT FOUND in screens collection!');
        }
      } else {
        print('     ❌ NO screenId field!');
      }
      
      final startTime = (data['startTime'] as Timestamp?)?.toDate();
      if (startTime != null) {
        final time = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        print('     Time: $time');
      }
    }
    
    // 5. Tìm showtimes với screenId bị lỗi
    print('\n' + '=' * 60);
    print('⚠️  CHECKING FOR INVALID SCREEN REFERENCES');
    print('=' * 60);
    
    final allShowtimesSnapshot = await firestore
        .collection('showtimes')
        .where('status', isEqualTo: 'active')
        .get();
    
    int invalidCount = 0;
    for (var showtime in allShowtimesSnapshot.docs) {
      final data = showtime.data();
      final screenId = data['screenId'] as String?;
      
      if (screenId != null) {
        final screenDoc = await firestore.collection('screens').doc(screenId).get();
        if (!screenDoc.exists) {
          invalidCount++;
          if (invalidCount <= 3) {
            print('  ❌ Showtime ${showtime.id}');
            print('     screenId: $screenId (NOT FOUND)');
            print('     theaterId: ${data['theaterId']}');
          }
        }
      }
    }
    
    if (invalidCount > 0) {
      print('\n  ⚠️  FOUND $invalidCount showtimes with invalid screenId references!');
      print('  📝 RECOMMENDATION: Chạy lại seed data hoặc fix references');
    } else {
      print('\n  ✅ All showtimes have valid screen references!');
    }
    
    print('\n' + '=' * 60);
    print('🎉 KIỂM TRA HOÀN TẤT');
    print('=' * 60);
    
  } catch (e, stackTrace) {
    print('\n❌ LỖI: $e');
    print('Stack trace: $stackTrace');
  }
}
