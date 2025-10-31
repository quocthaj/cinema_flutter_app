import 'package:flutter/material.dart';
import '../../services/seed/hardcoded_seed_service.dart';
import '../../services/seed/sync_seed_service.dart';
import 'admin_guard.dart'; // 🔥 ADMIN: Import AdminGuard

/// Màn hình Admin để quản lý seed data
/// 🔐 CHỈ ADMIN MỚI TRUY CẬP ĐƯỢC
class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  final _seedService = HardcodedSeedService();
  final _syncService = SyncSeedService();
  bool _isLoading = false;
  String _statusMessage = '';
  double _progress = 0.0;

  /// Thêm tất cả dữ liệu mẫu (Hardcoded)
  Future<void> _seedAllData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang thêm dữ liệu cứng...';
      _progress = 0.0;
    });

    // Set up progress callback
    _seedService.onProgress = (progress, message) {
      setState(() {
        _progress = progress;
        _statusMessage = message;
      });
    };

    try {
      await _seedService.seedAll();
      setState(() {
        _progress = 1.0;
        _statusMessage = '✅ Thêm dữ liệu thành công!\n'
            '  📽️  15 phim\n'
            '  🎭 11 rạp chiếu (4 HN + 4 HCM + 3 ĐN)\n'
            '  🪑 44 phòng chiếu (11 × 4)\n'
            '  ⏰ ~1,848 suất chiếu (264/ngày × 7 ngày)\n'
            '  ✅ KHÔNG TRÙNG GIỜ - Mỗi phòng mỗi giờ chỉ 1 suất';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi: $e';
        _progress = 0.0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Đồng bộ TẤT CẢ dữ liệu (SyncSeedService - Recommended)
  Future<void> _syncAllData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang đồng bộ tất cả dữ liệu...';
      _progress = 0.0;
    });

    // Set up progress callback
    _syncService.onProgress = (progress, message) {
      setState(() {
        _progress = progress;
        _statusMessage = message;
      });
    };

    try {
      final report = await _syncService.syncAll();

      setState(() {
        _progress = 1.0;
        _statusMessage = '✅ Đồng bộ hoàn tất!\n\n'
            '📰 Tin tức: +${report.news?.inserted ?? 0} | ~${report.news?.updated ?? 0}\n'
            '🎭 Rạp: +${report.theaters?.inserted ?? 0} | ~${report.theaters?.updated ?? 0}\n'
            '📽️ Phim: +${report.movies?.inserted ?? 0} | ~${report.movies?.updated ?? 0}\n'
            '🪑 Phòng: +${report.screens?.inserted ?? 0} | ~${report.screens?.updated ?? 0}\n'
            '⏰ Suất chiếu: +${report.showtimes?.inserted ?? 0} | ~${report.showtimes?.updated ?? 0}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi: $e';
        _progress = 0.0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Đồng bộ chỉ TIN TỨC
  Future<void> _syncNewsOnly() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang đồng bộ tin tức...';
      _progress = 0.0;
    });

    try {
      final result = await _syncService.syncNews();
      setState(() {
        _progress = 1.0;
        _statusMessage = '✅ Đồng bộ tin tức thành công!\n'
            '  ➕ Đã thêm: ${result.inserted}\n'
            '  📝 Đã cập nhật: ${result.updated}\n'
            '  ✓ Không đổi: ${result.unchanged}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi: $e';
        _progress = 0.0;
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
      _progress = 0.0;
    });

    // Set up progress callback
    _seedService.onProgress = (progress, message) {
      setState(() {
        _progress = progress;
        _statusMessage = message;
      });
    };

    try {
      await _seedService.clearAll();
      setState(() {
        _statusMessage = '✅ Xóa dữ liệu thành công!';
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi: $e';
        _progress = 0.0;
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
    // 🔥 ADMIN: Wrap toàn bộ screen với AdminGuard
    return AdminGuard(
      screenName: 'Quản lý dữ liệu',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🔧 Admin - Quản lý Data'),
          backgroundColor: Colors.deepPurple,
          // 🔥 ADMIN: Hiển thị badge
          actions: const [
            AdminBadge(),
          ],
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
            
            // 🟢 SECTION: ĐỒNG BỘ DỮ LIỆU (RECOMMENDED)
            Text(
              '🔄 ĐỒNG BỘ DỮ LIỆU (Khuyến nghị)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 12),

            // Nút Sync All Data
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _syncAllData,
              icon: const Icon(Icons.sync),
              label: const Text(
                'Đồng bộ TẤT CẢ dữ liệu',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Nút Sync News Only
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _syncNewsOnly,
              icon: const Icon(Icons.newspaper),
              label: const Text(
                '📰 Đồng bộ riêng TIN TỨC',
                style: TextStyle(fontSize: 15),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade700, width: 2),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 24),
            
            // 🟢 SECTION: THÊM DỮ LIỆU (LEGACY)
            Text(
              '📥 THÊM DỮ LIỆU (Legacy)',
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
                'Thêm tất cả dữ liệu cứng',
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
                _buildClearCollectionButton('news', 'Tin tức', Icons.newspaper),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _statusMessage.contains('✅')
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_isLoading && _progress > 0) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Loading indicator
            if (_isLoading && _progress == 0)
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
                      '🔄 ĐỒNG BỘ DỮ LIỆU (Recommended):\n'
                      '• "Đồng bộ TẤT CẢ": Sync toàn bộ (News + Rạp + Phim + Suất chiếu)\n'
                      '  - Tự động thêm/cập nhật dữ liệu mới từ seed\n'
                      '  - KHÔNG XÓA booking/payment đã có\n'
                      '  - An toàn chạy nhiều lần\n'
                      '• "Đồng bộ riêng TIN TỨC": Chỉ sync 15 tin tức/khuyến mãi\n\n'
                      '📥 THÊM DỮ LIỆU (Legacy):\n'
                      '• Nhấn "Thêm tất cả dữ liệu mẫu" để tạo:\n'
                      '  - 15 phim mẫu\n'
                      '  - 18 rạp chiếu\n'
                      '  - 72 phòng chiếu\n'
                      '  - Lịch chiếu trong 7 ngày\n\n'
                      '🗑️ XÓA DỮ LIỆU:\n'
                      '• "XÓA TẤT CẢ": Xóa toàn bộ data (bookings, payments, showtimes, screens, theaters, movies)\n'
                      '• Xóa từng collection: Chỉ xóa collection cụ thể\n\n'
                      '💡 TIPS:\n'
                      '• LẦN ĐẦU: Dùng "Đồng bộ TẤT CẢ" để tạo đầy đủ dữ liệu\n'
                      '• Nếu muốn thêm tin mới: Dùng "Đồng bộ riêng TIN TỨC"\n'
                      '• Nếu app bị lag/đen → Xóa bookings + payments trước\n'
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
    ),
    ); // 🔥 ADMIN: Đóng AdminGuard
  }
}
