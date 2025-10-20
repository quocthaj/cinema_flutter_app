import 'package:flutter/material.dart';
import '../widgets/colors.dart';

class RewardDetailsPage extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const RewardDetailsPage({super.key, required this.ticket});

  @override
  State<RewardDetailsPage> createState() => _RewardDetailsPageState();
}

class _RewardDetailsPageState extends State<RewardDetailsPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorbuttonColor,
        title: const Text('Quà tặng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(ticket['image'], height: 180, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text(ticket['title'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${ticket['price'] * _quantity} đ',
                style: const TextStyle(fontSize: 18, color: Colors.redAccent)),
            const SizedBox(height: 10),

            // Số lượng
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _quantity++),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: const Text('Mua ngay',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    indicatorColor: Colors.redAccent,
                    labelColor: Colors.black,
                    tabs: [
                      Tab(text: 'Nội dung chi tiết'),
                      Tab(text: 'Hướng dẫn sử dụng'),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '🎬 Quà tặng online 1EA\n'
                            'Không giới hạn số lượng mua.\n'
                            'Hạn sử dụng: ${ticket['duration']}.\n'
                            'Áp dụng cho tất cả rạp hệ thống.',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.5),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Sau khi mua, mã quà tặng sẽ được gửi trong mục "Voucher của tôi". '
                            'Khi đặt vé, nhập mã để giảm trừ tương ứng. '
                            'Không áp dụng hoàn tiền sau khi sử dụng.',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
