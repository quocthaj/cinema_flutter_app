import 'package:doan_mobile/screens/widgets/colors.dart';
import 'package:flutter/material.dart';

class ServicePlanScreen extends StatefulWidget {
  final int initialIndex;
  final List<Map<String, dynamic>> services;

  const ServicePlanScreen({
    super.key,
    required this.initialIndex,
    required this.services,
  });

  @override
  State<ServicePlanScreen> createState() => _ServicePlanScreenState();
}

class _ServicePlanScreenState extends State<ServicePlanScreen> {
  late PageController _pageController;
  late int _currentServiceIndex;
  String _selectedArea = 'Tất cả';
  String _selectedTheater = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _currentServiceIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.services[_currentServiceIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ColorbuttonColor,
        title: const Text('Lập kế hoạch cùng Lotte Cinema'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Carousel dịch vụ ---
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.services.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentServiceIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = widget.services[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index == _currentServiceIndex
                            ? Colors.redAccent
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            item['description'],
                            style: const TextStyle(
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // --- FORM LIÊN HỆ ---
            TextField(
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            // --- Dropdown chọn dịch vụ ---
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Chọn dịch vụ',
                border: OutlineInputBorder(),
              ),
              initialValue: widget.services[_currentServiceIndex]['title'],
              items: widget.services
                  .map(
                    (s) => DropdownMenuItem<String>(
                      value: s['title'] as String,
                      child: Text(s['title'] as String),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                final index = widget.services.indexWhere(
                  (s) => s['title'] == value,
                );
                if (index != -1) {
                  setState(() {
                    _currentServiceIndex = index;
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 10),

            // --- Dropdown khu vực và rạp ---
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Chọn khu vực',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedArea,
                    items: ['Tất cả', 'Hà Nội', 'TP.HCM', 'Đà Nẵng']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedArea = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Chọn rạp',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedTheater,
                    items: ['Tất cả', 'Gò Vấp', 'Nam Sài Gòn', 'Thủ Đức']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTheater = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Thông tin chi tiết',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(value: false, onChanged: (_) {}),
                const Expanded(
                  child: Text(
                    'Tôi đồng ý cung cấp thông tin cho LOTTE Cinema để phục vụ nhu cầu đăng ký dịch vụ của tôi.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorbuttonColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('GỬI', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
