# 🧪 Test Script cho Sync Data

## 📋 Checklist Test

### ✅ Test 1: Kiểm tra Dry Run
- [ ] Mở app trên emulator
- [ ] Vào Admin → Seed Data Screen
- [ ] Nhấn "Kiểm tra thay đổi (Dry Run)"
- [ ] Xem console logs
- [ ] Verify: Database KHÔNG thay đổi
- [ ] Verify: Hiển thị số liệu Added/Updated/Deleted/Unchanged

### ✅ Test 2: Sync Lần Đầu (Add All)
- [ ] Database trống hoàn toàn
- [ ] Nhấn "Đồng bộ thực tế"
- [ ] Đợi hoàn thành
- [ ] Verify Firebase Console:
  - [ ] 15 movies
  - [ ] 18 theaters
  - [ ] Document IDs = externalIds

### ✅ Test 3: Sync Lần 2 (Unchanged)
- [ ] Không sửa gì trong seed data
- [ ] Nhấn "Kiểm tra thay đổi"
- [ ] Verify: "Không đổi: 33" (15 movies + 18 theaters)
- [ ] Nhấn "Đồng bộ thực tế"
- [ ] Verify: Không có thay đổi nào

### ✅ Test 4: Update Movie
**Trước test:**
```dart
// Backup rating hiện tại của "Avatar 3"
// lib/services/seed/movie_seed_data.dart
{
  "externalId": "avatar-3",
  "title": "Avatar 3: Lửa Và Tro Tàn",
  "rating": 0.0,  // ← Ghi nhớ giá trị này
}
```

**Bước test:**
1. Sửa rating thành 9.5
2. Save file
3. Hot reload app (hoặc restart)
4. Dry Run → Verify: "Cập nhật: 1"
5. Sync thực tế
6. Firebase Console → movies/avatar-3 → rating = 9.5 ✅

### ✅ Test 5: Add New Movie
```dart
// Thêm vào cuối list movies:
{
  "externalId": "test-movie-2025",
  "title": "Test Movie 2025",
  "genre": "Test",
  "duration": 120,
  "rating": 8.0,
  "status": "now_showing",
  "releaseDate": "28/10/2025",
  "description": "Movie để test sync",
  "posterUrl": "https://example.com/poster.jpg",
  "trailerUrl": "https://www.youtube.com/watch?v=test",
  "director": "Test Director",
  "cast": "Test Cast",
  "language": "Tiếng Việt",
  "ageRating": "P",
}
```

**Bước test:**
1. Thêm movie như trên
2. Save → Hot reload
3. Dry Run → "Thêm mới: 1"
4. Sync thực tế
5. Firebase → movies/test-movie-2025 exists ✅
6. Vào UI app → Kiểm tra movie hiển thị

### ✅ Test 6: Delete Movie
**⚠️ CHÚ Ý: Test này sẽ XÓA movie khỏi database!**

1. Xóa movie "test-movie-2025" khỏi seed data
2. Save → Hot reload
3. Dry Run → "Xóa: 1"
4. Sync thực tế
5. Firebase → movies/test-movie-2025 gone ✅

### ✅ Test 7: Multiple Operations
**Chuẩn bị:**
- Update 2 movies (rating)
- Add 1 movie mới
- Delete 1 movie cũ

**Verify:**
- Dry Run: "Thêm: 1, Cập nhật: 2, Xóa: 1"
- Sync thực tế
- Kiểm tra Firebase: All changes applied ✅

### ✅ Test 8: Error Handling (Movie thiếu externalId)
```dart
// Thêm movie SAI (không có externalId):
{
  "title": "Movie Lỗi",  // ← Thiếu externalId
  "genre": "Test",
}
```

**Verify:**
- Console logs: "Movie thiếu externalId: Movie Lỗi"
- Movie này bị skip
- Các movies khác vẫn sync bình thường

### ✅ Test 9: Performance (Batch Operations)
**Nếu có > 500 movies:**
- Verify: Tự động chia batch
- Verify: Không timeout
- Verify: Console logs hiển thị tiến độ

### ✅ Test 10: Legacy Mode (Backward Compatibility)
1. Nhấn "Thêm tất cả dữ liệu mẫu" (Legacy)
2. Verify: Vẫn hoạt động bình thường
3. Check: Không conflict với Sync mode

## 🎯 Test Results Template

```
┌─────────────────────────────────────────┐
│  SYNC DATA TEST RESULTS                 │
├─────────────────────────────────────────┤
│ Test 1: Dry Run                    [ ✅ ] │
│ Test 2: Sync First Time            [ ✅ ] │
│ Test 3: Sync Unchanged             [ ✅ ] │
│ Test 4: Update Movie               [ ✅ ] │
│ Test 5: Add New Movie              [ ✅ ] │
│ Test 6: Delete Movie               [ ✅ ] │
│ Test 7: Multiple Operations        [ ✅ ] │
│ Test 8: Error Handling             [ ✅ ] │
│ Test 9: Performance                [ ✅ ] │
│ Test 10: Legacy Mode               [ ✅ ] │
├─────────────────────────────────────────┤
│ OVERALL:                           PASS  │
└─────────────────────────────────────────┘
```

## 📸 Screenshots to Take

1. Dry Run Result Screen
2. Sync Success Screen
3. Firebase Console - Before Sync
4. Firebase Console - After Sync
5. App UI - Movies List Updated

## 🐛 Bug Report Template

Nếu gặp bug, báo cáo theo template:

```markdown
### Bug Description
[Mô tả ngắn gọn]

### Steps to Reproduce
1. ...
2. ...
3. ...

### Expected Behavior
[Kết quả mong đợi]

### Actual Behavior
[Kết quả thực tế]

### Console Logs
```
[Paste console logs here]
```

### Environment
- Device: [Emulator/Physical]
- OS: [Android/iOS]
- Flutter Version: [flutter --version]
```

## 🎓 Tips

1. **Luôn kiểm tra console logs** - Thông tin chi tiết nhất
2. **Firebase Console** - Verify data changes
3. **Hot Reload** - Sau khi sửa seed data
4. **Backup** - Trước khi test Delete operations

## 📝 Notes

- Mỗi test nên làm độc lập
- Restore database về trạng thái ban đầu sau mỗi test
- Document kết quả test
- Báo cáo bugs/issues ngay

---

**Tester:** _______________
**Date:** _______________
**Build:** _______________
