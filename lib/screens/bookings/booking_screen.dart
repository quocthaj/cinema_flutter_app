import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../widgets/colors.dart';

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

  final List<String> seatList = [
    "A1", "A2", "A3", "A4", "A5",
    "B1", "B2", "B3", "B4", "B5",
    "C1", "C2", "C3", "C4", "C5",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: datve,
        title: Text("Đặt vé - ${widget.movie.title}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- THÔNG TIN PHIM ---
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.movie.posterUrl,
                      height: 150,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.movie.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- CHỌN NGÀY ---
              const Text(
                "Chọn ngày chiếu",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: availableDates.map((date) {
                  final bool isSelected = date == selectedDate;
                  return ChoiceChip(
                    label: Text(date),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedDate = date);
                    },
                    selectedColor: datve,
                    backgroundColor: Colors.grey[800],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // --- CHỌN GIỜ ---
              const Text(
                "Chọn suất chiếu",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: availableTimes.map((time) {
                  final bool isSelected = time == selectedTime;
                  return ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedTime = time);
                    },
                    selectedColor: datve,
                    backgroundColor: Colors.grey[800],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // --- CHỌN GHẾ ---
              const Text(
                "Chọn ghế ngồi",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: seatList.length,
                itemBuilder: (context, index) {
                  final seat = seatList[index];
                  final bool isSelected = selectedSeats.contains(seat);

                  return GestureDetector(
                    onTap: () {
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
                        color: isSelected ? datve : Colors.grey[800],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        seat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- NÚT XÁC NHẬN ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedDate == null ||
                        selectedTime == null ||
                        selectedSeats.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Vui lòng chọn đủ ngày, giờ và ghế!"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Đặt vé thành công!\nPhim: ${widget.movie.title}\nNgày: $selectedDate - $selectedTime\nGhế: ${selectedSeats.join(", ")}",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: datve,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Xác nhận đặt vé",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
