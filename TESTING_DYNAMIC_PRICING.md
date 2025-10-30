# 🧪 TESTING GUIDE - DYNAMIC PRICING

**Version:** 1.0.0  
**Date:** 30/10/2025

---

## 🎯 TEST SCENARIOS

### Scenario 1: Cheapest Ticket (48,000đ)
**Setup:**
- Screen: **Standard**
- Movie: **2D** (Cục Vàng Của Ngoại)
- Time: **09:00** (Morning)
- Day: **Weekday** (Monday-Friday)
- Seat: **Standard** (Front rows A-F)

**Expected Price:**
```
60,000 × 1.0 × 1.0 × 0.8 × 1.0 × 1.0 = 48,000đ ✅
```

**How to Test:**
1. Go to **Movies** → Select **"Cục Vàng Của Ngoại"**
2. Select any **Standard theater** (not VIP/IMAX)
3. Select **09:00** showtime on **Monday-Friday**
4. Select seat **A1** (standard, front row)
5. Verify price shows **48,000đ**

---

### Scenario 2: Most Expensive Ticket (242,000đ)
**Setup:**
- Screen: **IMAX**
- Movie: **3D** (Tron Ares)
- Time: **19:00** (Evening - Giờ vàng)
- Day: **Weekend** (Saturday/Sunday)
- Seat: **VIP** (Back rows in IMAX)

**Expected Price:**
```
60,000 × 1.5 × 1.3 × 1.2 × 1.15 × 1.5 = 242,000đ ✅
```

**How to Test:**
1. Go to **Movies** → Select **"Tron Ares"**
2. Select **CGV Vincom Bà Triệu** (has IMAX)
3. Select **19:00** showtime on **Saturday/Sunday**
4. Select seat **H10** (VIP, back row)
5. Verify price shows **242,000đ**

---

### Scenario 3: Weekend Surcharge Test
**Setup:**
- Same screen, movie, time, seat
- Compare **Weekday** vs **Weekend**

**Expected:**
```
Weekday:  60,000 × factors × 1.0  = 100,000đ
Weekend:  60,000 × factors × 1.15 = 115,000đ
Difference: +15,000đ (+15%) ✅
```

**How to Test:**
1. Select same movie + theater + time
2. Select showtime on **Wednesday** → Note price
3. Select showtime on **Saturday** → Note price
4. Verify Saturday price is **15% higher**

---

### Scenario 4: Time-Based Pricing Test
**Setup:**
- Same screen, movie, day (Weekday), seat (Standard)
- Compare different time slots

**Expected:**
```
09:00 (Morning):   60,000 × 0.8 = 48,000đ
11:30 (Lunch):     60,000 × 0.9 = 54,000đ
14:00 (Afternoon): 60,000 × 1.0 = 60,000đ
16:30 (Afternoon): 60,000 × 1.0 = 60,000đ
19:00 (Evening):   60,000 × 1.2 = 72,000đ ⭐
21:30 (Night):     60,000 × 1.1 = 66,000đ
```

**How to Test:**
1. Select same movie + theater + day (Monday)
2. For each time slot, select standard seat
3. Note prices for each time
4. Verify **19:00 is most expensive** (Giờ vàng)

---

### Scenario 5: Screen Type Pricing Test
**Setup:**
- Same movie (2D), time (14:00), day (Weekday), seat type (Standard)
- Compare different screen types

**Expected:**
```
Standard:  60,000 × 1.0 = 60,000đ
VIP:       60,000 × 1.2 = 72,000đ
IMAX:      60,000 × 1.5 = 90,000đ
```

**How to Test:**
1. Select movie **"Cục Vàng Của Ngoại"** (2D)
2. Select **14:00** showtime on **Monday**
3. Try at different theaters:
   - **Galaxy Nguyễn Du** (Standard) → 60,000đ
   - **CGV Vincom** (VIP room) → 72,000đ
   - **CGV Vincom** (IMAX room) → 90,000đ

---

### Scenario 6: Seat Type Pricing Test
**Setup:**
- Same screen (Standard), movie (2D), time (14:00), day (Weekday)
- Compare Standard seat vs VIP seat

**Expected:**
```
Standard seat (A1-F10): 60,000 × 1.0 = 60,000đ
VIP seat (G1-H10):      60,000 × 1.5 = 90,000đ
```

**How to Test:**
1. Select Standard theater, 2D movie, 14:00, Weekday
2. Select seat **A1** → Note price (60,000đ)
3. Select seat **G1** → Note price (90,000đ)
4. Verify VIP seat is **50% more expensive**

---

### Scenario 7: 3D Movie Surcharge Test
**Setup:**
- Same screen (Standard), time (14:00), day (Weekday), seat (Standard)
- Compare 2D vs 3D movie

**Expected:**
```
2D:  60,000 × 1.0 = 60,000đ
3D:  60,000 × 1.3 = 78,000đ
Difference: +18,000đ (+30%) ✅
```

**How to Test:**
1. Select **"Cục Vàng Của Ngoại"** (2D) → 60,000đ
2. Select **"Tử Chiến Trên Không"** (3D) → 78,000đ
3. Verify 3D is **30% more expensive**

---

## 🧮 PRICE CALCULATOR

Use this to calculate expected price:

```dart
BASE_PRICE = 60,000đ

// 1. Screen Type
if (IMAX)    multiplier1 = 1.5
if (VIP)     multiplier1 = 1.2
if (Standard) multiplier1 = 1.0

// 2. Movie Type
if (3D)      multiplier2 = 1.3
if (2D)      multiplier2 = 1.0

// 3. Time of Day
if (06:00-11:59) multiplier3 = 0.8  // Morning
if (12:00-13:59) multiplier3 = 0.9  // Lunch
if (14:00-17:59) multiplier3 = 1.0  // Afternoon
if (18:00-21:59) multiplier3 = 1.2  // Evening ⭐
if (22:00-05:59) multiplier3 = 1.1  // Night

// 4. Day of Week
if (Sat/Sun) multiplier4 = 1.15
else         multiplier4 = 1.0

// 5. Seat Type
if (VIP seat G-H) multiplier5 = 1.5
else               multiplier5 = 1.0

// TOTAL
PRICE = 60,000 × m1 × m2 × m3 × m4 × m5
FINAL = round(PRICE / 1000) × 1000  // Round to nearest 1,000
```

---

## 📊 EXPECTED PRICE RANGE

| Scenario | Price | Notes |
|----------|-------|-------|
| **Cheapest** | 48,000đ | Standard, 2D, Morning, Weekday, Standard seat |
| **Average** | 72,000đ | Standard, 2D, Evening, Weekday, Standard seat |
| **Weekend** | 83,000đ | Standard, 2D, Evening, Weekend, Standard seat |
| **3D Movie** | 93,000đ | Standard, 3D, Evening, Weekday, Standard seat |
| **VIP Seat** | 108,000đ | Standard, 2D, Evening, Weekday, VIP seat |
| **IMAX** | 108,000đ | IMAX, 2D, Evening, Weekday, Standard seat |
| **Premium** | 161,000đ | IMAX, 3D, Evening, Weekend, Standard seat |
| **Most Expensive** | 242,000đ | IMAX, 3D, Evening, Weekend, VIP seat |

---

## 🐛 COMMON ISSUES

### Issue 1: Price not updating
**Symptom:** Price stays the same when changing seat  
**Solution:** Make sure seat type is read from `Screen.seats[].type`

### Issue 2: Weekend pricing not applied
**Symptom:** Saturday/Sunday prices same as weekday  
**Solution:** Check `startTime.weekday == DateTime.saturday` logic

### Issue 3: Wrong seat type detection
**Symptom:** Front row shows VIP price  
**Solution:** Verify seat generation logic - VIP should be rows G-H (index 6-7)

### Issue 4: Price too high/low
**Symptom:** Price doesn't match expected  
**Solution:** 
1. Check all 5 multipliers are applied
2. Verify rounding logic (nearest 1,000)
3. Check base price is 60,000

---

## ✅ VALIDATION CHECKLIST

Before marking as complete:

- [ ] Test cheapest price (48,000đ) works
- [ ] Test most expensive price (242,000đ) works
- [ ] Weekend prices are 15% higher
- [ ] Evening prices are 20% higher than afternoon
- [ ] Morning prices are 20% lower than afternoon
- [ ] 3D movies are 30% more expensive than 2D
- [ ] IMAX is 50% more expensive than Standard
- [ ] VIP room is 20% more expensive than Standard
- [ ] VIP seats are 50% more expensive than Standard seats
- [ ] Prices are rounded to nearest 1,000

---

## 🎓 DEVELOPER NOTES

### How to add new price rule
```dart
// In HardcodedShowtimesData.calculatePrice()

// Example: Add holiday surcharge
if (isHoliday) {
  price *= 1.25; // +25% on holidays
}
```

### How to change base price
```dart
// In HardcodedShowtimesData
static const double BASE_PRICE = 70000; // Change from 60k to 70k
```

### How to modify multipliers
```dart
// Current
if (hour >= 18 && hour < 22) price *= 1.2; // Evening +20%

// New (higher evening price)
if (hour >= 18 && hour < 22) price *= 1.3; // Evening +30%
```

---

**Happy Testing! 🧪✨**
