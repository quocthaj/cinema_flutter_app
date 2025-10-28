# 🔄 Hướng Dẫn Sử Dụng Sync Data

## 📖 Tổng Quan

Hệ thống sync data cho phép bạn đồng bộ dữ liệu seed với Firestore theo 3 cách:
- **Update**: Cập nhật các bản ghi đã có nếu có thay đổi
- **Add**: Thêm mới các bản ghi còn thiếu
- **Delete**: Xóa các bản ghi không còn trong seed data

## 🎯 Khi Nào Sử Dụng

### ✅ Sử dụng Sync khi:
- Bạn đã có dữ liệu trên Firestore và muốn cập nhật
- Bạn thêm phim/rạp mới vào seed data
- Bạn sửa thông tin phim/rạp trong seed data (giá, mô tả, v.v.)
- Bạn xóa phim/rạp khỏi seed data và muốn xóa trên Firestore

### ❌ KHÔNG sử dụng Sync khi:
- Database trống hoàn toàn (dùng "Thêm dữ liệu mẫu" thay vì)
- Bạn muốn giữ lại dữ liệu cũ (Sync sẽ xóa những gì không có trong seed)

## 🚀 Cách Sử Dụng

### 1️⃣ Kiểm Tra Thay Đổi (Dry Run)

Luôn chạy Dry Run trước để xem những gì sẽ thay đổi:

```dart
// Trong UI Admin
Nhấn nút "Kiểm tra thay đổi (Dry Run)"
```

Hoặc trong code:
```dart
final result = await seedService.syncAllData(dryRun: true);
print(result); // Xem thống kê
```

**Output mẫu:**
```
📊 Kết quả sync:
  ✅ Thêm mới: 2
  🔄 Cập nhật: 5
  🗑️  Xóa: 1
  ⏭️  Không đổi: 10
```

### 2️⃣ Áp Dụng Thay Đổi (Sync Thực Tế)

Sau khi kiểm tra, nhấn "Đồng bộ thực tế":

```dart
final result = await seedService.syncAllData(dryRun: false);
```

## 📝 Quy Trình Làm Việc

### Thêm Phim Mới

1. Mở `lib/services/seed/movie_seed_data.dart`
2. Thêm phim mới vào list `movies`:
   ```dart
   {
     "externalId": "phim-moi-2025",  // Bắt buộc!
     "title": "Phim Mới 2025",
     "genre": "Hành Động",
     // ... các field khác
   }
   ```
3. Vào Admin UI → Nhấn "Kiểm tra thay đổi"
4. Xem kết quả: "Thêm mới: 1"
5. Nhấn "Đồng bộ thực tế"

### Cập Nhật Phim

1. Mở `lib/services/seed/movie_seed_data.dart`
2. Sửa thông tin phim (rating, description, v.v.)
3. Vào Admin UI → "Kiểm tra thay đổi"
4. Xem: "Cập nhật: X"
5. "Đồng bộ thực tế"

### Xóa Phim

1. Xóa entry phim khỏi `movie_seed_data.dart`
2. "Kiểm tra thay đổi" → thấy "Xóa: 1"
3. ⚠️ **CHÚ Ý**: Phim bị xóa sẽ mất vĩnh viễn!
4. "Đồng bộ thực tế"

## 🔑 External ID - Rất Quan Trọng!

### Tại sao cần External ID?

External ID là **định danh duy nhất** để Firestore biết document nào cần update/add/delete.

**❌ Trước (dùng auto-generated ID):**
```dart
{
  "title": "Avatar 3"  // Không có cách nào biết đây là phim nào
}
// Firestore tự tạo: JnQ8K2mP... (random)
```
Vấn đề: Mỗi lần seed lại tạo document mới → Duplicate!

**✅ Sau (dùng External ID):**
```dart
{
  "externalId": "avatar-3",  // Định danh rõ ràng
  "title": "Avatar 3"
}
// Document ID = "avatar-3" (cố định)
```
Lợi ích: Sync biết được document nào cần update, tránh duplicate!

### Quy tắc đặt External ID

- **Lowercase**: `avatar-3` ✅, `Avatar-3` ❌
- **Dấu gạch ngang**: `avatar-3` ✅, `avatar_3` ⚠️ (cũng được)
- **Unique**: Không trùng giữa các phim
- **Không đổi**: Khi đã set thì không nên đổi

## 🛡️ An Toàn Dữ Liệu

### Backup Trước Khi Sync

Firestore Console → Export → Cloud Storage

### Dry Run Là Bạn

**Luôn luôn** chạy Dry Run trước!

### Rollback Nếu Sai

1. Nếu sync nhầm → Restore từ backup
2. Hoặc: Sửa lại seed data → Sync lại

## 🔍 So Sánh Dữ Liệu

Sync chỉ cập nhật khi có **thay đổi thực sự**:

```dart
// Existing (Firestore)
{
  "title": "Avatar 3",
  "rating": 9.0
}

// Seed
{
  "title": "Avatar 3",
  "rating": 9.5  // ← Khác!
}

→ Kết quả: UPDATE
```

### Fields Được So Sánh (Movies)
- externalId, title, genre, duration
- rating, status, releaseDate
- description, posterUrl, trailerUrl
- director, cast, language, ageRating

### Fields Bị Bỏ Qua
- createdAt, updatedAt (metadata)
- Các field không có trong seed

## 📊 Kết Quả Sync

```dart
class SyncResult {
  int added;      // Số bản ghi thêm mới
  int updated;    // Số bản ghi cập nhật
  int deleted;    // Số bản ghi xóa
  int unchanged;  // Số bản ghi không đổi
  List<String> errors;  // Lỗi nếu có
}
```

## 🐛 Xử Lý Lỗi

### Lỗi: "Movie thiếu externalId"

**Nguyên nhân:** Quên thêm `externalId` cho movie

**Giải pháp:**
```dart
{
  "externalId": "ten-phim",  // ← Thêm dòng này
  "title": "Tên Phim"
}
```

### Lỗi: Timeout

**Nguyên nhân:** Quá nhiều documents cần sync

**Giải pháp:**
- Hệ thống tự chia batch (500 ops/batch)
- Nếu vẫn timeout → Chia nhỏ seed data

### Lỗi: Permission Denied

**Nguyên nhân:** Firestore rules chặn

**Giải pháp:**
- Check Firestore Rules
- Đảm bảo user có quyền write

## 🎓 Best Practices

1. **Luôn Dry Run trước** ✅
2. **Backup trước khi sync quan trọng** ✅
3. **External ID phải unique và không đổi** ✅
4. **Commit code trước khi sync** ✅
5. **Test trên môi trường dev trước** ✅

## 🔄 Sync Flow Chart

```
┌─────────────────────┐
│  Sửa Seed Data      │
│  (movie_seed_data)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Dry Run            │
│  (Kiểm tra)         │
└──────────┬──────────┘
           │
      ❓ OK?
           │
    ┌──────┴──────┐
    │ NO          │ YES
    ▼             ▼
┌────────┐  ┌──────────────┐
│ Sửa    │  │ Sync Thực Tế │
│ Lại    │  │              │
└────────┘  └──────┬───────┘
                   │
                   ▼
            ┌──────────────┐
            │ Kiểm tra     │
            │ Firebase     │
            │ Console      │
            └──────────────┘
```

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra console logs
2. Xem Firebase Console
3. Check file `sync_result.dart` để hiểu output

---

**Tạo bởi:** Cinema Flutter App Team
**Cập nhật:** 28/10/2025
