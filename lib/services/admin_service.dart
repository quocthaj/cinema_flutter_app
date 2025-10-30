import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// 🔐 Service quản lý quyền admin
/// Cung cấp các chức năng kiểm tra quyền, promote/demote user, quản lý whitelist
class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================
  // 🔍 KIỂM TRA QUYỀN ADMIN
  // ============================================

  /// Check xem user hiện tại có phải admin không
  Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) return false;
      
      final userData = doc.data();
      return userData?['role'] == 'admin';
    } catch (e) {
      print('❌ Error checking admin status: $e');
      return false;
    }
  }

  /// Check xem một user cụ thể có phải admin không (bằng userId)
  Future<bool> isUserAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) return false;
      
      final userData = doc.data();
      return userData?['role'] == 'admin';
    } catch (e) {
      print('❌ Error checking user admin status: $e');
      return false;
    }
  }

  /// Stream để theo dõi admin status (realtime)
  Stream<bool> isAdminStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return false;
      final userData = doc.data();
      return userData?['role'] == 'admin';
    });
  }

  // ============================================
  // 👥 QUẢN LÝ USER & ROLE
  // ============================================

  /// Promote user lên admin
  Future<void> promoteToAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'admin',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User $userId đã được promote lên admin');
    } catch (e) {
      print('❌ Failed to promote user: $e');
      throw Exception('Failed to promote user: $e');
    }
  }

  /// Demote admin xuống user
  Future<void> demoteToUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'user',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User $userId đã được demote xuống user');
    } catch (e) {
      print('❌ Failed to demote user: $e');
      throw Exception('Failed to demote user: $e');
    }
  }

  /// Lấy danh sách TẤT CẢ users (realtime)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Lấy danh sách chỉ admins (realtime)
  Stream<List<UserModel>> getAdmins() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Xóa user (cẩn thận!)
  Future<void> deleteUser(String userId) async {
    try {
      // Chỉ xóa document trong Firestore, không xóa Firebase Auth account
      await _firestore.collection('users').doc(userId).delete();
      print('✅ Đã xóa user document $userId');
    } catch (e) {
      print('❌ Failed to delete user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  // ============================================
  // 📋 QUẢN LÝ ADMIN WHITELIST
  // ============================================

  /// Check email có trong whitelist không
  Future<bool> isInAdminWhitelist(String email) async {
    try {
      final doc = await _firestore
          .collection('config')
          .doc('admin_whitelist')
          .get();
      
      if (!doc.exists) return false;
      
      final List<dynamic> whitelist = doc.data()?['emails'] ?? [];
      return whitelist.contains(email.toLowerCase());
    } catch (e) {
      print('❌ Error checking whitelist: $e');
      return false;
    }
  }

  /// Lấy danh sách emails trong whitelist
  Future<List<String>> getAdminWhitelist() async {
    try {
      final doc = await _firestore
          .collection('config')
          .doc('admin_whitelist')
          .get();
      
      if (!doc.exists) return [];
      
      final List<dynamic> whitelist = doc.data()?['emails'] ?? [];
      return whitelist.map((e) => e.toString()).toList();
    } catch (e) {
      print('❌ Error getting whitelist: $e');
      return [];
    }
  }

  /// Thêm email vào whitelist
  Future<void> addEmailToWhitelist(String email) async {
    try {
      await _firestore.collection('config').doc('admin_whitelist').update({
        'emails': FieldValue.arrayUnion([email.toLowerCase()]),
      });
      print('✅ Đã thêm $email vào whitelist');
    } catch (e) {
      print('❌ Failed to add email to whitelist: $e');
      throw Exception('Failed to add email to whitelist: $e');
    }
  }

  /// Xóa email khỏi whitelist
  Future<void> removeEmailFromWhitelist(String email) async {
    try {
      await _firestore.collection('config').doc('admin_whitelist').update({
        'emails': FieldValue.arrayRemove([email.toLowerCase()]),
      });
      print('✅ Đã xóa $email khỏi whitelist');
    } catch (e) {
      print('❌ Failed to remove email from whitelist: $e');
      throw Exception('Failed to remove email from whitelist: $e');
    }
  }

  /// Setup admin whitelist lần đầu (chỉ chạy một lần)
  Future<void> setupAdminWhitelist(List<String> adminEmails) async {
    try {
      await _firestore.collection('config').doc('admin_whitelist').set({
        'emails': adminEmails.map((e) => e.toLowerCase()).toList(),
        'description': 'Danh sách email được tự động promote lên admin khi đăng ký',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Admin whitelist đã được tạo!');
    } catch (e) {
      print('❌ Failed to setup whitelist: $e');
      throw Exception('Failed to setup whitelist: $e');
    }
  }

  // ============================================
  // 🛠️ ADMIN UTILITIES
  // ============================================

  /// Promote user đầu tiên lên admin (setup ban đầu)
  Future<void> promoteFirstAdmin(String userId) async {
    try {
      await promoteToAdmin(userId);
      print('🎉 Admin đầu tiên đã được tạo! UID: $userId');
      print('📧 Hãy đăng xuất và đăng nhập lại để áp dụng quyền mới.');
    } catch (e) {
      print('❌ Error promoting first admin: $e');
      rethrow;
    }
  }

  /// Promote user bằng email
  Future<void> promoteByEmail(String email) async {
    try {
      // Tìm user bằng email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        throw Exception('❌ Không tìm thấy user với email: $email');
      }
      
      final userId = querySnapshot.docs.first.id;
      await promoteToAdmin(userId);
      print('✅ User $email đã được promote lên admin!');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Get admin statistics
  Future<Map<String, int>> getAdminStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final adminsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      
      return {
        'totalUsers': usersSnapshot.docs.length,
        'totalAdmins': adminsSnapshot.docs.length,
        'regularUsers': usersSnapshot.docs.length - adminsSnapshot.docs.length,
      };
    } catch (e) {
      print('❌ Error getting admin stats: $e');
      return {'totalUsers': 0, 'totalAdmins': 0, 'regularUsers': 0};
    }
  }
}
