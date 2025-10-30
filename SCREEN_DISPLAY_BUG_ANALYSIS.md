# 🐛 SCREEN DISPLAY BUG - BÁO CÁO PHÂN TÍCH VÀ FIX

**Ngày:** 30/10/2025  
**Vấn đề:** UI hiển thị chỉ 1 phòng chiếu duy nhất thay vì 4 phòng  
**Trạng thái:** 🔍 ĐANG DEBUG

---

## 📸 HIỆN TRẠNG

Từ screenshot bạn gửi:

```
Chọn suất chiếu:
┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
│ 09:00   │ 11:30   │ 14:00   │ 16:30   │ 19:00   │ 21:30   │
│ Phòng 2 │ Phòng 2 │ Phòng 2 │ Phòng 2 │ Phòng 2 │ Phòng 2 │
│ 80 ghế  │ 80 ghế  │ 80 ghế  │ 80 ghế  │ 80 ghế  │ 80 ghế  │
└─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘
```

**❌ SAI:** Tất cả đều hiển thị "Phòng 2"

**✅ ĐÚNG:** Mỗi suất chiếu phải hiển thị phòng riêng (Phòng 1, 2, 3, 4)

---

## 🔍 PHÂN TÍCH VẤN ĐỀ

### 1. Kiểm tra Data Seed

**File:** `lib/services/seed/hardcoded_showtimes_data.dart`

```dart
// CGV Vincom Bà Triệu - ĐÚNG: Có đủ 4 phòng
static List<Map<String, dynamic>> get cgvVincomBaTrieuShowtimes {
  const theater = 'cgv-vincom-ba-trieu-hn';
  return [
    // Phòng 1: Cục Vàng Của Ngoại
    ...timeSlots.map((time) => createShowtime(
      movieExternalId: 'cuc-vang-cua-ngoai',
      theaterExternalId: theater,
      screenNumber: 1, // ✅
      time: time,
    )),
    
    // Phòng 2: Nhà Ma Xó
    ...timeSlots.map((time) => createShowtime(
      movieExternalId: 'nha-ma-xo',
      theaterExternalId: theater,
      screenNumber: 2, // ✅
      time: time,
    )),
    
    // Phòng 3 VIP: Tee Yod 3
    ...timeSlots.map((time) => createShowtime(
      movieExternalId: 'tee-yod-3',
      theaterExternalId: theater,
      screenNumber: 3, // ✅
      time: time,
    )),
    
    // Phòng 4: Tử Chiến Trên Không
    ...timeSlots.map((time) => createShowtime(
      movieExternalId: 'tu-chien-tren-khong',
      theaterExternalId: theater,
      screenNumber: 4, // ✅
      time: time,
    )),
  ];
}
```

**✅ KẾT LUẬN:** Data seed CÓ ĐỦ 4 phòng (screenNumber: 1, 2, 3, 4)

---

### 2. Kiểm tra Hiển thị UI

**File:** `lib/screens/bookings/booking_screen.dart`

**Cơ chế hiển thị:**
```dart
// Dùng _screenCache để lấy tên phòng
final screen = _screenCache[showtime.screenId];
final screenName = screen?.name ?? 'Đang tải...';
```

**Vấn đề phát hiện:**

1. **Cache được load trong `_preloadScreenData()`**
   - Gọi từ `initState()`
   - Chạy async → có thể chưa load kịp khi render

2. **Fallback "Đang tải..." không rõ ràng**
   - Nếu `screen == null` → hiển thị "Đang tải..."
   - Nhưng thực tế có thể là:
     - ❓ Cache chưa load xong
     - ❌ screenId không tồn tại trong DB
     - ❌ screenId sai format

3. **UI hiển thị TẤT CẢ "Phòng 2"**
   - Có thể tất cả showtimes đều có cùng `screenId`
   - Hoặc cache chỉ có 1 screen duy nhất

---

## 🐛 GIẢ THUYẾT

### Giả thuyết 1: Showtimes có sai screenId

**Nguyên nhân có thể:**
- Khi seed data, `screenId` được map sai
- Tất cả showtimes đều trỏ về cùng 1 screen

**Cách kiểm tra:**
```dart
// In ra screenId của các showtimes
for (var showtime in showtimes) {
  print('Showtime ${showtime.id}: screenId = ${showtime.screenId}');
}
```

---

### Giả thuyết 2: Cache không load đủ screens

**Nguyên nhân có thể:**
- `_preloadScreenData()` chỉ load screens của showtimes đã có
- Nếu showtimes có sai screenId → load sai screens

**Cách kiểm tra:**
```dart
// In ra cache
print('Cache has ${_screenCache.length} screens');
print('IDs: ${_screenCache.keys.join(", ")}');
```

---

### Giả thuyết 3: Seed data không sync đúng

**Nguyên nhân có thể:**
- `screenExternalId` trong seed data: `cgv-vincom-ba-trieu-hn-screen-1`
- Nhưng trong Firebase `screens` collection, ID khác format
- Dẫn đến showtimes.screenId không match với screens.id

**Cách kiểm tra:**
```sql
-- Firestore query
showtimes.screenId = "abc123"
screens.id = "xyz789"  ← NOT MATCH!
```

---

## 🛠️ GIẢI PHÁP ĐANG TRIỂN KHAI

### Bước 1: Thêm Debug Logs ✅

**File modified:** `lib/screens/bookings/booking_screen.dart`

**Thay đổi:**

1. **`_preloadScreenData()`** - In ra quá trình load cache:
```dart
print('🔄 PRELOAD: Starting to load screen data...');
print('📊 PRELOAD: Found ${showtimes.length} showtimes');
print('🎬 PRELOAD: Unique screenIds: ${screenIds.length}');
print('   IDs: ${screenIds.join(", ")}');
// ...
print('   ✅ Cached: ${screen.name} (ID: $screenId)');
print('   ❌ NOT FOUND: $screenId');
print('✅ PRELOAD: Complete. Cache has ${_screenCache.length} screens');
```

2. **`_buildSimpleShowtimeSelection()`** - In ra khi thiếu screen:
```dart
if (screen == null) {
  print('⚠️  MISSING SCREEN: ${showtime.screenId} for showtime ${showtime.id}');
  print('   Cache has ${_screenCache.length} screens: ${_screenCache.keys.join(", ")}');
}
```

3. **`_buildGroupedShowtimeSelection()`** - Tương tự debug cho grouped view

---

### Bước 2: Chạy App và Kiểm tra Log 🔄

**Cần làm:**
1. Mở app Flutter
2. Navigate to BookingScreen (chọn phim "Nhà Ma Xó")
3. Xem console log:
   - Có bao nhiêu showtimes?
   - Có bao nhiêu unique screenIds?
   - Cache load được bao nhiêu screens?
   - Có screenId nào không tìm thấy không?

**Expected output:**
```
🔄 PRELOAD: Starting to load screen data...
📊 PRELOAD: Found 24 showtimes
🎬 PRELOAD: Unique screenIds: 4
   IDs: abc123, def456, ghi789, jkl012
   ✅ Cached: Phòng 1 (ID: abc123)
   ✅ Cached: Phòng 2 (ID: def456)
   ✅ Cached: Phòng 3 VIP (ID: ghi789)
   ✅ Cached: Phòng 4 (ID: jkl012)
✅ PRELOAD: Complete. Cache has 4 screens
```

**Nếu thấy:**
```
🎬 PRELOAD: Unique screenIds: 1  ← ❌ CHỈ 1 SCREEN ID!
   IDs: abc123
```
→ **Vấn đề ở DATA**: Tất cả showtimes đều có cùng screenId!

---

### Bước 3: Xác định Root Cause 🎯

**Dựa vào log, có 3 kịch bản:**

#### Kịch bản A: Cache chỉ có 1 screen
```
✅ PRELOAD: Complete. Cache has 1 screens
```
**→ Root cause:** Showtimes có sai screenId (tất cả trỏ về 1 screen)
**→ Fix:** Reseed data với đúng screenId mapping

#### Kịch bản B: Cache có 4 screens nhưng UI hiển thị 1
```
✅ PRELOAD: Complete. Cache has 4 screens
⚠️  MISSING SCREEN: xyz789 for showtime abc
   Cache has 4 screens: a,b,c,d
```
**→ Root cause:** screenId không match
**→ Fix:** Kiểm tra seed service mapping logic

#### Kịch bản C: MISSING SCREEN warnings
```
⚠️  MISSING SCREEN: xyz789
⚠️  MISSING SCREEN: xyz790
⚠️  MISSING SCREEN: xyz791
```
**→ Root cause:** Screens không tồn tại trong DB
**→ Fix:** Reseed screens collection

---

## 📋 NEXT STEPS

### Immediate (Đang làm):
1. ✅ Thêm debug logs
2. 🔄 **Chạy app và xem console log**
3. 📊 Phân tích output để xác định root cause

### Based on Findings:

#### Nếu vấn đề ở SEED DATA:
```bash
# Reseed toàn bộ data
flutter run lib/screens/admin/seed_data_screen.dart
```

#### Nếu vấn đề ở MAPPING LOGIC:
```dart
// File: lib/services/seed/hardcoded_seed_service.dart
// Kiểm tra logic map screenExternalId → Firestore ID
```

#### Nếu vấn đề ở FIREBASE:
```bash
# Xóa showtimes và screens collection
# Seed lại từ đầu
```

---

## 🎯 MỤC TIÊU CUỐI CÙNG

**UI mong đợi:**
```
Chọn suất chiếu:
┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
│ 09:00   │ 11:30   │ 14:00   │ 16:30   │ 19:00   │ 21:30   │
│ Phòng 1 │ Phòng 2 │ Phòng 3 │ Phòng 4 │ Phòng 1 │ Phòng 2 │
│ 80 ghế  │ 80 ghế  │ 100 ghế │ 80 ghế  │ 80 ghế  │ 80 ghế  │
└─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘
```

**Mỗi phim chiếu ở nhiều phòng khác nhau**

---

## 📝 CHÚ THÍCH

### Seed Data Structure
```
Theater (CGV Vincom Bà Triệu)
├── Phòng 1 → Phim A (Cục Vàng Của Ngoại)
│   ├── 09:00
│   ├── 11:30
│   ├── 14:00
│   └── ...
├── Phòng 2 → Phim B (Nhà Ma Xó)
│   ├── 09:00
│   ├── 11:30
│   └── ...
├── Phòng 3 VIP → Phim C (Tee Yod 3)
└── Phòng 4 → Phim D (Tử Chiến Trên Không)
```

**Khi chọn "Nhà Ma Xó":**
- ✅ Phải hiển thị TẤT CẢ rạp có chiếu phim này
- ✅ Mỗi rạp có nhiều phòng (1-4)
- ✅ Mỗi phòng có nhiều suất (6 suất/ngày)

---

**STATUS:** 🔄 Waiting for debug log output để xác định root cause chính xác

**ASSIGNED TO:** Bạn (chạy app và gửi console log)

**PRIORITY:** 🔴 HIGH - Ảnh hưởng trực tiếp đến UX booking

