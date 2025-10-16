// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart'; // Import Model Movie

// LƯU Ý QUAN TRỌNG VỀ URL:
// - Android Emulator: Dùng http://10.0.2.2:3000
// - iOS Simulator/Web/Desktop: Dùng http://localhost:3000

const String API_BASE_URL = 'http://10.0.2.2:3000/api'; 

class ApiService {
  // Lấy danh sách phim đang chiếu
  Future<List<Movie>> fetchNowPlayingMovies() async {
    print('Fetching movies from: $API_BASE_URL/movies/now-playing');
    
    final response = await http.get(Uri.parse('$API_BASE_URL/movies/now-playing'));

    if (response.statusCode == 200) {
      // Decode JSON từ chuỗi response body
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      
      // Chuyển List JSON sang List<Movie>
      return jsonResponse.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      // Báo lỗi nếu API không thành công
      throw Exception('Failed to load movies. Status code: ${response.statusCode}');
    }
  }
  
  // (Các hàm fetchShowtimeDates, fetchAvailableTimes sẽ được thêm sau)
}