import 'package:flutter/material.dart';
import '../../services/seed_data_service.dart';

/// Màn hình Admin để quản lý seed data
/// Chỉ dùng trong quá trình development
class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  final _seedService = SeedDataService();
  bool _isLoading = false;
  String _statusMessage = '';

  /// Thêm tất cả dữ liệu mẫu
  Future<void> _seedAllData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang thêm dữ liệu...';
    });

    try {
      await _seedService.seedAllData();
      setState(() {
        _statusMessage = '✅ Thêm dữ liệu thành công!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Xóa tất cả dữ liệu
  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Cảnh báo'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa TẤT CẢ dữ liệu?\n'
          'Hành động này không thể hoàn tác!'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang xóa dữ liệu...';
    });

    try {
      await _seedService.clearAllData();
      setState(() {
        _statusMessage = '✅ Xóa dữ liệu thành công!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Admin - Seed Data'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thông báo cảnh báo
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Chế độ Development',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Màn hình này chỉ dùng để thêm dữ liệu mẫu. '
                      'Không nên sử dụng trong production.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nút Seed All Data
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _seedAllData,
              icon: const Icon(Icons.upload),
              label: const Text(
                'Thêm tất cả dữ liệu mẫu',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Nút Clear All Data
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearAllData,
              icon: const Icon(Icons.delete_forever),
              label: const Text(
                'Xóa tất cả dữ liệu',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),

            const SizedBox(height: 24),

            // Status message
            if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.contains('✅') 
                    ? Colors.green.shade50 
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains('✅')
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            const Spacer(),

            // Hướng dẫn
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Hướng dẫn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Nhấn "Thêm tất cả dữ liệu mẫu" để tạo:\n'
                      '   • 5 phim\n'
                      '   • 4 rạp chiếu\n'
                      '   • 12 phòng chiếu\n'
                      '   • Lịch chiếu trong 7 ngày\n\n'
                      '2. Kiểm tra kết quả tại Firebase Console\n\n'
                      '3. Nếu cần làm lại, xóa dữ liệu và seed lại',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
