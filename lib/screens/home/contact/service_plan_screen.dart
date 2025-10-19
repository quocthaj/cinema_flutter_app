import 'package:flutter/material.dart';
import '../../../config/theme.dart';

// Custom Clipper cho ticket shape với răng cưa 2 bên
class TicketClipper extends CustomClipper<Path> {
  final double notchRadius;
  final int notchCount;

  TicketClipper({this.notchRadius = 10, this.notchCount = 5});

  @override
  Path getClip(Size size) {
    final path = Path();
    const double cornerRadius = 12.0;
    
    // Top left corner
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    
    // Top edge
    path.lineTo(size.width - cornerRadius, 0);
    
    // Top right corner
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    
    // Right edge with notches (răng cưa)
    final double notchSpacing = (size.height - cornerRadius * 2) / (notchCount + 1);
    for (int i = 0; i <= notchCount; i++) {
      final double y = cornerRadius + notchSpacing * i + notchSpacing / 2;
      if (i < notchCount) {
        path.lineTo(size.width, y - notchRadius);
        path.arcToPoint(
          Offset(size.width, y + notchRadius),
          radius: Radius.circular(notchRadius),
          clockwise: false,
        );
      }
    }
    
    // Bottom right corner
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - cornerRadius, size.height);
    
    // Bottom edge
    path.lineTo(cornerRadius, size.height);
    
    // Bottom left corner
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    
    // Left edge with notches (răng cưa)
    for (int i = notchCount; i >= 0; i--) {
      final double y = cornerRadius + notchSpacing * i + notchSpacing / 2;
      if (i < notchCount) {
        path.lineTo(0, y + notchRadius);
        path.arcToPoint(
          Offset(0, y - notchRadius),
          radius: Radius.circular(notchRadius),
          clockwise: false,
        );
      }
    }
    
    path.lineTo(0, cornerRadius);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

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

  // Helper method để lấy icon theo index
  IconData _getServiceIcon(int index) {
    switch (index) {
      case 0:
        return Icons.event_seat; // Thuê rạp
      case 1:
        return Icons.campaign; // Quảng cáo
      case 2:
        return Icons.card_giftcard; // Quà tặng
      case 3:
        return Icons.groups; // Vé nhóm
      default:
        return Icons.local_activity;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Lập kế hoạch cùng TNT Cinema'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Carousel dịch vụ với Ticket Shape ---
            SizedBox(
              height: 200,
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
                  final bool isActive = index == _currentServiceIndex;
                  final List<Color> gradientColors = item['gradientColors'] ?? 
                      [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)];
                  
                  return AnimatedScale(
                    scale: isActive ? 1.0 : 0.9,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipPath(
                        clipper: TicketClipper(notchRadius: 8, notchCount: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.4),
                                blurRadius: isActive ? 15 : 8,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Decorative pattern
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Icon(
                                  Icons.local_activity,
                                  size: 100,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Icon dịch vụ
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getServiceIcon(index),
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Title
                                    Text(
                                      item['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Description
                                    Expanded(
                                      child: Text(
                                        item['description'],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    
                                    // Badge "Chi tiết"
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Chi tiết',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                            size: 12,
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
                      ),
                    ),
                  );
                },
              ),
            ),

            // Indicator dots
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.services.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentServiceIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentServiceIndex == index
                        ? (widget.services[index]['gradientColors']?[0] ?? AppTheme.primaryColor)
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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
                    'Tôi đồng ý cung cấp thông tin cho TNT Cinema để phục vụ nhu cầu đăng ký dịch vụ của tôi.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('GỬI'),
            ),
          ],
        ),
      ),
    );
  }
}
