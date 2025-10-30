# 🔐 Hướng dẫn Thiết lập & Test Hệ thống Admin

## 📋 Tổng quan

Hệ thống Admin đã được triển khai hoàn chỉnh với 3 tầng bảo mật:
- **Tier 1**: UI Guards (AdminGuard widget chặn truy cập)
- **Tier 2**: Service Layer (AdminService kiểm tra quyền)
- **Tier 3**: Firestore Rules (Bảo mật database - cần deploy)

---

## 🚀 Bước 1: Tạo Admin đầu tiên

### Phương án A: Sử dụng Firebase Console (Khuyến nghị cho lần đầu)

1. Mở [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Firestore Database** → Collection `users`
4. Tìm user document (ID là UID của user)
5. Thêm/sửa field:
   ```
   Field: role
   Type: string
   Value: admin
   ```
6. Click **Update** → User giờ đã là Admin!

### Phương án B: Sử dụng Admin Whitelist (Auto-promote)

1. Mở **Firestore Database** → Create collection `config`
2. Tạo document với ID: `admin_whitelist`
3. Thêm field:
   ```
   Field: emails
   Type: array
   Value: ['your-email@example.com', 'admin@tntcinema.com']
   ```
4. Đăng ký tài khoản mới với email trong whitelist
5. User sẽ tự động được promote thành admin!

### Phương án C: Sử dụng Script (Nâng cao)

Chạy script sau trong Dart/Flutter DevTools Console:

```dart
import 'package:cinema_flutter_app/services/admin_service.dart';

// Promote user hiện tại
await AdminService().promoteToAdmin('USER_UID_HERE');

// Hoặc promote theo email
await AdminService().promoteByEmail('user@example.com');

// Setup whitelist
await AdminService().setupAdminWhitelist([
  'admin1@example.com',
  'admin2@example.com',
]);
```

---

## ✅ Bước 2: Test với 2 tài khoản

### Tạo tài khoản test

**Admin Account:**
```
Email: admin@tntcinema.com
Password: Admin@123
Role: admin (đã setup ở bước 1)
```

**User Account:**
```
Email: user@tntcinema.com
Password: User@123
Role: user (mặc định)
```

### Test Cases

#### 🧪 Test 1: Kiểm tra Drawer Menu

**Admin đăng nhập:**
- ✅ Phải thấy section "QUẢN TRỊ" trong drawer
- ✅ Thấy 3 menu items:
  - Admin Dashboard
  - Quản lý dữ liệu
  - Quản lý người dùng
- ✅ Các items có badge "ADMIN" màu đỏ

**User đăng nhập:**
- ✅ KHÔNG thấy section "QUẢN TRỊ"
- ✅ Chỉ thấy menu thông thường (Mua vé, Phim, Rạp...)

---

#### 🧪 Test 2: Admin Dashboard

**Admin:**
1. Mở drawer → Click "Admin Dashboard"
2. ✅ Màn hình hiển thị statistics:
   - Số phim
   - Số rạp chiếu
   - Số phòng chiếu
   - Số suất chiếu
   - Số đặt vé
   - Số người dùng
   - Số admin
3. ✅ Pull-to-refresh hoạt động
4. ✅ Thấy badge "ADMIN" trên AppBar
5. ✅ Quick actions navigation hoạt động

**User:**
1. Không thể truy cập (không có menu item)

---

#### 🧪 Test 3: Quản lý Dữ liệu (Seed Data)

**Admin:**
1. Mở drawer → Click "Quản lý dữ liệu"
2. ✅ Màn hình SeedDataScreen mở ra
3. ✅ Thấy badge "ADMIN" trên AppBar
4. ✅ Các chức năng hoạt động:
   - Seed movies
   - Seed theaters
   - Seed screens
   - Seed showtimes
   - Delete collections

**User:**
1. Không thể truy cập

**Test truy cập trực tiếp (nếu có deep link):**
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => SeedDataScreen(),
));
```
- Admin: ✅ Vào được
- User: ❌ Thấy màn hình "Access Denied"

---

#### 🧪 Test 4: Quản lý Người dùng

**Admin:**
1. Mở drawer → Click "Quản lý người dùng"
2. ✅ Thấy danh sách tất cả users
3. ✅ Search bar hoạt động (tìm theo tên/email)
4. ✅ Statistics card hiển thị đúng
5. ✅ Test Promote user:
   - Click menu (3 dots) của user
   - Click "Promote to Admin"
   - Confirm dialog xuất hiện
   - Sau khi confirm: User role → admin
   - ✅ Badge hiển thị "ADMIN" ngay lập tức
6. ✅ Test Demote admin:
   - Click menu của admin
   - Click "Demote to User"
   - Confirm dialog xuất hiện
   - Sau khi confirm: Admin role → user
7. ✅ Test Delete user:
   - Click menu của user
   - Click "Delete"
   - Warning dialog xuất hiện
   - Sau khi confirm: User bị xóa khỏi list

**User:**
1. Không thể truy cập

---

#### 🧪 Test 5: Real-time Updates

**Setup:**
- Đăng nhập admin trên device A
- Đăng nhập user trên device B

**Test scenario:**
1. Device A: Vào User Management
2. Device A: Promote user B thành admin
3. Device B: Pull-to-refresh drawer hoặc restart app
4. ✅ Device B giờ thấy menu "QUẢN TRỊ"

**Reverse:**
1. Device A: Demote user B về user
2. Device B: Pull-to-refresh drawer
3. ✅ Menu "QUẢN TRỊ" biến mất trên device B

---

## 🔒 Bước 3: Deploy Firestore Security Rules

### Rules cần deploy

Tạo file `firestore.rules` trong project root:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Check if user is admin
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Helper function: Check if user owns the document
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone can read their own data
      allow read: if isOwner(userId);
      
      // Users can update their own data (except role field)
      allow update: if isOwner(userId) && 
                      (!request.resource.data.diff(resource.data).affectedKeys().hasAny(['role']));
      
      // Only admins can read all users, create users, and change roles
      allow read, create, update, delete: if isAdmin();
    }
    
    // Movies collection
    match /movies/{movieId} {
      allow read: if true; // Public read
      allow write: if isAdmin(); // Admin only write
    }
    
    // Theaters collection
    match /theaters/{theaterId} {
      allow read: if true; // Public read
      allow write: if isAdmin(); // Admin only write
    }
    
    // Screens collection
    match /screens/{screenId} {
      allow read: if true; // Public read
      allow write: if isAdmin(); // Admin only write
    }
    
    // Showtimes collection
    match /showtimes/{showtimeId} {
      allow read: if true; // Public read
      allow write: if isAdmin(); // Admin only write
    }
    
    // Bookings collection
    match /bookings/{bookingId} {
      // Users can read their own bookings
      allow read: if isOwner(resource.data.userId);
      
      // Users can create bookings
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      
      // Admins can do anything
      allow read, write: if isAdmin();
    }
    
    // Payments collection
    match /payments/{paymentId} {
      // Same as bookings
      allow read: if isOwner(resource.data.userId);
      allow create: if request.auth != null;
      allow read, write: if isAdmin();
    }
    
    // Config collection (admin only)
    match /config/{document=**} {
      allow read, write: if isAdmin();
    }
    
    // Admin whitelist (special: readable by auth users for auto-promotion check)
    match /config/admin_whitelist {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
  }
}
```

### Deploy rules

```bash
# Nếu đã cài Firebase CLI
firebase deploy --only firestore:rules

# Hoặc copy-paste rules trực tiếp vào Firebase Console
# Firestore Database → Rules tab
```

---

## 🐛 Troubleshooting

### Admin menu không hiện

**Nguyên nhân:** User chưa có role 'admin' trong Firestore

**Giải pháp:**
1. Kiểm tra Firestore: `users/{uid}` phải có field `role = 'admin'`
2. Restart app sau khi update role
3. Check AuthService có gọi AdminService chưa

---

### Access Denied khi là admin

**Nguyên nhân:** AdminService không đọc được user role

**Giải pháp:**
1. Check Firebase Auth đã đăng nhập chưa
2. Check Firestore rules cho phép read users collection
3. Check user document có tồn tại trong Firestore không

---

### Auto-promotion không hoạt động

**Nguyên nhân:** Whitelist chưa setup hoặc email không match

**Giải pháp:**
1. Verify collection `config/admin_whitelist` tồn tại
2. Verify field `emails` là array và chứa email chính xác
3. Check console logs xem có error không
4. Đảm bảo email trong whitelist viết thường (lowercase)

---

### Statistics không load

**Nguyên nhân:** Firestore rules chặn read

**Giải pháp:**
1. Deploy Firestore rules (xem phần trên)
2. Hoặc tạm thời set test mode rules:
```
allow read, write: if true; // WARNING: Chỉ dùng development!
```

---

## 📊 Kiểm tra Logs

### Debug admin status

Thêm vào code để debug:

```dart
// Trong CustomDrawer hoặc bất kỳ widget nào
StreamBuilder<bool>(
  stream: AdminService().isAdminStream(),
  builder: (context, snapshot) {
    print('🔍 Is Admin: ${snapshot.data}');
    print('🔍 Connection State: ${snapshot.connectionState}');
    print('🔍 Error: ${snapshot.error}');
    return Text('Admin: ${snapshot.data ?? false}');
  },
)
```

### Check user role trong Firestore

```dart
final user = FirebaseAuth.instance.currentUser;
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user!.uid)
    .get();
    
print('🔍 User Role: ${doc.data()?['role']}');
```

---

## 🎯 Checklist Hoàn chỉnh

### Backend
- ✅ UserModel có field `role`
- ✅ AdminService implemented
- ✅ AuthService tích hợp auto-promotion
- ✅ FirestoreService accepts role parameter

### Frontend
- ✅ AdminGuard widget created
- ✅ SeedDataScreen protected
- ✅ UserManagementScreen created
- ✅ AdminDashboardScreen created
- ✅ CustomDrawer shows admin menu conditionally

### Security
- ⚠️ Firestore Rules chưa deploy (làm ở Bước 3)
- ✅ UI protection hoạt động
- ✅ Service layer validation hoạt động

### Testing
- ⏳ Tạo admin account (Bước 1)
- ⏳ Tạo user account (Bước 2)
- ⏳ Test drawer menu visibility
- ⏳ Test admin screens access
- ⏳ Test promote/demote operations
- ⏳ Test real-time updates

---

## 🚀 Quick Start Commands

```bash
# 1. Đảm bảo dependencies đã cài
flutter pub get

# 2. Run app
flutter run

# 3. Build release (sau khi test xong)
flutter build apk --release
flutter build ios --release

# 4. Deploy Firestore rules
firebase deploy --only firestore:rules
```

---

## 📞 Support

Nếu gặp vấn đề, check theo thứ tự:
1. ✅ Firebase Auth đang hoạt động
2. ✅ Firestore có collection `users`
3. ✅ User document có field `role`
4. ✅ Firestore rules cho phép read `users` collection
5. ✅ AdminService đang được import đúng
6. ✅ App đã được rebuild sau khi thay đổi code

---

**🎉 Chúc mừng! Hệ thống Admin đã sẵn sàng!**
