# 🚀 Admin System - Quick Reference

## 🎯 TÓM TẮT 1 PHÚT

**Hệ thống admin đã HOÀN THÀNH với:**
- ✅ 3 màn hình admin (Dashboard, Seed Data, User Management)
- ✅ AdminService với 15+ methods
- ✅ AdminGuard bảo vệ routes
- ✅ Drawer menu hiện admin section khi user là admin
- ✅ Real-time permission checking
- ✅ Auto-promotion via whitelist
- ✅ Firestore rules template

---

## ⚡ QUICK START (3 BƯỚC)

### 1️⃣ Tạo Admin đầu tiên
```
Firebase Console → Firestore → users/{user-uid}
Thêm field: role = "admin"
```

### 2️⃣ Test App
```bash
flutter run
```

**Kiểm tra:**
- Admin: Thấy menu "QUẢN TRỊ" trong drawer ✅
- User: KHÔNG thấy menu "QUẢN TRỊ" ✅

### 3️⃣ Deploy Security Rules (SAU KHI TEST)
```bash
firebase deploy --only firestore:rules
```
Rules template: `docs/ADMIN_SETUP_GUIDE.md` Bước 3

---

## 🗂️ CÁC FILES QUAN TRỌNG

### Services
```
lib/services/admin_service.dart          // 15+ methods quản lý admin
```

### Admin Screens
```
lib/screens/admin/admin_dashboard_screen.dart    // Tổng quan stats
lib/screens/admin/admin_guard.dart               // Widget bảo vệ route
lib/screens/admin/user_management_screen.dart    // Quản lý users
lib/screens/admin/seed_data_screen.dart          // Quản lý dữ liệu (đã có)
```

### Navigation
```
lib/screens/home/custom_drawer.dart      // Drawer menu với admin section
```

### Models
```
lib/models/user_model.dart               // UserModel.role + isAdmin getter
```

### Documentation
```
docs/ADMIN_SETUP_GUIDE.md               // Hướng dẫn setup chi tiết
docs/ADMIN_SYSTEM_COMPLETE.md           // Technical overview
```

---

## 🔧 CODE SNIPPETS HAY DÙNG

### Kiểm tra admin status
```dart
// One-time check
final isAdmin = await AdminService().isAdmin();

// Real-time stream
StreamBuilder<bool>(
  stream: AdminService().isAdminStream(),
  builder: (context, snapshot) {
    return snapshot.data == true ? AdminWidget() : UserWidget();
  },
)
```

### Bảo vệ màn hình admin
```dart
class MyAdminScreen extends StatelessWidget {
  @override
  Widget build(context) => AdminGuard(
    screenName: 'My Feature',
    child: Scaffold(
      appBar: AppBar(
        title: Text('Admin Only'),
        actions: [AdminBadge()],
      ),
      body: MyContent(),
    ),
  );
}
```

### Promote/Demote user
```dart
// Promote
await AdminService().promoteToAdmin(userId);

// Demote
await AdminService().demoteToUser(userId);

// Delete
await AdminService().deleteUser(userId);
```

### Setup whitelist
```dart
await AdminService().setupAdminWhitelist([
  'admin1@example.com',
  'admin2@example.com',
]);
```

---

## 🎨 UI COMPONENTS

### AdminGuard Widget
```dart
AdminGuard(
  screenName: 'Tên màn hình',
  child: YourProtectedScreen(),
)
```
- Loading state khi check permission
- Access Denied screen nếu không phải admin
- Pass through child nếu là admin

### AdminBadge Widget
```dart
AppBar(
  title: Text('Admin Screen'),
  actions: [AdminBadge()],
)
```
- Hiện badge "ADMIN" màu đỏ
- Icon admin_panel_settings
- Auto-sized

---

## 🎯 ADMIN SERVICE METHODS

### Permission Checks
```dart
isAdmin()                    // Future<bool> - Check current user
isUserAdmin(userId)          // Future<bool> - Check specific user
isAdminStream()              // Stream<bool> - Real-time admin status
```

### User Management
```dart
getAllUsers()                // Stream<List<UserModel>> - All users
getAdmins()                  // Stream<List<UserModel>> - Only admins
promoteToAdmin(userId)       // Future<void> - Elevate to admin
demoteToUser(userId)         // Future<void> - Downgrade to user
deleteUser(userId)           // Future<void> - Delete from Firestore
```

### Whitelist Management
```dart
isInAdminWhitelist(email)           // Future<bool> - Check membership
getAdminWhitelist()                 // Future<List<String>> - All emails
addEmailToWhitelist(email)          // Future<void> - Add email
removeEmailFromWhitelist(email)     // Future<void> - Remove email
setupAdminWhitelist(emails)         // Future<void> - Initial setup
```

### Utilities
```dart
getAdminStats()              // Future<Map<String, int>> - User counts
promoteByEmail(email)        // Future<void> - Promote by email lookup
promoteFirstAdmin(userId)    // Future<void> - Setup utility
```

---

## 📊 ADMIN SCREENS

### 1. Admin Dashboard
**Route:** `Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboardScreen()))`

**Features:**
- 📈 Statistics cards (movies, theaters, screens, showtimes, bookings, users, admins)
- ⚡ Quick actions (navigate to Seed Data, User Management)
- 🔄 Pull-to-refresh

### 2. User Management
**Route:** `Navigator.push(context, MaterialPageRoute(builder: (_) => UserManagementScreen()))`

**Features:**
- 🔍 Search bar (tìm theo tên/email)
- 📊 Statistics (total users, admins, regular users)
- 📋 Real-time user list
- 🎯 Actions: Promote, Demote, Delete (có confirmation)

### 3. Seed Data Management
**Route:** `Navigator.push(context, MaterialPageRoute(builder: (_) => SeedDataScreen()))`

**Features:**
- 🌱 Seed movies, theaters, screens, showtimes
- 🗑️ Delete collections
- 📦 Backup/restore (nếu có)

---

## 🔐 FIRESTORE COLLECTIONS

### users/{userId}
```javascript
{
  email: string,
  displayName: string,
  role: 'admin' | 'user',  // ← KEY FIELD
  createdAt: timestamp,
  photoUrl: string (optional)
}
```

### config/admin_whitelist
```javascript
{
  emails: ['admin1@example.com', 'admin2@example.com']
}
```

---

## 🚨 TROUBLESHOOTING NHANH

| Vấn đề | Giải pháp |
|--------|-----------|
| Admin menu không hiện | Check `users/{uid}.role = 'admin'` trong Firestore |
| Access Denied cho admin | Check Firestore rules allow read users collection |
| Auto-promotion không hoạt động | Check `config/admin_whitelist.emails` array exists |
| Statistics không load | Deploy Firestore rules hoặc dùng test mode |
| App crash khi mở admin screen | Check Firebase Auth đã đăng nhập chưa |

---

## 📱 NAVIGATION STRUCTURE

```
CustomDrawer
├── Regular Menu Items
│   ├── Mua vé
│   ├── Phim
│   ├── Rạp
│   ├── Khuyến mãi
│   ├── Quà tặng
│   └── Liên hệ
│
└── QUẢN TRỊ Section (chỉ admin thấy)
    ├── Admin Dashboard      → AdminDashboardScreen
    ├── Quản lý dữ liệu      → SeedDataScreen
    └── Quản lý người dùng   → UserManagementScreen
```

---

## 🎓 BEST PRACTICES

### ✅ DO
- Luôn wrap admin screens với `AdminGuard`
- Dùng `isAdminStream()` cho real-time checks
- Show confirmation dialogs cho destructive actions
- Add `AdminBadge()` vào AppBar của admin screens
- Check `isAdmin()` trước khi gọi admin operations

### ❌ DON'T
- Không skip AdminGuard (bypass UI protection)
- Không hardcode admin UIDs trong code
- Không expose admin APIs qua public endpoints
- Không skip confirmation dialogs
- Không quên deploy Firestore rules

---

## 🔗 LINKS NHANH

- **Setup Guide:** `docs/ADMIN_SETUP_GUIDE.md`
- **Technical Docs:** `docs/ADMIN_SYSTEM_COMPLETE.md`
- **Firebase Console:** https://console.firebase.google.com/
- **Firestore Rules:** `firebase.rules` (cần tạo từ template)

---

## 📞 SUPPORT FLOW

```
Gặp vấn đề?
    │
    ├─> Check Troubleshooting section (trên)
    │
    ├─> Check ADMIN_SETUP_GUIDE.md
    │
    ├─> Check Firebase Console logs
    │
    ├─> Check Flutter logs: `flutter logs`
    │
    └─> Check Firestore Rules: Firebase Console → Rules tab
```

---

## ✅ DEPLOYMENT CHECKLIST

```
□ All code compiles without errors
□ Admin account created (Bước 1)
□ Test với admin account (thấy menu QUẢN TRỊ)
□ Test với user account (không thấy menu QUẢN TRỊ)
□ Test promote/demote operations
□ Firestore rules deployed
□ Test rules in production
□ Monitor Firebase Console
□ Document admin credentials
```

---

**📌 SAVE THIS FILE** - Reference nhanh khi cần!

*Last updated: 2024*  
*Version: 1.0.0*
