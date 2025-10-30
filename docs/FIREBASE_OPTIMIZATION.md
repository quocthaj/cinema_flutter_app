# 🔥 FIREBASE FREE TIER OPTIMIZATION

## 📊 Phân Tích Vấn Đề

Dựa theo biểu đồ Firestore operations trong 24h:
- **Readings**: 30k trong 1 giờ (spike tại 10 PM)
- **Scriptures (Writes)**: 20k trong 1 giờ (spike tại 10 PM) ⚠️
- **Deletions**: 7.9k

### ❌ Vấn Đề: RESOURCE_EXHAUSTED
```
Status{code=RESOURCE_EXHAUSTED, description=Quota exceeded., cause=null}
```

**Firebase Free Tier Limits:**
- Reads: 50,000/day
- **Writes: 20,000/day** ← VẤN ĐỀ CHÍNH
- Deletes: 20,000/day

**Spike 20k writes trong 1 giờ = VƯỢT QUOTA CẢ NGÀY!**

---

## ✅ Giải Pháp Đã Triển Khai

### 1. **Giảm Dữ Liệu (Data Reduction)**

| Metric | ❌ Trước | ✅ Sau | % Giảm |
|--------|---------|--------|--------|
| **Rạp** | 44 | 10 | -77% |
| **Phòng chiếu** | ~280 | ~39 | -86% |
| **Ngày seed** | 7 | 3 | -57% |
| **Suất/phim/ngày** | 2 | 1 | -50% |
| **Time slots** | 7 | 4 | -43% |
| **Phim/rạp** | 3-5 | 2-3 | -40% |
| **Hàng ghế** | 10 (A-J) | 6 (A-F) | -40% |
| **Ghế/hàng** | 15 | 10 | -33% |
| **Capacity/phòng** | 80-250 | 50-100 | -60% |

**KẾT QUẢ:**
```
TRƯỚC: ~444,000 documents (writes) ❌
SAU:   ~5,764 documents (writes) ✅
GIẢM:  98.7%
```

---

### 2. **Throttling & Delays**

#### A. Batch Operations:
```dart
// seed_config.dart
static const int batchSize = 500;
static const int delayBetweenBatchesMs = 500; // TĂNG TỪ 100ms
static const int maxWritesPerSecond = 50;
```

#### B. Inter-Phase Delays:
```dart
// seed_data_orchestrator.dart

// Phase 1: Movies
await seedMovies();
await Future.delayed(Duration(seconds: 2)); // ⏳

// Phase 1: Theaters
await seedTheaters();
await Future.delayed(Duration(seconds: 2)); // ⏳

// Phase 1: Screens
await seedScreens();
await Future.delayed(Duration(seconds: 3)); // ⏳

// Phase 2: Showtimes
await seedShowtimes();
await Future.delayed(Duration(seconds: 3)); // ⏳

// Phase 3: Seats
await seedSeats();
```

#### C. Batch Commit Delays:
```dart
// Trong mỗi seeder
if (batchCount >= SeedConfig.batchSize) {
  await batch.commit();
  print('💾 Batch committed');
  await Future.delayed(Duration(milliseconds: 500)); // ⏳
  batch = _db.batch();
  batchCount = 0;
}
```

**Lợi ích:**
- Tránh spike writes trong 1 giờ
- Phân tán writes ra nhiều giờ
- Giảm áp lực lên Firebase server

---

### 3. **Cấu Hình Chi Tiết**

#### `seed_config.dart`:
```dart
// MOVIES & THEATERS
maxMoviesPerTheater: 3  // (giảm từ 5)
minMoviesPerTheater: 2

// SHOWTIMES
daysToSeed: 3  // (giảm từ 7)
showtimesPerMoviePerDay: 1  // (giảm từ 2)
timeSlots: ['10:00', '14:00', '18:00', '21:00']  // 4 slots (giảm từ 7)

// SEATS
seatRows: ['A', 'B', 'C', 'D', 'E', 'F']  // 6 hàng (giảm từ 10)
seatsPerRow: 10  // (giảm từ 15)
vipRows: ['D', 'E']  // 2 hàng (giảm từ 3)
coupleRows: ['F']  // 1 hàng (giảm từ 2)

// CAPACITY BY ROOM TYPE
Standard: 80  (giảm từ 150)
Deluxe: 60    (giảm từ 120)
VIP: 50       (giảm từ 80)
IMAX: 100     (giảm từ 250)
```

#### `movie_theater_seeder.dart`:
```dart
// CHỈ GIỮ 10 RẠP CHÍNH
[
  // Hà Nội (5 rạp)
  {'name': 'CGV Vincom Bà Triệu', 'rooms': 4},      // giảm từ 8
  {'name': 'CGV Aeon Long Biên', 'rooms': 3},       // giảm từ 7
  {'name': 'Lotte Mỹ Đình Plaza 2', 'rooms': 4},    // giảm từ 8
  {'name': 'Galaxy Trung Hòa', 'rooms': 3},         // giảm từ 6
  {'name': 'BHD Times City', 'rooms': 3},           // giảm từ 6
  
  // HCM (5 rạp)
  {'name': 'CGV Landmark 81', 'rooms': 5},          // giảm từ 9
  {'name': 'CGV Đồng Khởi', 'rooms': 4},            // giảm từ 7
  {'name': 'Lotte Diamond', 'rooms': 5},            // giảm từ 9
  {'name': 'Galaxy Nguyễn Du', 'rooms': 4},         // giảm từ 8
  {'name': 'BHD Vincom 3/2', 'rooms': 4},           // giảm từ 8
]
```

---

## 📈 Ước Tính Writes Sau Tối Ưu

### Phase 1: Movies & Theaters & Screens
```
Movies:   15 writes
Theaters: 10 writes
Screens:  39 writes (10 rạp × ~3.9 phòng)
─────────────────────
Total:    64 writes
Time:     ~10 giây (với delays)
```

### Phase 2: Showtimes
```
Screens:  39 phòng
Days:     3 ngày
Movies:   2-3 phim/rạp × ~0.3 suất/phim/ngày
─────────────────────
Total:    ~94 showtimes
Time:     ~20 giây (với delays)
```

### Phase 3: Seats
```
Showtimes: 94
Seats/showtime: 60 ghế trung bình (6 hàng × 10 ghế)
─────────────────────
Total:     ~5,640 seats
Time:      ~60 giây (với delays + batch commits mỗi 500 docs)
```

### **TỔNG:**
```
Total Writes:  ~5,764 documents
Total Time:    ~90 giây (1.5 phút)
Writes/second: ~64 writes/s (TRUNG BÌNH)

✅ AN TOÀN: 5,764 << 20,000 (Free tier limit)
```

---

## 🎯 Kết Quả Mong Đợi

### Trước (❌ Vượt Quota):
```
┌────────────────────────────────────┐
│  10 PM  │ ████████████ 20k writes │ ← SPIKE!
│  11 PM  │ ███         3k writes   │
│  12 AM  │ ████████    15k writes  │
└────────────────────────────────────┘
TOTAL: 38k writes trong 3 giờ ❌
```

### Sau (✅ An Toàn):
```
┌────────────────────────────────────┐
│  10 PM  │ ██          ~2k writes  │ ← Phân tán
│  10:01  │ ██          ~2k writes  │
│  10:02  │ ██          ~1.7k writes│
└────────────────────────────────────┘
TOTAL: ~5.7k writes trong 2 phút ✅
```

---

## 🚀 Cách Chạy Seed

### 1. Clear Old Data (nếu cần):
```dart
final orchestrator = SeedDataOrchestrator();
await orchestrator.clearAllData();
```

### 2. Seed All (Tự động 3 phases):
```dart
await orchestrator.seedAll();
```

**Output mẫu:**
```
╔═══════════════════════════════════════════════════════╗
║  🚀 BẮT ĐẦU SEED DỮ LIỆU - HỆ THỐNG RẠP VIỆT NAM    ║
╚═══════════════════════════════════════════════════════╝

┌─────────────────────────────────────────┐
│  🎬 PHASE 1.1: SEEDING MOVIES          │
└─────────────────────────────────────────┘
  ✅ Venom: The Last Dance (now_showing)
  ✅ Smile 2 (now_showing)
  ...
   💾 Final batch committed (15 movies)
✅ Đã thêm 15 phim!

⏳ Đợi 2s để tránh Firebase throttle...

┌─────────────────────────────────────────┐
│  🏢 PHASE 1.2: SEEDING THEATERS        │
└─────────────────────────────────────────┘
   💾 Final batch committed (10 theaters)
✅ Đã thêm 10 rạp!

⏳ Đợi 2s để tránh Firebase throttle...

┌─────────────────────────────────────────┐
│  🪑 PHASE 1.3: SEEDING SCREENS         │
└─────────────────────────────────────────┘
   💾 Final batch committed (39 screens)
✅ Đã tạo 39 phòng chiếu!

⏳ Đợi 3s trước khi chuyển sang Phase 2...

┌─────────────────────────────────────────┐
│  ⏰ PHASE 2: SEEDING SHOWTIMES         │
└─────────────────────────────────────────┘
   📌 Logic: Mỗi screen + ngày + giờ chỉ có 1 showtime
   ✅ Ngày 1/3: 32 showtimes
   ✅ Ngày 2/3: 31 showtimes
   ✅ Ngày 3/3: 31 showtimes
   💾 Final batch committed
✅ HOÀN TẤT: Đã tạo 94 showtimes (KHÔNG TRÙNG LẶP)!

⏳ Đợi 3s trước khi chuyển sang Phase 3...

┌─────────────────────────────────────────┐
│  🪑 PHASE 3: SEEDING SEATS             │
└─────────────────────────────────────────┘
   💾 Đã xử lý 50/94 showtimes...
   💾 Batch committed (500 seats)
   💾 Final batch committed
✅ HOÀN TẤT: Đã tạo 5,640 ghế cho 94 showtimes!

╔═══════════════════════════════════════════════════════╗
║              ✅ HOÀN THÀNH SEED DỮ LIỆU              ║
╚═══════════════════════════════════════════════════════╝

📊 TỔNG KẾT:
│  🎬 Phim:              15 phim (15 đang chiếu)
│  🏢 Rạp chiếu:         10 rạp
│  🪑 Phòng chiếu:       39 phòng
│  ⏰ Lịch chiếu:        94 suất (3 ngày)
│  🎫 Ghế ngồi:        5640 ghế
│  ⏱️ Thời gian:         90s

🎯 CHI TIẾT:
  • 15 phim đang chiếu (CÓ LỊCH CHIẾU)
  • 0 phim sắp chiếu (KHÔNG CÓ LỊCH)
  • Mỗi phim: 1 suất/ngày
  • Ghế: 70% Regular, 25% VIP, 5% Couple
  • ✅ KHÔNG CÓ SHOWTIME TRÙNG LẶP
  • ✅ SEATS PHÂN LOẠI THEO HÀNG
```

---

## 📋 Checklist Sau Khi Seed

- [ ] Kiểm tra Firebase Console → Firestore Database
  - [ ] Collection `movies`: 15 documents
  - [ ] Collection `theaters`: 10 documents
  - [ ] Collection `screens`: 39 documents
  - [ ] Collection `showtimes`: ~94 documents
  - [ ] Collection `seats`: ~5,640 documents

- [ ] Kiểm tra Firebase Console → Usage
  - [ ] Reads: Dưới 50k/day
  - [ ] Writes: Dưới 20k/day ✅
  - [ ] No RESOURCE_EXHAUSTED errors

- [ ] Test App
  - [ ] Movies hiển thị đúng
  - [ ] Theaters hiển thị đúng
  - [ ] Showtimes load được
  - [ ] Seat selection hoạt động
  - [ ] Booking flow hoàn chỉnh

---

## 🔧 Troubleshooting

### Vẫn bị RESOURCE_EXHAUSTED?

1. **Tăng delay giữa các batch:**
   ```dart
   // seed_config.dart
   static const int delayBetweenBatchesMs = 1000; // Tăng lên 1 giây
   ```

2. **Giảm thêm số rạp:**
   ```dart
   // movie_theater_seeder.dart
   // Chỉ giữ 5 rạp (3 HN + 2 HCM)
   ```

3. **Giảm số ngày seed:**
   ```dart
   // seed_config.dart
   static const int daysToSeed = 2; // Giảm xuống 2 ngày
   ```

4. **Chạy từng phase riêng lẻ với delay dài:**
   ```dart
   await orchestrator.seedPhase(SeedPhase.phase1MoviesTheaters);
   await Future.delayed(Duration(hours: 1)); // Đợi 1 giờ!
   
   await orchestrator.seedPhase(SeedPhase.phase2Showtimes);
   await Future.delayed(Duration(hours: 1));
   
   await orchestrator.seedPhase(SeedPhase.phase3Seats);
   ```

---

## 💡 Best Practices

### 1. **Monitor Firebase Usage:**
- Vào Firebase Console → Usage and Billing
- Theo dõi biểu đồ Operations/hour
- Set alerts khi gần đến limit

### 2. **Seed vào giờ thấp điểm:**
- Tránh seed vào giờ cao điểm (8-10 PM)
- Seed vào sáng sớm hoặc đêm khuya

### 3. **Clear old data trước khi seed:**
- Xóa data cũ để tránh duplicate
- Đảm bảo không vượt storage limit

### 4. **Test với data nhỏ trước:**
```dart
// Test với 1 rạp, 1 ngày
static const int daysToSeed = 1;
List<Map<String, dynamic>> _getTheatersData() {
  return [
    {'name': 'CGV Test', 'rooms': 2}
  ];
}
```

---

## 📞 Support

Nếu vẫn gặp vấn đề, check:
1. Firebase Console → Usage metrics
2. Flutter Console → Error logs
3. Logcat → Firestore warnings

**Happy Seeding! 🎉**
