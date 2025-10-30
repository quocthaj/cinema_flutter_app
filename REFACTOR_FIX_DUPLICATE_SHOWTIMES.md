# 🎯 REFACTOR HOÀN TOÀN - FIX BUG TRÙNG GIỜ & SAI PHÒNG

## 📋 VẤN ĐỀ GỐC

1. **Suất chiếu trùng giờ**: Nhiều phim chiếu cùng lúc trong 1 phòng
2. **Tên phòng sai**: Phòng của rạp CGV hiển thị là BHD
3. **Quá nhiều rạp**: 18 rạp (7 HN + 8 HCM + 3 ĐN) → khó quản lý

## ✅ GIẢI PHÁP MỚI

### 1. Giảm Số Lượng Rạp
- **Hà Nội**: 7 → **4 rạp**
- **TP.HCM**: 8 → **4 rạp**  
- **Đà Nẵng**: **3 rạp** (giữ nguyên)
- **Tổng**: 18 → **11 rạp**

### 2. Cấu Trúc Mới

#### Theaters (11 rạp)
```
Hà Nội (4):
├── cgv-vincom-ba-trieu-hn
├── bhd-vincom-pham-ngoc-thach-hn
├── lotte-west-lake-hn
└── galaxy-nguyen-du-hn

TP.HCM (4):
├── cgv-vincom-dong-khoi-hcm
├── cgv-landmark-81-hcm
├── lotte-nam-saigon-hcm
└── galaxy-nguyen-du-hcm

Đà Nẵng (3):
├── cgv-vincom-da-nang
├── lotte-vinh-trung-plaza-dn
└── bhd-lotte-mart-da-nang
```

#### Screens (44 phòng = 11 rạp × 4 phòng)
- Mỗi rạp có **4 phòng chiếu**
- externalId pattern: `{theater}-screen-{1-4}`
- VD: `cgv-vincom-ba-trieu-hn-screen-1`

#### Showtimes (1,848 suất = 264/ngày × 7 ngày)
- **6 khung giờ**: 09:00, 11:30, 14:00, 16:30, 19:00, 21:30
- **Mỗi phòng**: 6 suất/ngày
- **Mỗi rạp**: 4 phòng × 6 suất = 24 suất/ngày
- **Tất cả rạp**: 11 × 24 = 264 suất/ngày
- **7 ngày**: 264 × 7 = **1,848 suất**

### 3. Logic Phân Bổ Thông Minh

#### ✅ Đảm Bảo KHÔNG TRÙNG GIỜ
```dart
// Mỗi phòng 1 phim cố định
// Phòng 1 CGV Bà Triệu: chỉ chiếu "Cục Vàng Của Ngoại"
// → 6 suất: 09:00, 11:30, 14:00, 16:30, 19:00, 21:30

// Phòng 2 CGV Bà Triệu: chỉ chiếu "Nhà Ma Xó"  
// → 6 suất: 09:00, 11:30, 14:00, 16:30, 19:00, 21:30

// ⚠️ KHÔNG BAO GIỜ: 2 phim cùng phòng cùng giờ!
```

#### ✅ Mối Quan Hệ Chính Xác
```
Showtime.screenId → Screen.id → Screen.theaterId → Theater.id
```

**VD cụ thể**:
```
Showtime {
  movieId: "cuc-vang-cua-ngoai",
  screenId: "cgv-vincom-ba-trieu-hn-screen-1",
  theaterId: "cgv-vincom-ba-trieu-hn",  
  time: "09:00"
}
↓
Screen {
  id: "cgv-vincom-ba-trieu-hn-screen-1",
  theaterId: "cgv-vincom-ba-trieu-hn",
  name: "Phòng 1"
}
↓
Theater {
  id: "cgv-vincom-ba-trieu-hn",
  name: "CGV Vincom Center Bà Triệu"
}
```

## 📁 FILES MỚI TẠO

1. ✅ `hardcoded_theaters_data_NEW.dart` - 11 rạp
2. ✅ `hardcoded_screens_data_NEW.dart` - 44 phòng
3. ✅ `hardcoded_showtimes_data_NEW.dart` - Hà Nội (96 templates)
4. ✅ `hardcoded_showtimes_hcm_data_NEW.dart` - HCM (96 templates)
5. ✅ `hardcoded_showtimes_danang_data_NEW.dart` - Đà Nẵng (72 templates)
6. ✅ `hardcoded_seed_service_NEW.dart` - Service mới

**Tổng**: 264 templates × 7 ngày = 1,848 suất chiếu

## 🚀 CÁCH SỬ DỤNG

### Bước 1: Xóa Dữ Liệu Cũ
```dart
// Từ Admin UI
await HardcodedSeedServiceNew().clearAll();
```

### Bước 2: Seed Dữ Liệu Mới
```dart
// Từ Admin UI
await HardcodedSeedServiceNew().seedAll();
```

### Bước 3: Verify
1. Mở Firebase Console
2. Check collection `showtimes`
3. Filter theo `theaterId` và `screenId`
4. **Verify**: Mỗi (screenId + startTime) chỉ có 1 document

## 🎯 KẾT QUẢ MONG ĐỢI

### ✅ TRƯỚC (SAI)
```
CGV Bà Triệu - 13:00
├── Phòng 1: Cục Vàng Của Ngoại ✅
├── Phòng 1: Joker Điên Viên ❌ (TRÙNG!)
└── Phòng 3 (BHD): Venom ❌ (SAI RẠP!)
```

### ✅ SAU (ĐÚNG)
```
CGV Bà Triệu - 13:00 (14:00 trong timeslot)
├── Phòng 1: Cục Vàng Của Ngoại ✅
├── Phòng 2: Nhà Ma Xó ✅
├── Phòng 3 VIP: Joker Điên Viên ✅
└── Phòng 4: Venom Kết Thúc ✅

(Mỗi phòng 1 phim, KHÔNG TRÙNG!)
```

## 📊 SO SÁNH

| Metric | Cũ | Mới | Ghi chú |
|--------|-----|-----|---------|
| Rạp | 18 | 11 | Giảm 39% |
| Phòng | 72 | 44 | Giảm 39% |
| Suất/ngày | 290 | 264 | Giảm 9% |
| Suất/7 ngày | 2,030 | 1,848 | Giảm 9% |
| **Bug trùng giờ** | ❌ Có | ✅ Không | **FIXED!** |
| **Bug sai phòng** | ❌ Có | ✅ Không | **FIXED!** |

## 🔧 TECHNICAL DETAILS

### Naming Convention
```
theater: {brand}-{location}-{city_code}
  VD: cgv-vincom-ba-trieu-hn

screen: {theater_external_id}-screen-{number}
  VD: cgv-vincom-ba-trieu-hn-screen-1
```

### Time Slots (6 slots)
```dart
const timeSlots = [
  '09:00',  // Sáng - 60k
  '11:30',  // Trưa - 60k
  '14:00',  // Chiều - 75k
  '16:30',  // Chiều muộn - 75k
  '19:00',  // Tối (giờ vàng) - 90k
  '21:30',  // Tối muộn - 90k
];
```

### Pricing Logic
- **Sáng (< 12h)**: 60,000đ
- **Chiều (12h-18h)**: 75,000đ
- **Tối (>= 18h)**: 90,000đ
- **VIP**: Thêm 30,000đ

## ⚠️ LƯU Ý

1. **Files cũ KHÔNG XÓA** - giữ làm backup:
   - `hardcoded_theaters_data.dart`
   - `hardcoded_screens_data.dart`
   - `hardcoded_showtimes_data.dart`
   - `hardcoded_seed_service.dart`

2. **Files mới có suffix `_NEW`** - dễ phân biệt

3. **Admin UI đã update** - dùng `HardcodedSeedServiceNew()`

## 🎉 DONE!

Bây giờ:
- ✅ **KHÔNG CÒN** suất chiếu trùng giờ
- ✅ **KHÔNG CÒN** phòng chiếu sai rạp
- ✅ Dữ liệu **DỄ QUẢN LÝ** (11 rạp thay vì 18)
- ✅ Logic **RÕ RÀNG** và dễ debug

**Happy Coding! 🚀**
