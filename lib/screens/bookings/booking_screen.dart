import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/theme.dart';
import '../../models/movie.dart';

class BookingScreen extends StatefulWidget {
  final Movie movie;

  const BookingScreen({super.key, required this.movie});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedDate;
  String? selectedTime;
  List<String> selectedSeats = [];

  // Giả lập các ghế đã bán để thêm tính năng
  final List<String> soldSeats = ["A3", "B1", "C5"];

  final List<String> availableDates = [
    "11/10",
    "12/10",
    "13/10",
    "14/10",
    "15/10",
  ];

  final List<String> availableTimes = [
    "10:00",
    "13:00",
    "16:00",
    "19:00",
    "21:30",
  ];

  // Ghế được sắp xếp theo 5 cột và 3 hàng (A, B, C)
  final List<String> seatList = [
    "A1",
    "A2",
    "A3",
    "A4",
    "A5",
    "B1",
    "B2",
    "B3",
    "B4",
    "B5",
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
  ];

  // =======================================================
  //                 WIDGET CHỌN GHẾ MỚI
  // =======================================================
  Widget _buildSeatLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(AppTheme.primaryColor, "Đang chọn"),
        _legendItem(AppTheme.fieldColor, "Trống"),
        _legendItem(Colors.red[900]!, "Đã bán"),
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
          style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSeatGrid() {
    return Column(
      children: [
        // 1. Màn hình Chiếu
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
              color: AppTheme.primaryColor.withOpacity(0.8), // Màu đỏ/accent
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(5)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]),
        ),
        const SizedBox(height: 20),

        // 2. Lưới Ghế ngồi
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                7, // Tăng lên 7 cột để thêm khoảng trống và nhãn hàng
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0, // Tỉ lệ 1:1 cho ghế
          ),
          itemCount: seatList.length +
              3, // 3 hàng, mỗi hàng thêm 2 ô trống + 1 nhãn hàng
          itemBuilder: (context, index) {
            // Tính toán vị trí trong seatList (bỏ qua các vị trí nhãn)
            // Lưới 7 cột: Nhãn | Ghế | Ghế | Ghế | Ghế | Ghế | Nhãn
            int row = index ~/ 7;
            int col = index % 7;

            // Vị trí cột cho Nhãn (cột 0) và khoảng trống (cột 6)
            if (col == 0) {
              return Center(
                child: Text(
                  String.fromCharCode('A'.codeUnitAt(0) + row),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }
            if (col == 6) {
              return const SizedBox.shrink(); // Khoảng trống bên phải
            }

            // Tính toán index thực tế trong seatList (5 ghế mỗi hàng)
            // Lưới 7 cột: [Nhãn, G1, G2, G3, G4, G5, Trống]
            // index thực = (hàng * 5) + (cột - 1)
            int actualSeatIndex = row * 5 + (col - 1);
            if (actualSeatIndex >= seatList.length)
              return const SizedBox.shrink();

            final seat = seatList[actualSeatIndex];
            final bool isSelected = selectedSeats.contains(seat);
            final bool isSold = soldSeats.contains(seat);

            Color seatColor;
            if (isSold) {
              seatColor = Colors.red[900]!; // Ghế đã bán
            } else if (isSelected) {
              seatColor = AppTheme.primaryColor; // Ghế đang chọn
            } else {
              seatColor = AppTheme.fieldColor; // Ghế trống
            }

            return GestureDetector(
              onTap: isSold
                  ? null
                  : () {
                      // Không chọn được ghế đã bán
                      setState(() {
                        if (isSelected) {
                          selectedSeats.remove(seat);
                        } else {
                          selectedSeats.add(seat);
                        }
                      });
                    },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: seatColor,
                  // Mô phỏng hình dạng ghế (bo góc trên)
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                ),
                child: Text(
                  seat,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSold ? Colors.white54 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // 3. Chú thích Ghế
        _buildSeatLegend(),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- THÔNG TIN PHIM (Cải tiến nhẹ) ---
              Row(
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
              ),
              const Divider(color: Colors.white12, height: 30),

              // --- CHỌN NGÀY ---
              _buildSectionTitle("Chọn ngày chiếu"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12, // Tăng spacing
                children: availableDates.map((date) {
                  final bool isSelected = date == selectedDate;
                  return ActionChip(
                    // Dùng ActionChip
                    label: Text(date),
                    onPressed: () {
                      setState(() => selectedDate = date);
                    },
                    backgroundColor: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.fieldColor,
                    labelStyle: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),

              const Divider(color: Colors.white12, height: 30),

              // --- CHỌN GIỜ ---
              _buildSectionTitle("Chọn suất chiếu"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: availableTimes.map((time) {
                  final bool isSelected = time == selectedTime;
                  return ActionChip(
                    label: Text(time),
                    onPressed: () {
                      setState(() => selectedTime = time);
                    },
                    backgroundColor: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.fieldColor,
                    labelStyle: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),

              const Divider(color: Colors.white12, height: 30),

              // --- CHỌN GHẾ MỚI ---
              _buildSectionTitle("Chọn ghế ngồi"),
              const SizedBox(height: 20),

              _buildSeatGrid(), // Gọi widget lưới ghế mới

              const SizedBox(height: 30),

              // --- TỔNG KẾT & XÁC NHẬN ---
              _buildSummaryAndConfirmation(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
    );
  }

  // Widget Tóm tắt và Nút Xác nhận
  Widget _buildSummaryAndConfirmation() {
    final int seatCount = selectedSeats.length;
    final double ticketPrice = 100000; // Giả sử giá vé
    final double totalPrice = seatCount * ticketPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ghế đã chọn:",
              style:
                  TextStyle(color: AppTheme.textSecondaryColor, fontSize: 16),
            ),
            Text(
              selectedSeats.isEmpty ? "Chưa chọn" : selectedSeats.join(", "),
              style: TextStyle(
                  color: selectedSeats.isEmpty
                      ? AppTheme.textSecondaryColor
                      : AppTheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (selectedDate == null ||
                  selectedTime == null ||
                  selectedSeats.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Vui lòng chọn đủ ngày, giờ và ghế!"),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              // Hiển thị loading
              EasyLoading.show(status: 'Đang đặt vé...');

              try {
                // Giả lập xử lý đặt vé (gọi API)
                await Future.delayed(const Duration(seconds: 2));

                // Ẩn loading
                EasyLoading.dismiss();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Đặt vé thành công!\nPhim: ${widget.movie.title}\nNgày: $selectedDate - $selectedTime\nGhế: ${selectedSeats.join(", ")}\nTổng: ${totalPrice.toStringAsFixed(0)} VNĐ",
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 4),
                  ),
                );
              } catch (e) {
                EasyLoading.dismiss();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Đặt vé thất bại: $e"),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
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
  }
}
