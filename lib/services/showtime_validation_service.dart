// lib/services/showtime_validation_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/showtime.dart';

/// Service kiểm tra ràng buộc và xung đột lịch chiếu phim
/// 
/// ✅ NGHIỆP VỤ THỰC TẾ:
/// 1. Một rạp có thể chiếu nhiều phim cùng lúc (khác Room)
/// 2. Một Room chỉ chiếu 1 phim tại 1 thời điểm
/// 3. Phải có buffer time giữa các suất (15 phút dọn rạp)
/// 4. Tính thời lượng phim + buffer để kiểm tra overlap
/// 
/// USAGE:
/// ```dart
/// final validator = ShowtimeValidationService();
/// final result = await validator.validateNewShowtime(
///   screenId: 'screen-1',
///   startTime: DateTime.parse('2025-10-29 19:00'),
///   movieDuration: 120,
/// );
/// if (!result.isValid) {
///   print('Conflict: ${result.conflicts}');
/// }
/// ```
class ShowtimeValidationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  /// Buffer time sau mỗi suất chiếu (phút) - thời gian dọn rạp
  static const int bufferMinutes = 15;
  
  /// ✅ Kiểm tra showtime mới có conflict không
  /// 
  /// @param screenId ID phòng chiếu
  /// @param startTime Thời gian bắt đầu muốn thêm
  /// @param movieDuration Thời lượng phim (phút)
  /// @param excludeShowtimeId ID của showtime đang edit (để loại trừ khi update)
  /// @return ValidationResult với isValid và danh sách conflicts
  Future<ShowtimeValidationResult> validateNewShowtime({
    required String screenId,
    required DateTime startTime,
    required int movieDuration,
    String? excludeShowtimeId,
  }) async {
    try {
      // Tính thời gian kết thúc (bao gồm buffer)
      final endTimeWithBuffer = startTime.add(
        Duration(minutes: movieDuration + bufferMinutes)
      );
      
      // Lấy tất cả showtimes của phòng này trong cùng ngày
      final dayStart = DateTime(startTime.year, startTime.month, startTime.day);
      final dayEnd = dayStart.add(Duration(days: 1));
      
      final snapshot = await _db
          .collection('showtimes')
          .where('screenId', isEqualTo: screenId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
          .where('startTime', isLessThan: Timestamp.fromDate(dayEnd))
          .where('status', isEqualTo: 'active')
          .get();
      
      final conflicts = <ShowtimeConflict>[];
      
      for (var doc in snapshot.docs) {
        // Bỏ qua showtime đang edit
        if (excludeShowtimeId != null && doc.id == excludeShowtimeId) {
          continue;
        }
        
        final existingShowtime = Showtime.fromFirestore(doc);
        
        // Kiểm tra overlap
        // Showtime mới: [startTime ---- movieDuration ---- endTimeWithBuffer]
        // Showtime cũ: [existing.startTime ---- existing.endTime + buffer]
        
        final existingEndWithBuffer = existingShowtime.endTime.add(
          Duration(minutes: bufferMinutes)
        );
        
        // Check overlap: A.start < B.end && B.start < A.end
        final hasOverlap = startTime.isBefore(existingEndWithBuffer) &&
                          existingShowtime.startTime.isBefore(endTimeWithBuffer);
        
        if (hasOverlap) {
          conflicts.add(ShowtimeConflict(
            conflictingShowtimeId: doc.id,
            conflictingStartTime: existingShowtime.startTime,
            conflictingEndTime: existingShowtime.endTime,
            movieId: existingShowtime.movieId,
            reason: 'Trùng lịch chiếu (bao gồm ${bufferMinutes}p dọn rạp)',
          ));
        }
      }
      
      return ShowtimeValidationResult(
        isValid: conflicts.isEmpty,
        conflicts: conflicts,
        screenId: screenId,
        requestedStartTime: startTime,
        requestedEndTime: endTimeWithBuffer,
      );
      
    } catch (e) {
      return ShowtimeValidationResult(
        isValid: false,
        conflicts: [],
        screenId: screenId,
        requestedStartTime: startTime,
        requestedEndTime: startTime.add(Duration(minutes: movieDuration)),
        errorMessage: 'Lỗi kiểm tra: $e',
      );
    }
  }
  
  /// ✅ Kiểm tra tất cả showtimes của một phòng trong khoảng thời gian
  /// 
  /// Dùng để admin xem lịch phòng chiếu và tìm slot trống
  /// 
  /// @param screenId ID phòng chiếu
  /// @param startDate Ngày bắt đầu
  /// @param endDate Ngày kết thúc
  /// @return Danh sách showtimes đã sort theo thời gian
  Future<List<Showtime>> getScreenSchedule({
    required String screenId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _db
          .collection('showtimes')
          .where('screenId', isEqualTo: screenId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThan: Timestamp.fromDate(endDate))
          .where('status', isEqualTo: 'active')
          .orderBy('startTime')
          .get();
      
      return snapshot.docs
          .map((doc) => Showtime.fromFirestore(doc))
          .toList();
          
    } catch (e) {
      print('❌ Lỗi lấy lịch phòng: $e');
      return [];
    }
  }
  
  /// ✅ Tìm các khung giờ trống trong ngày
  /// 
  /// @param screenId ID phòng chiếu
  /// @param date Ngày cần tìm
  /// @param movieDuration Thời lượng phim cần xếp lịch (phút)
  /// @param operatingHours Giờ hoạt động của rạp (default: 08:00 - 23:00)
  /// @return Danh sách các khung giờ trống có thể xếp phim
  Future<List<TimeSlot>> findAvailableTimeSlots({
    required String screenId,
    required DateTime date,
    required int movieDuration,
    TimeRange? operatingHours,
  }) async {
    // Giờ hoạt động mặc định: 08:00 - 23:00
    final defaultStart = DateTime(date.year, date.month, date.day, 8, 0);
    final defaultEnd = DateTime(date.year, date.month, date.day, 23, 0);
    
    final dayStart = operatingHours?.start ?? defaultStart;
    final dayEnd = operatingHours?.end ?? defaultEnd;
    
    // Lấy tất cả showtimes trong ngày
    final schedule = await getScreenSchedule(
      screenId: screenId,
      startDate: DateTime(date.year, date.month, date.day),
      endDate: DateTime(date.year, date.month, date.day + 1),
    );
    
    final availableSlots = <TimeSlot>[];
    var currentTime = dayStart;
    
    for (var showtime in schedule) {
      // Nếu có khoảng trống giữa currentTime và showtime tiếp theo
      final gap = showtime.startTime.difference(currentTime).inMinutes;
      final requiredTime = movieDuration + bufferMinutes;
      
      if (gap >= requiredTime) {
        availableSlots.add(TimeSlot(
          start: currentTime,
          end: showtime.startTime,
          durationMinutes: gap,
        ));
      }
      
      // Di chuyển currentTime đến sau showtime này (có buffer)
      currentTime = showtime.endTime.add(Duration(minutes: bufferMinutes));
    }
    
    // Kiểm tra khoảng trống cuối ngày
    if (currentTime.isBefore(dayEnd)) {
      final gap = dayEnd.difference(currentTime).inMinutes;
      final requiredTime = movieDuration + bufferMinutes;
      
      if (gap >= requiredTime) {
        availableSlots.add(TimeSlot(
          start: currentTime,
          end: dayEnd,
          durationMinutes: gap,
        ));
      }
    }
    
    return availableSlots;
  }
  
  /// ✅ Gợi ý giờ chiếu tối ưu cho phim mới
  /// 
  /// Dựa trên:
  /// - Các slot trống trong ngày
  /// - Độ dài phim
  /// - Khung giờ vàng (18:00 - 22:00 ưu tiên)
  /// 
  /// @return Danh sách giờ gợi ý đã sort theo độ ưu tiên
  Future<List<DateTime>> suggestOptimalTimes({
    required String screenId,
    required DateTime date,
    required int movieDuration,
  }) async {
    final availableSlots = await findAvailableTimeSlots(
      screenId: screenId,
      date: date,
      movieDuration: movieDuration,
    );
    
    final suggestions = <TimeSuggestion>[];
    
    for (var slot in availableSlots) {
      var currentTime = slot.start;
      
      // Sinh tất cả thời gian có thể trong slot này (mỗi 30 phút)
      while (currentTime.add(Duration(minutes: movieDuration + bufferMinutes))
          .isBefore(slot.end) || 
          currentTime.add(Duration(minutes: movieDuration + bufferMinutes))
          .isAtSameMomentAs(slot.end)) {
        
        final priority = _calculateTimePriority(currentTime);
        
        suggestions.add(TimeSuggestion(
          time: currentTime,
          priority: priority,
        ));
        
        currentTime = currentTime.add(Duration(minutes: 30));
      }
    }
    
    // Sort theo priority giảm dần
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    
    return suggestions.map((s) => s.time).toList();
  }
  
  /// Tính độ ưu tiên của khung giờ (càng cao càng tốt)
  /// 
  /// Giờ vàng (18:00 - 22:00): 10 điểm
  /// Chiều (14:00 - 18:00): 7 điểm
  /// Tối muộn (22:00 - 23:00): 5 điểm
  /// Sáng (08:00 - 12:00): 4 điểm
  /// Trưa (12:00 - 14:00): 6 điểm
  int _calculateTimePriority(DateTime time) {
    final hour = time.hour;
    
    if (hour >= 18 && hour < 22) return 10; // Giờ vàng
    if (hour >= 14 && hour < 18) return 7;  // Chiều
    if (hour >= 12 && hour < 14) return 6;  // Trưa
    if (hour >= 22 && hour < 23) return 5;  // Tối muộn
    if (hour >= 8 && hour < 12) return 4;   // Sáng
    
    return 1; // Khác
  }
  
  /// ✅ Kiểm tra một showtime đã tồn tại có conflict không
  /// 
  /// Dùng để validate lại dữ liệu hiện có
  Future<ShowtimeValidationResult> validateExistingShowtime(String showtimeId) async {
    try {
      final doc = await _db.collection('showtimes').doc(showtimeId).get();
      
      if (!doc.exists) {
        return ShowtimeValidationResult(
          isValid: false,
          conflicts: [],
          screenId: '',
          requestedStartTime: DateTime.now(),
          requestedEndTime: DateTime.now(),
          errorMessage: 'Showtime không tồn tại',
        );
      }
      
      final showtime = Showtime.fromFirestore(doc);
      
      // Lấy thông tin phim để biết duration
      final movieDoc = await _db.collection('movies').doc(showtime.movieId).get();
      final movieDuration = movieDoc.exists 
          ? (movieDoc.data()?['duration'] ?? 120) as int
          : 120;
      
      return await validateNewShowtime(
        screenId: showtime.screenId,
        startTime: showtime.startTime,
        movieDuration: movieDuration,
        excludeShowtimeId: showtimeId, // Loại trừ chính nó
      );
      
    } catch (e) {
      return ShowtimeValidationResult(
        isValid: false,
        conflicts: [],
        screenId: '',
        requestedStartTime: DateTime.now(),
        requestedEndTime: DateTime.now(),
        errorMessage: 'Lỗi: $e',
      );
    }
  }
  
  /// ✅ Validate tất cả showtimes trong hệ thống
  /// 
  /// Dùng để kiểm tra data integrity sau khi seed
  /// @return Map<showtimeId, conflicts>
  Future<Map<String, List<ShowtimeConflict>>> validateAllShowtimes() async {
    print('🔍 Bắt đầu validate tất cả showtimes...\n');
    
    final allConflicts = <String, List<ShowtimeConflict>>{};
    
    try {
      final snapshot = await _db
          .collection('showtimes')
          .where('status', isEqualTo: 'active')
          .get();
      
      print('   Tổng số showtimes: ${snapshot.docs.length}');
      
      int checked = 0;
      for (var doc in snapshot.docs) {
        final result = await validateExistingShowtime(doc.id);
        
        if (!result.isValid && result.conflicts.isNotEmpty) {
          allConflicts[doc.id] = result.conflicts;
        }
        
        checked++;
        if (checked % 50 == 0) {
          print('   Đã kiểm tra: $checked/${snapshot.docs.length}');
        }
      }
      
      print('\n📊 Kết quả:');
      if (allConflicts.isEmpty) {
        print('   ✅ HOÀN HẢO! Không có conflict nào');
      } else {
        print('   ❌ Tìm thấy ${allConflicts.length} showtimes có conflict');
        
        // In ra 5 conflicts đầu
        int count = 0;
        for (var entry in allConflicts.entries) {
          if (count >= 5) break;
          print('   Showtime ${entry.key}: ${entry.value.length} conflicts');
          count++;
        }
        
        if (allConflicts.length > 5) {
          print('   ... và ${allConflicts.length - 5} showtimes khác');
        }
      }
      
    } catch (e) {
      print('❌ Lỗi: $e');
    }
    
    return allConflicts;
  }
}

/// ========================================
/// MODELS
/// ========================================

/// Kết quả validation
class ShowtimeValidationResult {
  final bool isValid;
  final List<ShowtimeConflict> conflicts;
  final String screenId;
  final DateTime requestedStartTime;
  final DateTime requestedEndTime;
  final String? errorMessage;
  
  ShowtimeValidationResult({
    required this.isValid,
    required this.conflicts,
    required this.screenId,
    required this.requestedStartTime,
    required this.requestedEndTime,
    this.errorMessage,
  });
  
  /// Message cho user
  String get message {
    if (errorMessage != null) return errorMessage!;
    if (isValid) return '✅ Lịch chiếu hợp lệ';
    return '❌ Có ${conflicts.length} xung đột lịch chiếu';
  }
  
  /// Chi tiết conflicts
  String get detailMessage {
    if (conflicts.isEmpty) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('Chi tiết xung đột:');
    for (var i = 0; i < conflicts.length; i++) {
      final c = conflicts[i];
      buffer.writeln('${i + 1}. ${c.reason}');
      buffer.writeln('   Suất hiện có: ${_formatTime(c.conflictingStartTime)} - ${_formatTime(c.conflictingEndTime)}');
    }
    return buffer.toString();
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Thông tin xung đột
class ShowtimeConflict {
  final String conflictingShowtimeId;
  final DateTime conflictingStartTime;
  final DateTime conflictingEndTime;
  final String movieId;
  final String reason;
  
  ShowtimeConflict({
    required this.conflictingShowtimeId,
    required this.conflictingStartTime,
    required this.conflictingEndTime,
    required this.movieId,
    required this.reason,
  });
}

/// Khung giờ trống
class TimeSlot {
  final DateTime start;
  final DateTime end;
  final int durationMinutes;
  
  TimeSlot({
    required this.start,
    required this.end,
    required this.durationMinutes,
  });
  
  @override
  String toString() {
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr ($durationMinutes phút)';
  }
}

/// Giờ hoạt động
class TimeRange {
  final DateTime start;
  final DateTime end;
  
  TimeRange({
    required this.start,
    required this.end,
  });
}

/// Gợi ý thời gian với độ ưu tiên
class TimeSuggestion {
  final DateTime time;
  final int priority;
  
  TimeSuggestion({
    required this.time,
    required this.priority,
  });
}
