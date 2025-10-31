import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';
import '../../models/movie.dart';
import '../../models/showtime.dart';
import '../../models/screen_model.dart';
import '../../models/booking_model.dart';
import '../../models/theater_model.dart';
import '../../services/firestore_service.dart';
import 'package:doan_mobile/screens/payment/payment_selection_screen.dart';

class BookingScreen extends StatefulWidget {
  final Movie movie;
  final Theater?
      theater; // ✅ Optional: có thể chọn từ cinema_selection hoặc null

  const BookingScreen({
    super.key,
    required this.movie,
    this.theater, // ✅ Theater đã chọn từ cinema_selection_screen
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // ✅ NEW: Firestore service
  final _firestoreService = FirestoreService();

  // ✅ OPTIMIZED: Dùng ValueNotifier thay vì setState cho từng state
  final ValueNotifier<String?> selectedDateNotifier = ValueNotifier(null);
  final ValueNotifier<Showtime?> selectedShowtimeNotifier = ValueNotifier(null);
  final ValueNotifier<Screen?> selectedScreenNotifier = ValueNotifier(null);
  final ValueNotifier<Theater?> selectedTheaterNotifier = ValueNotifier(null);
  final ValueNotifier<List<String>> selectedSeatsNotifier = ValueNotifier([]);

  // ✅ Cache screen info để tránh gọi API nhiều lần
  final Map<String, Screen> _screenCache = {};

  // ✅ Removed all hardcoded data
  // ❌ final List<String> availableDates = [...];
  // ❌ final List<String> availableTimes = [...];
  // ❌ final List<String> soldSeats = [...];
  // ❌ final List<String> seatList = [...];

  @override
  void initState() {
    super.initState();
    _preloadScreenData();
  }

  @override
  void dispose() {
    // ✅ Dispose all ValueNotifiers
    selectedDateNotifier.dispose();
    selectedShowtimeNotifier.dispose();
    selectedScreenNotifier.dispose();
    selectedTheaterNotifier.dispose();
    selectedSeatsNotifier.dispose();
    super.dispose();
  }

  /// Preload screen data để cache (không cần setState nữa)
  Future<void> _preloadScreenData() async {
    try {
      final showtimes =
          await _firestoreService.getShowtimesByMovie(widget.movie.id).first;

      final screenIds = showtimes.map((s) => s.screenId).toSet();

      for (var screenId in screenIds) {
        final screen = await _firestoreService.getScreenById(screenId);
        if (screen != null) {
          _screenCache[screenId] = screen;
        }
      }
    } catch (e) {
      print('Error preloading screens: $e');
    }
  }

  // =======================================================
  //                 ✅ SEAT LEGEND (Updated)
  // =======================================================
  Widget _buildSeatLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(AppTheme.primaryColor, "Đang chọn"),
        _legendItem(Colors.orange[700]!, "VIP"),
        _legendItem(AppTheme.fieldColor, "Trống"),
        _legendItem(Colors.red[900]!, "Đã đặt"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
        ),
      ],
    );
  }
  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Đặt vé - ${widget.movie.title}",
        ),
      ),
      body: StreamBuilder<List<Showtime>>(
        stream: _firestoreService.getShowtimesByMovie(widget.movie.id),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 60, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy,
                      size: 60, color: AppTheme.textSecondaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có lịch chiếu cho phim này',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng quay lại sau',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Success - build booking UI with real showtimes
          final showtimes = snapshot.data!;
          return _buildBookingContent(showtimes);
        },
      ),
    );
  }

  /// ✅ NEW: Build booking content with real showtimes
  Widget _buildBookingContent(List<Showtime> showtimes) {
    // ✅ Lọc theo theater nếu đã chọn từ cinema_selection
    final filteredByTheater = widget.theater != null
        ? showtimes.where((s) => s.theaterId == widget.theater!.id).toList()
        : showtimes;

    // Group showtimes by date
    final Map<String, List<Showtime>> groupedByDate = {};
    for (var showtime in filteredByTheater) {
      final date = showtime.getDate();
      groupedByDate.putIfAbsent(date, () => []).add(showtime);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THÔNG TIN PHIM ---
            _buildMovieInfo(),

            // --- THÔNG TIN RẠP (nếu đã chọn) ---
            if (widget.theater != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.theater!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          if (widget.theater!.address.isNotEmpty)
                            Text(
                              widget.theater!.address,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(color: Colors.white12, height: 30),

            // --- ✅ CHỌN NGÀY (ValueListenableBuilder) ---
            _buildSectionTitle("Chọn ngày chiếu"),
            const SizedBox(height: 12),
            _buildDateSelection(groupedByDate),

            const Divider(color: Colors.white12, height: 30),

            // --- ✅ CHỌN SUẤT CHIẾU (ValueListenableBuilder) ---
            _buildSectionTitle("Chọn suất chiếu"),
            const SizedBox(height: 12),
            ValueListenableBuilder<String?>(
              valueListenable: selectedDateNotifier,
              builder: (context, selectedDate, _) {
                if (selectedDate == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Vui lòng chọn ngày chiếu trước',
                      style: TextStyle(
                          color: AppTheme.textSecondaryColor, fontSize: 14),
                    ),
                  );
                }

                final filteredShowtimes = groupedByDate[selectedDate] ?? [];
                return _buildShowtimeSelection(filteredShowtimes);
              },
            ),

            // --- ✅ CHỌN GHẾ (ValueListenableBuilder - chỉ khi đã chọn showtime) ---
            ValueListenableBuilder<Showtime?>(
              valueListenable: selectedShowtimeNotifier,
              builder: (context, selectedShowtime, _) {
                if (selectedShowtime == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.white12, height: 30),
                    _buildSectionTitle("Chọn ghế ngồi"),
                    const SizedBox(height: 20),
                    _buildSeatSelection(),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // --- TỔNG KẾT & XÁC NHẬN (ValueListenableBuilder cho seats) ---
            _buildSummaryAndConfirmation(),
          ],
        ),
      ),
    );
  }

  /// ✅ NEW: Movie info section
  Widget _buildMovieInfo() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            widget.movie.posterUrl,
            height: 100,
            width: 70,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                height: 100,
                width: 70,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: 70,
                color: AppTheme.cardColor,
                child: const Icon(
                  Icons.movie_creation_outlined,
                  color: Colors.white54,
                  size: 30,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.movie.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 20),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${widget.movie.duration} phút | ${widget.movie.genre}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ NEW: Date selection from real showtimes (ValueListenableBuilder)
  Widget _buildDateSelection(Map<String, List<Showtime>> groupedByDate) {
    if (groupedByDate.isEmpty) {
      return const Text('Không có lịch chiếu');
    }

    return ValueListenableBuilder<String?>(
      valueListenable: selectedDateNotifier,
      builder: (context, selectedDate, _) {
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: groupedByDate.keys.map((date) {
            final bool isSelected = date == selectedDate;
            final count = groupedByDate[date]!.length;

            return ActionChip(
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(date),
                  Text(
                    '$count suất',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
              onPressed: () {
                // ✅ Chỉ update ValueNotifier - không setState
                selectedDateNotifier.value = date;
                selectedShowtimeNotifier.value = null; // Reset showtime
                selectedSeatsNotifier.value = []; // Reset seats
              },
              backgroundColor:
                  isSelected ? AppTheme.primaryColor : AppTheme.fieldColor,
              labelStyle: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide.none,
            );
          }).toList(),
        );
      },
    );
  }

  /// ✅ NEW: Showtime selection with theater & screen info
  Widget _buildShowtimeSelection(List<Showtime> showtimes) {
    if (showtimes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Không có suất chiếu cho ngày này',
          style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14),
        ),
      );
    }

    // ✅ Nếu đã chọn theater từ cinema_selection, hiển thị đơn giản hơn
    if (widget.theater != null) {
      return _buildSimpleShowtimeSelection(showtimes);
    }

    // ✅ Nếu chưa chọn theater, nhóm theo theater
    return _buildGroupedShowtimeSelection(showtimes);
  }

  /// Hiển thị suất chiếu đơn giản (đã chọn rạp) với ValueListenableBuilder
  Widget _buildSimpleShowtimeSelection(List<Showtime> showtimes) {
    return ValueListenableBuilder<Showtime?>(
      valueListenable: selectedShowtimeNotifier,
      builder: (context, selectedShowtime, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: showtimes.map((showtime) {
            final bool isSelected = selectedShowtime?.id == showtime.id;
            final canBook = showtime.availableSeats > 0;

            // ✅ Dùng cache thay vì FutureBuilder
            final screen = _screenCache[showtime.screenId];
            final screenName = screen?.name ?? 'Đang tải...';

            return InkWell(
              onTap: canBook
                  ? () async {
                      // ✅ Chỉ update ValueNotifier - không setState
                      selectedShowtimeNotifier.value = showtime;
                      selectedSeatsNotifier.value = [];
                      await _loadShowtimeDetails(showtime);
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (canBook ? AppTheme.fieldColor : Colors.grey[800]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showtime.getTime(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: canBook
                            ? AppTheme.textPrimaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                    if (screenName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        screenName,
                        style: TextStyle(
                          fontSize: 10,
                          color: canBook
                              ? AppTheme.textSecondaryColor
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      '${showtime.availableSeats} ghế',
                      style: TextStyle(
                        fontSize: 10,
                        color: canBook
                            ? AppTheme.textSecondaryColor
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Hiển thị suất chiếu nhóm theo rạp (chưa chọn rạp) với ValueListenableBuilder
  Widget _buildGroupedShowtimeSelection(List<Showtime> showtimes) {
    // Group showtimes by theater
    final Map<String, List<Showtime>> groupedByTheater = {};
    for (var showtime in showtimes) {
      groupedByTheater.putIfAbsent(showtime.theaterId, () => []).add(showtime);
    }

    return ValueListenableBuilder<Showtime?>(
      valueListenable: selectedShowtimeNotifier,
      builder: (context, selectedShowtime, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groupedByTheater.entries.map((entry) {
            final theaterId = entry.key;
            final theaterShowtimes = entry.value;

            return FutureBuilder<Theater?>(
              future: _firestoreService.getTheaterById(theaterId),
              builder: (context, snapshot) {
                final theaterName = snapshot.data?.name ?? 'Đang tải...';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Theater name
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: AppTheme.primaryColor, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              theaterName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Showtimes
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: theaterShowtimes.map((showtime) {
                          final bool isSelected =
                              selectedShowtime?.id == showtime.id;
                          final canBook = showtime.availableSeats > 0;

                          // ✅ Dùng cache thay vì FutureBuilder
                          final screen = _screenCache[showtime.screenId];
                          final screenName = screen?.name ?? 'Đang tải...';

                          return InkWell(
                            onTap: canBook
                                ? () async {
                                    // ✅ Chỉ update ValueNotifier - không setState
                                    selectedShowtimeNotifier.value = showtime;
                                    selectedSeatsNotifier.value = [];
                                    await _loadShowtimeDetails(showtime);
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : (canBook
                                        ? AppTheme.fieldColor
                                        : Colors.grey[800]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    showtime.getTime(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: canBook
                                          ? AppTheme.textPrimaryColor
                                          : AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  if (screenName.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      screenName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: canBook
                                            ? AppTheme.textSecondaryColor
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    '${showtime.availableSeats} ghế',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: canBook
                                          ? AppTheme.textSecondaryColor
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// ✅ NEW: Load screen and theater details (update ValueNotifier thay vì setState)
  Future<void> _loadShowtimeDetails(Showtime showtime) async {
    try {
      final results = await Future.wait<Object?>([
        _firestoreService.getScreenById(showtime.screenId),
        _firestoreService.getTheaterById(showtime.theaterId),
      ]);

      // ✅ Update ValueNotifiers - không cần setState
      selectedScreenNotifier.value = results[0] as Screen?;
      selectedTheaterNotifier.value = results[1] as Theater?;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thông tin: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// ✅ NEW: Seat selection with real seat layout (ValueListenableBuilder)
  Widget _buildSeatSelection() {
    return ValueListenableBuilder<Screen?>(
      valueListenable: selectedScreenNotifier,
      builder: (context, selectedScreen, _) {
        if (selectedScreen == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<Showtime?>(
          valueListenable: selectedShowtimeNotifier,
          builder: (context, selectedShowtime, _) {
            if (selectedShowtime == null) {
              return const SizedBox.shrink();
            }

            final screen = selectedScreen;
            final bookedSeats = selectedShowtime.bookedSeats;

            return Column(
              children: [
                // Theater and screen info
                ValueListenableBuilder<Theater?>(
                  valueListenable: selectedTheaterNotifier,
                  builder: (context, selectedTheater, _) {
                    if (selectedTheater == null) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.theaters,
                              color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${selectedTheater.name} - ${screen.name}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Screen label
                Text(
                  "SCREEN",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.8),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ Real seat grid WITH AISLES (with ValueListenableBuilder for seats)
                _buildSeatGridWithAisles(screen, bookedSeats),

                const SizedBox(height: 20),
                _buildSeatLegend(),
              ],
            );
          },
        );
      },
    );
  }

  /// ✅ FIXED: Build seat grid WITH AISLES (ValueListenableBuilder)
  /// Seats từ Firestore đã bỏ qua aisles (A1,A2,A3,A4,A7,A8... - không có A5,A6)
  /// Ta chỉ cần render từng seat theo vị trí column của nó
  Widget _buildSeatGridWithAisles(Screen screen, List<String> bookedSeats) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: selectedSeatsNotifier,
      builder: (context, selectedSeats, _) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screen.columns + 2, // +2 for row labels
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: screen.rows * (screen.columns + 2), // Total grid cells
          itemBuilder: (context, index) {
            final int row = index ~/ (screen.columns + 2);
            final int col = index % (screen.columns + 2);

            // Row label (first column)
            if (col == 0) {
              if (row < screen.rows) {
                return Center(
                  child: Text(
                    String.fromCharCode('A'.codeUnitAt(0) + row),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            // Empty space (last column)
            if (col == screen.columns + 1) {
              return const SizedBox.shrink();
            }

            // Column number (1-based, từ data)
            final actualCol =
                col; // col đã là 1-12 cho IMAX, 1-10 cho Standard, 1-8 cho VIP

            // Tìm seat với row + column này
            final rowLetter = String.fromCharCode('A'.codeUnitAt(0) + row);
            final seatId = '$rowLetter$actualCol';

            // ✅ Try to find seat - nếu không có thì là AISLE
            final seatIndex = screen.seats.indexWhere((s) => s.id == seatId);

            if (seatIndex == -1) {
              // Không tìm thấy seat → đây là AISLE
              return Container(
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_downward,
                  size: 16,
                  color: AppTheme.textSecondaryColor.withOpacity(0.3),
                ),
              );
            }

            final seat = screen.seats[seatIndex];
            final isBooked = bookedSeats.contains(seat.id);
            final isSelected = selectedSeats.contains(seat.id);

            Color seatColor;
            if (isBooked) {
              seatColor = Colors.red[900]!; // Đã đặt
            } else if (isSelected) {
              seatColor = AppTheme.primaryColor; // Đang chọn
            } else if (seat.type == 'vip') {
              seatColor = Colors.orange[700]!; // VIP available
            } else {
              seatColor = AppTheme.fieldColor; // Standard available
            }

            return GestureDetector(
              onTap: isBooked
                  ? null
                  : () {
                      // ✅ Chỉ update ValueNotifier - không setState
                      final updatedSeats = List<String>.from(selectedSeats);
                      if (isSelected) {
                        updatedSeats.remove(seat.id);
                      } else {
                        updatedSeats.add(seat.id);
                      }
                      selectedSeatsNotifier.value = updatedSeats;
                    },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: seatColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                ),
                child: Text(
                  seat.id,
                  style: TextStyle(
                    fontSize: 10,
                    color: isBooked ? Colors.white54 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
    );
  }

  /// ✅ NEW: Summary and confirmation with real pricing (ValueListenableBuilder)
  Widget _buildSummaryAndConfirmation() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: selectedSeatsNotifier,
      builder: (context, selectedSeats, _) {
        return ValueListenableBuilder<Showtime?>(
          valueListenable: selectedShowtimeNotifier,
          builder: (context, selectedShowtime, _) {
            return ValueListenableBuilder<Screen?>(
              valueListenable: selectedScreenNotifier,
              builder: (context, selectedScreen, _) {
                // Calculate real price from selected seats and showtime
                double totalPrice = 0.0;
                final Map<String, String> seatTypes = {};

                if (selectedShowtime != null && selectedScreen != null) {
                  for (var seatId in selectedSeats) {
                    final seat = selectedScreen.seats.firstWhere(
                      (s) => s.id == seatId,
                      orElse: () => selectedScreen.seats.first,
                    );

                    seatTypes[seatId] = seat.type;

                    if (seat.type == 'vip') {
                      totalPrice += selectedShowtime.vipPrice;
                    } else {
                      totalPrice += selectedShowtime.basePrice;
                    }
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ghế đã chọn:",
                          style: TextStyle(
                              color: AppTheme.textSecondaryColor, fontSize: 16),
                        ),
                        Text(
                          selectedSeats.isEmpty
                              ? "Chưa chọn"
                              : selectedSeats.join(", "),
                          style: TextStyle(
                            color: selectedSeats.isEmpty
                                ? AppTheme.textSecondaryColor
                                : AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tổng tiền:",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 18),
                        ),
                        Text(
                          "${totalPrice.toStringAsFixed(0)} VNĐ",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    color: AppTheme.primaryColor,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            selectedShowtime == null || selectedSeats.isEmpty
                                ? null
                                : () => _confirmBooking(totalPrice, seatTypes),
                        child: const Text(
                          "Xác nhận đặt vé",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// ✅ NEW: Real booking creation with Firestore
  Future<void> _confirmBooking(
    double totalPrice,
    Map<String, String> seatTypes,
  ) async {
    // Lấy giá trị hiện tại từ notifiers
    final selectedShowtime = selectedShowtimeNotifier.value;
    final selectedTheater = selectedTheaterNotifier.value;
    final selectedScreen = selectedScreenNotifier.value;
    final selectedSeats = selectedSeatsNotifier.value;
    final selectedDate = selectedDateNotifier.value;

    // 1. Check user logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Vui lòng đăng nhập để đặt vé')),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          action: SnackBarAction(
            label: 'Đăng nhập',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Navigate to login screen
              Navigator.pushNamed(context, '/login');
            },
          ),
        ),
      );
      return;
    }

    // 2. Validate selection
    if (selectedShowtime == null || selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn suất chiếu và ghế!'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // 3. Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đặt vé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phim: ${widget.movie.title}'),
            const SizedBox(height: 8),
            if (selectedTheater != null) Text('Rạp: ${selectedTheater.name}'),
            if (selectedScreen != null) Text('Phòng: ${selectedScreen.name}'),
            const SizedBox(height: 8),
            Text('Ngày: $selectedDate'),
            Text('Giờ: ${selectedShowtime.getTime()}'),
            const SizedBox(height: 8),
            Text('Ghế: ${selectedSeats.join(", ")}'),
            const SizedBox(height: 8),
            Text(
              'Tổng tiền: ${totalPrice.toStringAsFixed(0)} VNĐ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 4. Create booking
    EasyLoading.show(status: 'Đang đặt vé...');

    try {
      // Create booking object
      final booking = Booking(
        id: '', // Firestore will generate
        userId: user.uid,
        showtimeId: selectedShowtime.id,
        movieId: widget.movie.id,
        movieTitle: widget.movie.title,
        theaterId: selectedShowtime.theaterId,
        screenId: selectedShowtime.screenId,
        selectedSeats: selectedSeats,
        seatTypes: seatTypes,
        theaterName: selectedTheater?.name ?? '',
        screenName: selectedScreen?.name ?? '',
        totalPrice: totalPrice,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // ✅ Save to Firestore (with transaction to prevent double booking)
      final bookingId = await _firestoreService.createBooking(booking);

      EasyLoading.dismiss();

      if (!mounted) return;
      if (mounted) {
        // Dùng rootNavigator: true để đóng dialog "Xác nhận"
        Navigator.of(context, rootNavigator: true).pop();

        // Chuyển sang màn hình Chọn Thanh toán
        // Dùng pushReplacement để người dùng không "back" lại được màn hình chọn ghế
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSelectionScreen(
              bookingId: bookingId, // ID booking vừa tạo
              amount: totalPrice, // Tổng tiền đã tính
            ),
          ),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();

      if (!mounted) return;

      String errorMessage = 'Đặt vé thất bại';
      if (e.toString().contains('đã được đặt')) {
        errorMessage =
            'Ghế đã được đặt bởi người khác.\nVui lòng chọn ghế khác.';
      } else if (e.toString().contains('không tồn tại')) {
        errorMessage = 'Lịch chiếu không tồn tại hoặc đã bị hủy.';
      } else {
        errorMessage = 'Lỗi: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: () => _confirmBooking(totalPrice, seatTypes),
          ),
        ),
      );
    }
  }
}
