// lib/services/seed/hardcoded_showtimes_danang_data.dart

import 'hardcoded_showtimes_data.dart';

/// ✅ REFACTORED: Showtimes Đà Nẵng với Dynamic Pricing
/// 
/// 3 rạp × 4 phòng × 6 suất = 72 templates/ngày
class HardcodedShowtimesDanangData {
  
  /// 9️⃣ CGV Vincom Đà Nẵng (4 phòng)
  static List<Map<String, dynamic>> get cgvVincomDaNangShowtimes {
    return HardcodedShowtimesData.generateTheaterShowtimes(
      theaterExternalId: 'cgv-vincom-da-nang',
      movieIds: [
        'cuc-vang-cua-ngoai',
        'tee-yod-3',
        'nha-ma-xo',
        'tron-ares',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 0,
    );
  }

  /// 🔟 Lotte Cinema Vĩnh Trung Plaza - Đà Nẵng (4 phòng)
  static List<Map<String, dynamic>> get lotteVinhTrungPlazaShowtimes {
    return HardcodedShowtimesData.generateTheaterShowtimes(
      theaterExternalId: 'lotte-vinh-trung-plaza-dn',
      movieIds: [
        'tu-chien-tren-khong',
        'van-may',
        'to-quoc-trong-tim',
        'tay-anh-giu-mot-vi-sao',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 0,
    );
  }

  /// 1️⃣1️⃣ BHD Star Lotte Mart Đà Nẵng (4 phòng)
  static List<Map<String, dynamic>> get bhdLotteMartDaNangShowtimes {
    return HardcodedShowtimesData.generateTheaterShowtimes(
      theaterExternalId: 'bhd-lotte-mart-da-nang',
      movieIds: [
        'nha-ma-xo',
        'cuc-vang-cua-ngoai',
        'tu-chien-tren-khong',
        'tee-yod-3',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 0,
    );
  }

  /// ✅ Tất cả showtimes Đà Nẵng (12 phòng × 6 suất = 72 templates)
  static List<Map<String, dynamic>> get allDaNangShowtimes => [
    ...cgvVincomDaNangShowtimes,
    ...lotteVinhTrungPlazaShowtimes,
    ...bhdLotteMartDaNangShowtimes,
  ];
}
