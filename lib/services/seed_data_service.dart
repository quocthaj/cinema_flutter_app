// lib/services/seed_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Service để thêm dữ liệu mẫu vào Firestore
/// Sử dụng một lần để khởi tạo database
class SeedDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🎬 Thêm dữ liệu mẫu cho Movies
  Future<List<String>> seedMovies() async {
    print('🎬 Bắt đầu thêm Movies...');
    
    final movies = [
      {
        'title': 'Avatar: The Way of Water',
        'genre': 'Sci-Fi, Adventure',
        'duration': 192,
        'rating': 8.5,
        'posterUrl': 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
        'status': 'now_showing',
        'releaseDate': '16/12/2022',
        'description': 'Jake Sully và Neytiri đã lập gia đình và đang cố gắng ở bên nhau. Tuy nhiên, họ phải rời khỏi nhà và khám phá các vùng khác nhau của Pandora.',
        'trailerUrl': 'https://www.youtube.com/watch?v=d9MyW72ELq0',
      },
      {
        'title': 'Mai',
        'genre': 'Drama, Romance',
        'duration': 131,
        'rating': 7.8,
        'posterUrl': 'https://cdn.galaxycine.vn/media/2024/1/26/mai-1_1706262139919.jpg',
        'status': 'now_showing',
        'releaseDate': '10/02/2024',
        'description': 'Câu chuyện về Mai, một cô gái bán đào phố cổ Hà Nội, và những biến cố trong cuộc đời cô.',
        'trailerUrl': 'https://www.youtube.com/watch?v=example',
      },
      {
        'title': 'Deadpool & Wolverine',
        'genre': 'Action, Comedy',
        'duration': 128,
        'rating': 8.2,
        'posterUrl': 'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
        'status': 'now_showing',
        'releaseDate': '26/07/2024',
        'description': 'Deadpool và Wolverine hợp tác trong một nhiệm vụ đầy hỗn loạn và hài hước.',
        'trailerUrl': 'https://www.youtube.com/watch?v=73_1biulkYk',
      },
      {
        'title': 'Oppenheimer',
        'genre': 'Biography, Drama',
        'duration': 180,
        'rating': 8.9,
        'posterUrl': 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
        'status': 'now_showing',
        'releaseDate': '21/07/2023',
        'description': 'Câu chuyện về J. Robert Oppenheimer, cha đẻ của bom nguyên tử.',
        'trailerUrl': 'https://www.youtube.com/watch?v=uYPbbksJxIg',
      },
      {
        'title': 'The Marvels',
        'genre': 'Action, Adventure, Fantasy',
        'duration': 105,
        'rating': 7.1,
        'posterUrl': 'https://image.tmdb.org/t/p/w500/9GBhzXMFjgcZ3FdR9w3bUMMTps5.jpg',
        'status': 'coming_soon',
        'releaseDate': '10/11/2024',
        'description': 'Captain Marvel, Ms. Marvel và Monica Rambeau hợp tác trong một cuộc phiêu lưu vũ trụ.',
        'trailerUrl': 'https://www.youtube.com/watch?v=wS_qbDztgVY',
      },
    ];

    List<String> movieIds = [];
    
    for (var movieData in movies) {
      final docRef = await _db.collection('movies').add(movieData);
      movieIds.add(docRef.id);
      print('✅ Đã thêm phim: ${movieData['title']}');
    }

    print('🎉 Hoàn thành thêm ${movieIds.length} phim!\n');
    return movieIds;
  }

  /// 🏢 Thêm dữ liệu mẫu cho Theaters
  Future<List<String>> seedTheaters() async {
    print('🏢 Bắt đầu thêm Theaters...');
    
    final theaters = [
      {
        'name': 'CGV Vincom Center',
        'address': '191 Bà Triệu, Hai Bà Trưng',
        'city': 'Hà Nội',
        'phone': '1900 6017',
        'screens': [], // Sẽ cập nhật sau khi tạo screens
      },
      {
        'name': 'Galaxy Cinema Nguyễn Du',
        'address': '116 Nguyễn Du, Quận 1',
        'city': 'Hồ Chí Minh',
        'phone': '1900 2224',
        'screens': [],
      },
      {
        'name': 'Lotte Cinema Đà Nẵng',
        'address': '255 Hùng Vương, Quận Hải Châu',
        'city': 'Đà Nẵng',
        'phone': '1900 5454',
        'screens': [],
      },
      {
        'name': 'BHD Star Cineplex',
        'address': '3/2 Vincom Plaza, Quận 10',
        'city': 'Hồ Chí Minh',
        'phone': '1900 2099',
        'screens': [],
      },
    ];

    List<String> theaterIds = [];
    
    for (var theaterData in theaters) {
      final docRef = await _db.collection('theaters').add(theaterData);
      theaterIds.add(docRef.id);
      print('✅ Đã thêm rạp: ${theaterData['name']}');
    }

    print('🎉 Hoàn thành thêm ${theaterIds.length} rạp!\n');
    return theaterIds;
  }

  /// 🪑 Thêm dữ liệu mẫu cho Screens
  Future<List<String>> seedScreens(List<String> theaterIds) async {
    print('🪑 Bắt đầu thêm Screens...');
    
    List<String> screenIds = [];

    for (var theaterId in theaterIds) {
      // Mỗi rạp có 3 phòng chiếu
      for (int i = 1; i <= 3; i++) {
        final isVIPScreen = i == 3; // Phòng 3 là VIP
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

        print('✅ Đã thêm phòng chiếu: ${screenData['name']} cho rạp $theaterId');
      }
    }

    print('🎉 Hoàn thành thêm ${screenIds.length} phòng chiếu!\n');
    return screenIds;
  }

  /// ⏰ Thêm dữ liệu mẫu cho Showtimes
  Future<void> seedShowtimes(
    List<String> movieIds, 
    List<String> theaterIds, 
    List<String> screenIds
  ) async {
    print('⏰ Bắt đầu thêm Showtimes...');
    
    int count = 0;
    final now = DateTime.now();

    // Tạo lịch chiếu cho 7 ngày tới
    for (int day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      
      // Mỗi phim sẽ có lịch chiếu
      for (var movieId in movieIds.take(3)) { // Chỉ lấy 3 phim đầu
        // Mỗi phim có 3 suất chiếu/ngày
        for (var timeSlot in ['10:00', '14:30', '19:00']) {
          final timeParts = timeSlot.split(':');
          final startTime = DateTime(
            date.year, date.month, date.day,
            int.parse(timeParts[0]), int.parse(timeParts[1])
          );
          final endTime = startTime.add(Duration(minutes: 120)); // 2 giờ

          // Random một screen
          final screenId = screenIds[count % screenIds.length];
          
          // Tìm theaterId từ screenId
          final screenDoc = await _db.collection('screens').doc(screenId).get();
          final theaterId = screenDoc.data()?['theaterId'] ?? theaterIds[0];
          final totalSeats = screenDoc.data()?['totalSeats'] ?? 80;

          final showtimeData = {
            'movieId': movieId,
            'screenId': screenId,
            'theaterId': theaterId,
            'startTime': Timestamp.fromDate(startTime),
            'endTime': Timestamp.fromDate(endTime),
            'basePrice': 80000.0,
            'vipPrice': 120000.0,
            'availableSeats': totalSeats,
            'bookedSeats': [],
            'status': 'active',
          };

          await _db.collection('showtimes').add(showtimeData);
          count++;
        }
      }
    }

    print('🎉 Hoàn thành thêm $count lịch chiếu!\n');
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
    
    final collections = ['movies', 'theaters', 'screens', 'showtimes', 'bookings', 'payments'];
    
    for (var collection in collections) {
      final snapshot = await _db.collection(collection).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Đã xóa collection: $collection');
    }
    
    print('🎉 Hoàn thành xóa dữ liệu!\n');
  }

  /// 📝 Thêm một movie đơn lẻ
  Future<String> addSingleMovie(Map<String, dynamic> movieData) async {
    final docRef = await _db.collection('movies').add(movieData);
    print('✅ Đã thêm phim: ${movieData['title']}');
    return docRef.id;
  }

  /// 📝 Thêm một theater đơn lẻ
  Future<String> addSingleTheater(Map<String, dynamic> theaterData) async {
    final docRef = await _db.collection('theaters').add(theaterData);
    print('✅ Đã thêm rạp: ${theaterData['name']}');
    return docRef.id;
  }
}
