# 🚀 QUICK START: Sử Dụng Admin UI để Seed Data

## 📱 Cách Mở Admin Screen

### ✅ Đã cài đặt sẵn: Nút Admin trên Home Screen

1. **Chạy app:**
   ```bash
   flutter run
   ```

2. **Tìm nút Admin:**
   - Ở màn hình Home
   - Góc dưới bên phải
   - Nút màu tím với icon ⚙️ và text "Admin"

3. **Click vào nút Admin**
   - Màn hình "🔧 Admin - Seed Data" sẽ hiện ra

---

## 🎬 Cách Seed Data (3 bước đơn giản)

### Bước 1: Nhấn nút "Thêm tất cả dữ liệu mẫu"
- Nút màu xanh lá
- Icon upload ⬆️

### Bước 2: Đợi ~2 phút
- Loading indicator sẽ hiện
- Message "Đang thêm dữ liệu..." sẽ xuất hiện
- **KHÔNG tắt app** trong lúc này

### Bước 3: Xác nhận thành công
- Message "✅ Thêm dữ liệu thành công!" sẽ hiện
- Quay lại Home screen
- Phim sẽ xuất hiện ngay lập tức (real-time)

---

## 📊 Dữ Liệu Được Thêm

| Collection | Số lượng | Mô tả |
|-----------|----------|-------|
| 🎬 **Movies** | 5 phim | Avatar, Mai, Deadpool, Oppenheimer, The Marvels |
| 🏢 **Theaters** | 4 rạp | CGV (HN), Galaxy (HCM), Lotte (ĐN), BHD (HCM) |
| 🪑 **Screens** | 12 phòng | 3 phòng/rạp (Phòng 1, 2, 3-VIP) |
| ⏰ **Showtimes** | 60+ lịch | 7 ngày × 3 phim × 3 suất = 63 showtimes |

**Thời gian:** ~1-2 phút

---

## ✅ Kiểm Tra Kết Quả

### Trong App:
- ✅ Home screen → Thấy banner phim
- ✅ Movies screen → Thấy 4 phim "Đang chiếu" + 1 "Sắp chiếu"
- ✅ Theaters screen → Thấy 4 rạp
- ✅ Movie Detail → Thấy lịch chiếu

### Trên Firebase Console:
1. Vào: https://console.firebase.google.com/
2. Chọn project → Firestore Database
3. Thấy 5 collections: `movies`, `theaters`, `screens`, `showtimes`, `users`

---

## 🗑️ Xóa Dữ Liệu (Nếu Cần)

1. Vào Admin screen
2. Nhấn nút "Xóa tất cả dữ liệu" (màu đỏ)
3. Xác nhận trong dialog
4. Đợi ~30 giây
5. Message "✅ Xóa dữ liệu thành công!"

---

## 🐛 Gặp Lỗi?

### Lỗi: "Permission denied"
→ Vào Firebase Console → Firestore Rules → Đổi thành:
```javascript
allow read, write: if true;
```

### Lỗi: "Firebase not initialized"
→ Check `main.dart` có dòng:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### App crash khi seed
→ Chạy:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📖 Đọc Thêm

- **Chi tiết đầy đủ:** `HOW_TO_USE_ADMIN_UI.md`
- **Kiến trúc:** `ARCHITECTURE.md`
- **Code examples:** `USAGE_GUIDE.md`

---

## 🎯 Sau Khi Seed Xong

Bạn đã sẵn sàng để:
- ✅ Test màn hình Movies
- ✅ Test màn hình Theaters
- ✅ Implement booking flow
- ✅ Test thanh toán

---

**🎉 Enjoy coding!** 🚀
