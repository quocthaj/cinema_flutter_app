# 🔧 FIX SCREEN NAMES - HƯỚNG DẪN NHANH

## 🐛 VẤN ĐỀ PHÁT HIỆN:

Từ console log:
```
✅ Cached: Phòng 4 (ID: M7cpOGDeOBPpFeE1kK2I)
✅ Cached: Phòng 4 (ID: ZYL2mFJhKG0a2HoeSTPV)  ← DUPLICATE!
✅ Cached: Phòng 3 VIP (ID: V5ByOgPaJTnbqp1D990j)
✅ Cached: Phòng 4 (ID: 0jXKOP4pArNFzMYqTWOZ)  ← DUPLICATE!
✅ Cached: Phòng 4 (ID: wkfbbG8jDiAYDTo6YsRV)  ← DUPLICATE!
```

**Root Cause:** Có 5 screenIds nhưng 4 cái đều tên "Phòng 4" → Data trong Firebase bị SAI!

---

## ✅ GIẢI PHÁP: RESEED DATA

### Cách 1: Dùng Admin UI (KHUYẾN NGHỊ) ⭐

1. **Mở app Flutter**
   ```bash
   flutter run
   ```

2. **Vào Admin → Seed Data**
   - Từ bottom nav → "Hồ sơ"
   - Tap "Admin Panel"
   - Chọn "Seed Data"

3. **Chọn options:**
   - ✅ Movies (nếu muốn update)
   - ✅ Theaters
   - ✅ **Screens** ← QUAN TRỌNG!
   - ✅ **Showtimes** ← QUAN TRỌNG!
   - ✅ Sample Bookings

4. **Tap "🚀 Bắt Đầu Seed"**
   - Đợi progress bar chạy xong
   - Sẽ thấy "✅ Seed data hoàn tất!"

5. **Restart app**
   ```bash
   R (hot reload)
   # hoặc
   r (full restart)
   ```

6. **Test lại:**
   - Chọn phim "Nhà Ma Xó"
   - Vào booking screen
   - **Kiểm tra:** Phải hiển thị Phòng 1, 2, 3 VIP, 4

---

### Cách 2: Xóa Collections Manually (Nếu cần) 🔥

**CHỈ LÀM NẾU CÁCH 1 KHÔNG HIỆU QUẢ!**

1. **Mở Firebase Console:**
   ```
   https://console.firebase.google.com
   ```

2. **Chọn project của bạn**

3. **Vào Firestore Database**

4. **Xóa 2 collections:**
   - `screens` → Delete collection
   - `showtimes` → Delete collection

5. **Chạy lại Cách 1** (Seed từ Admin UI)

---

## 🎯 KẾT QUẢ MONG ĐỢI:

Sau khi reseed, console log sẽ thay đổi:

### ❌ Trước (SAI):
```
✅ Cached: Phòng 4 (ID: M7cpOGDeOBPpFeE1kK2I)
✅ Cached: Phòng 4 (ID: ZYL2mFJhKG0a2HoeSTPV)  ← DUPLICATE!
✅ Cached: Phòng 3 VIP (ID: V5ByOgPaJTnbqp1D990j)
✅ Cached: Phòng 4 (ID: 0jXKOP4pArNFzMYqTWOZ)  ← DUPLICATE!
✅ Cached: Phòng 4 (ID: wkfbbG8jDiAYDTo6YsRV)  ← DUPLICATE!
```

### ✅ Sau (ĐÚNG):
```
✅ Cached: Phòng 1 (ID: ABC123...)
✅ Cached: Phòng 2 (ID: DEF456...)
✅ Cached: Phòng 3 VIP (ID: GHI789...)
✅ Cached: Phòng 4 (ID: JKL012...)
```

### UI sẽ hiển thị:
```
Chọn suất chiếu:
┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
│ 09:00   │ 11:30   │ 14:00   │ 16:30   │ 19:00   │ 21:30   │
│ Phòng 1 │ Phòng 2 │ Phòng 3 │ Phòng 4 │ Phòng 1 │ Phòng 2 │
│ 80 ghế  │ 80 ghế  │ 48 ghế  │ 80 ghế  │ 80 ghế  │ 80 ghế  │
└─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘
           ✅ Mỗi phòng hiển thị đúng tên!
```

---

## ⚠️ LƯU Ý:

1. **Seed sẽ MẤT 2-3 phút** (do 210 showtimes × 7 ngày)
2. **Không đóng app** trong khi seed
3. **Kiểm tra internet** ổn định
4. **Sau khi seed xong:** Restart app để refresh cache

---

## 🐛 NẾU VẪN BỊ LỖI:

Chạy lại với **Clean Build:**

```bash
cd "C:\Tin\Lap trinh Mobile\Code\cinema_flutter_app"
flutter clean
flutter pub get
flutter run
```

Rồi lại **seed data** một lần nữa.

---

**🎯 HÃY THỬ NGAY VÀ GỬI KẾT QUẢ CHO TÔI!**
