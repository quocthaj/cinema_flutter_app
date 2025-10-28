// lib/services/seed/sync_result.dart

/// Kết quả của quá trình sync dữ liệu
class SyncResult {
  final int added;
  final int updated;
  final int deleted;
  final int unchanged;
  final List<String> errors;
  final List<String> addedIds;
  final List<String> updatedIds;
  final List<String> deletedIds;

  SyncResult({
    this.added = 0,
    this.updated = 0,
    this.deleted = 0,
    this.unchanged = 0,
    this.errors = const [],
    this.addedIds = const [],
    this.updatedIds = const [],
    this.deletedIds = const [],
  });

  bool get hasChanges => added > 0 || updated > 0 || deleted > 0;
  bool get hasErrors => errors.isNotEmpty;
  int get total => added + updated + deleted + unchanged;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Kết quả sync:');
    buffer.writeln('  ✅ Thêm mới: $added');
    buffer.writeln('  🔄 Cập nhật: $updated');
    buffer.writeln('  🗑️  Xóa: $deleted');
    buffer.writeln('  ⏭️  Không đổi: $unchanged');
    if (hasErrors) {
      buffer.writeln('  ❌ Lỗi: ${errors.length}');
    }
    return buffer.toString();
  }

  /// Merge nhiều kết quả sync lại với nhau
  static SyncResult merge(List<SyncResult> results) {
    return SyncResult(
      added: results.fold(0, (sum, r) => sum + r.added),
      updated: results.fold(0, (sum, r) => sum + r.updated),
      deleted: results.fold(0, (sum, r) => sum + r.deleted),
      unchanged: results.fold(0, (sum, r) => sum + r.unchanged),
      errors: results.expand((r) => r.errors).toList(),
      addedIds: results.expand((r) => r.addedIds).toList(),
      updatedIds: results.expand((r) => r.updatedIds).toList(),
      deletedIds: results.expand((r) => r.deletedIds).toList(),
    );
  }
}
