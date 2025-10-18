import 'package:doan_mobile/screens/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'service_plan_screen.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        'title': 'THUÊ RẠP TỔ CHỨC SỰ KIỆN',
        'iconColor': Colors.redAccent,
        'image': 'lib/images/service_event.jpg',
        'description':
            'Không gian sang trọng, phòng chiếu riêng biệt, âm thanh vượt trội, hỗ trợ tổ chức họp báo, hội nghị, sự kiện đặc biệt...',
      },
      {
        'title': 'QUẢNG CÁO TẠI RẠP',
        'iconColor': Colors.green,
        'image': 'lib/images/service_ads.jpg',
        'description':
            'Tiếp cận hàng trăm ngàn khán giả mỗi ngày qua màn hình chiếu, poster, standee và các hoạt động PR sáng tạo tại rạp.',
      },
      {
        'title': 'MUA PHIẾU QUÀ TẶNG / E-CODE',
        'iconColor': Colors.orangeAccent,
        'image': 'lib/images/service_gift.jpg',
        'description':
            'Dành tặng bạn bè, đồng nghiệp hoặc khách hàng những trải nghiệm điện ảnh tuyệt vời với e-code tiện lợi.',
      },
      {
        'title': 'MUA VÉ NHÓM',
        'iconColor': Colors.deepOrange,
        'image': 'lib/images/service_group.jpg',
        'description':
            'Ưu đãi hấp dẫn khi mua vé nhóm cho công ty, trường học, câu lạc bộ hoặc các dịp đặc biệt.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ColorbuttonColor,
        title: const Text('Liên hệ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Banner & Info ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('lib/images/contact_banner.jpg'),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Bạn có nhu cầu quảng cáo tại rạp, thuê rạp tổ chức sự kiện, mua vé nhóm hoặc phiếu quà tặng?\n'
              '• Hãy liên hệ Lotte Cinema để được hỗ trợ nhanh nhất.',
              style: TextStyle(color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              'Email: ads.lottecinema@gmail.com\nHotline: 0965010004',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dịch vụ của chúng tôi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // --- Service List ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ListTile(
                  leading: Icon(
                    Icons.local_activity,
                    color: service['iconColor'],
                  ),
                  title: Text(
                    service['title'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServicePlanScreen(
                          initialIndex: index,
                          services: services,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
