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

  /// Xóa một collection cụ thể
  Future<void> _clearCollection(String collectionName, String displayName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xác nhận'),
        content: Text('Bạn có muốn xóa collection "$displayName"?'),
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
      _statusMessage = 'Đang xóa $displayName...';
    });

    try {
      await _seedService.clearCollection(collectionName);
      setState(() {
        _statusMessage = '✅ Đã xóa $displayName thành công!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi khi xóa $displayName: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Build button xóa một collection
  Widget _buildClearCollectionButton(String collectionName, String displayName, IconData icon) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : () => _clearCollection(collectionName, displayName),
      icon: Icon(icon, size: 18),
      label: Text(displayName),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Admin - Quản lý Data'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
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
                      'Màn hình này chỉ dùng để thêm/xóa dữ liệu mẫu. '
                      'Không nên sử dụng trong production.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 🟢 SECTION: THÊM DỮ LIỆU
            Text(
              '📥 THÊM DỮ LIỆU',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 12),

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

            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 24),

            // 🔴 SECTION: XÓA DỮ LIỆU
            Text(
              '🗑️ XÓA DỮ LIỆU',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 12),

            // Nút Clear All Data (NGUY HIỂM - ĐỎ)
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearAllData,
              icon: const Icon(Icons.delete_forever),
              label: const Text(
                '⚠️ XÓA TẤT CẢ DỮ LIỆU',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 2),
              ),
            ),

            const SizedBox(height: 16),

            // Tiêu đề xóa từng collection
            Text(
              'Xóa từng collection:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),

            // Buttons xóa từng collection
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildClearCollectionButton('movies', 'Phim', Icons.movie),
                _buildClearCollectionButton('theaters', 'Rạp', Icons.theater_comedy),
                _buildClearCollectionButton('screens', 'Phòng', Icons.meeting_room),
                _buildClearCollectionButton('showtimes', 'Lịch chiếu', Icons.schedule),
                _buildClearCollectionButton('bookings', 'Đặt vé', Icons.confirmation_number),
                _buildClearCollectionButton('payments', 'Thanh toán', Icons.payment),
              ],
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

            const SizedBox(height: 24),

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
                          'Hướng dẫn sử dụng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '📥 THÊM DỮ LIỆU:\n'
                      '• Nhấn "Thêm tất cả dữ liệu mẫu" để tạo:\n'
                      '  - 15 phim mẫu\n'
                      '  - 18 rạp chiếu\n'
                      '  - 72 phòng chiếu\n'
                      '  - Lịch chiếu trong 7 ngày\n\n'
                      '🗑️ XÓA DỮ LIỆU:\n'
                      '• "XÓA TẤT CẢ": Xóa toàn bộ data (bookings, payments, showtimes, screens, theaters, movies)\n'
                      '• Xóa từng collection: Chỉ xóa collection cụ thể\n\n'
                      '💡 TIPS:\n'
                      '• Nếu app bị lag/đen → Xóa bookings + payments trước\n'
                      '• Nếu muốn làm lại hoàn toàn → Xóa tất cả rồi seed lại\n'
                      '• Check Firebase Console để verify',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
