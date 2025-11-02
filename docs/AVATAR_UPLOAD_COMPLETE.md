# 📸 Avatar Upload Feature - Implementation Complete

## ✅ Đã Triển Khai

### 1. **Dependencies Đã Thêm** (`pubspec.yaml`)
```yaml
firebase_storage: ^13.0.3    # Upload ảnh lên Firebase Storage
image_picker: ^1.0.7         # Chọn ảnh từ gallery/camera
image_cropper: ^5.0.1        # Crop ảnh thành hình tròn
path_provider: ^2.1.2        # Xử lý file paths
```

### 2. **Service Mới: `avatar_service.dart`**
Chức năng:
- ✅ `pickImageFromGallery()` - Chọn ảnh từ thư viện
- ✅ `pickImageFromCamera()` - Chụp ảnh mới
- ✅ `cropImage()` - Crop ảnh thành hình vuông/tròn
- ✅ `uploadAvatar()` - Upload lên Firebase Storage + update Firestore
- ✅ `deleteAvatar()` - Xóa avatar hiện tại
- ✅ `_deleteOldAvatar()` - Tự động xóa ảnh cũ khi upload ảnh mới

### 3. **UI Update: `member_info_screen.dart`**
**Thêm chức năng:**
- ✅ Icon camera button khi ở chế độ edit
- ✅ Bottom sheet chọn nguồn ảnh (Gallery/Camera/Delete)
- ✅ Progress indicator khi đang upload
- ✅ Success/Error notifications
- ✅ Confirmation dialog khi xóa avatar

**Flow người dùng:**
```
1. Click nút "Sửa" → Chế độ edit
2. Click icon camera trên avatar
3. Chọn:
   - "Chọn từ thư viện" → Gallery
   - "Chụp ảnh mới" → Camera
   - "Xóa ảnh đại diện" → Delete (nếu có avatar)
4. Crop ảnh (tự động)
5. Upload lên Firebase (tự động)
6. Thông báo thành công
7. Avatar cập nhật ngay lập tức
```

### 4. **Permissions Đã Cấu Hình**

**Android** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

**iOS** (`Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Cho phép sử dụng camera để chụp ảnh đại diện</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cho phép truy cập thư viện ảnh để chọn ảnh đại diện</string>
```

---

## 🔥 Firebase Storage Structure

```
avatars/
  ├── avatar_USER_UID_1234567890.jpg
  ├── avatar_USER_UID_9876543210.jpg
  └── ...
```

**Naming format:** `avatar_{userId}_{timestamp}.jpg`

---

## 🎯 Cách Sử Dụng

### Người dùng cuối:
1. Vào **Thông tin thành viên**
2. Click nút **Sửa** (góc trên bên phải)
3. Click icon **camera** trên avatar
4. Chọn ảnh từ gallery hoặc chụp ảnh mới
5. Crop ảnh (adjust khung crop nếu cần)
6. Click ✅ để xác nhận
7. Chờ upload (loading indicator)
8. Thấy thông báo "✅ Cập nhật ảnh đại diện thành công!"
9. Avatar mới hiển thị ngay lập tức

### Xóa avatar:
1. Vào **Thông tin thành viên** → **Sửa**
2. Click icon camera → Chọn **"Xóa ảnh đại diện"**
3. Confirm trong dialog
4. Avatar reset về icon mặc định

---

## 🧪 Testing Checklist

### ✅ Chức năng cần test:

**Gallery Upload:**
- [ ] Click camera icon → Chọn "Chọn từ thư viện"
- [ ] Chọn ảnh từ gallery
- [ ] Crop ảnh thành công
- [ ] Upload thành công
- [ ] Avatar hiển thị ảnh mới
- [ ] Ảnh cũ bị xóa khỏi Storage (check Firebase Console)

**Camera Upload:**
- [ ] Click camera icon → Chọn "Chụp ảnh mới"
- [ ] Chụp ảnh mới
- [ ] Crop ảnh thành công
- [ ] Upload thành công
- [ ] Avatar hiển thị ảnh mới

**Delete Avatar:**
- [ ] Click camera icon → Chọn "Xóa ảnh đại diện"
- [ ] Confirm dialog xuất hiện
- [ ] Click "Xóa"
- [ ] Avatar reset về icon mặc định
- [ ] Ảnh bị xóa khỏi Storage
- [ ] Firestore `photoUrl` = null

**Edge Cases:**
- [ ] Cancel crop → Không upload gì
- [ ] Cancel camera → Không làm gì
- [ ] Không có permission → Show system permission dialog
- [ ] Upload lỗi (no internet) → Show error message
- [ ] Upload ảnh rất lớn → Resize tự động (max 1024x1024)

**Firestore & Auth Sync:**
- [ ] Check Firestore `users/{uid}.photoUrl` updated
- [ ] Check Firebase Auth profile photoURL updated
- [ ] Ảnh cũ tự động xóa khi upload ảnh mới
- [ ] Không xóa Google OAuth avatar (chỉ xóa Firebase Storage avatars)

---

## 🔒 Security Rules (Firebase)

### Storage Rules (cần deploy):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Avatars folder
    match /avatars/{fileName} {
      // Cho phép read public (để hiển thị avatar)
      allow read: if true;
      
      // Chỉ cho phép user authenticated upload avatar của chính họ
      allow write: if request.auth != null 
                   && fileName.matches('avatar_' + request.auth.uid + '_.*');
      
      // Chỉ cho phép user xóa avatar của chính họ
      allow delete: if request.auth != null 
                    && fileName.matches('avatar_' + request.auth.uid + '_.*');
    }
  }
}
```

**Deploy rules:**
```bash
firebase deploy --only storage
```

### Firestore Rules (đã có):
```javascript
// users/{userId}
allow update: if isOwner(userId) || isAdmin();
```

---

## 🚀 Next Steps (Optional Enhancements)

### Phase 2 - Advanced Features:
1. **Image Compression:**
   - Thêm `flutter_image_compress` package
   - Compress ảnh trước khi upload (giảm storage cost)

2. **Multiple Image Formats:**
   - Support PNG, JPEG, WebP
   - Convert sang JPEG để tiết kiệm dung lượng

3. **Avatar Templates:**
   - Cho phép chọn avatar mặc định từ template
   - Không cần upload nếu chọn template

4. **Progress Indicator:**
   - Hiện % upload progress
   - Cancel upload mid-way

5. **Image Filters:**
   - Thêm filters (black/white, blur, etc.)
   - Adjust brightness/contrast

---

## 🐛 Troubleshooting

### Lỗi: "Permission denied"
**Nguyên nhân:** App chưa có permission camera/gallery  
**Giải pháp:**
1. Vào Settings → App → Cinema App → Permissions
2. Cho phép Camera và Storage

### Lỗi: "Upload failed"
**Nguyên nhân:** Không có internet hoặc Firebase Storage rules chặn  
**Giải pháp:**
1. Check internet connection
2. Deploy Storage rules (xem phần Security Rules)
3. Check Firebase Console → Storage → Files

### Avatar không hiển thị sau khi upload
**Nguyên nhân:** Cache hoặc chưa reload  
**Giải pháp:**
1. Pull-to-refresh màn hình
2. Logout/login lại
3. Clear app cache

### Ảnh cũ không bị xóa
**Nguyên nhân:** Storage rules không cho phép delete  
**Giải pháp:**
1. Deploy Storage rules với `allow delete`
2. Hoặc dùng Cloud Functions để auto-cleanup

---

## 📊 Firebase Console - Check Points

### Storage:
- Console → Storage → Files → `avatars/`
- Check file size (should be < 1MB after compression)
- Check filename format: `avatar_{uid}_{timestamp}.jpg`

### Firestore:
- Console → Firestore → `users/{uid}`
- Check field: `photoUrl` = "https://firebasestorage.googleapis.com/..."

### Authentication:
- Console → Authentication → Users
- Check PhotoURL column

---

## ✅ Hoàn Thành

**Status:** ✅ READY FOR TESTING

**Files Changed:**
- ✅ `pubspec.yaml` - Dependencies
- ✅ `lib/services/avatar_service.dart` - New service
- ✅ `lib/screens/members/member_info_screen.dart` - UI updates
- ✅ `android/app/src/main/AndroidManifest.xml` - Permissions
- ✅ `ios/Runner/Info.plist` - Permissions

**Next Action:**
1. Run `flutter pub get` (đã chạy) ✅
2. Run app trên device/emulator
3. Test upload/delete avatar
4. Deploy Storage rules nếu chưa có

---

**🎉 Feature hoàn chỉnh và sẵn sàng sử dụng!**
