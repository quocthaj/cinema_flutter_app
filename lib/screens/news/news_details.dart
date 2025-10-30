import 'package:flutter/material.dart';

class NewsDetailsPage extends StatelessWidget {
  final Map<String, dynamic> promotion;
  const NewsDetailsPage({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Khuyến mãi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Nền gradient mờ
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Nội dung
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh chính
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      promotion['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 220,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Tiêu đề
                Text(
                  promotion['title'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Ngày diễn ra
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      promotion['date'] ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                // Nội dung
                Text(
                  promotion['content'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
