// lib/services/seed/hardcoded_showtimes_hcm_data.dart

import 'hardcoded_showtimes_data.dart';

/// ✅ REFACTORED: Showtimes TP.HCM với Dynamic Pricing
/// 
/// 4 rạp × 4-5 phòng × 6 suất = ~108 templates/ngày
class HardcodedShowtimesHCMData {
  
  /// 5️⃣ CGV Vincom Đồng Khởi - HCM (5 phòng: có IMAX)
  static List<Map<String, dynamic>> get cgvDongKhoiShowtimes {
    return HardcodedShowtimesData.generateTheaterShowtimes(
      theaterExternalId: 'cgv-vincom-dong-khoi-hcm',
      movieIds: [
        'tee-yod-3',
        'nha-ma-xo',
        'cuc-vang-cua-ngoai',
        'tay-anh-giu-mot-vi-sao',
        'tron-ares',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 1,
    );
  }

  /// 6️⃣ CGV Landmark 81 - HCM (5 phòng: có IMAX)
  static List<Map<String, dynamic>> get cgvLandmark81Showtimes {
    return HardcodedShowtimesData.generateTheaterShowtimes(
      theaterExternalId: 'cgv-landmark-81-hcm',
      movieIds: [
        'van-may',
        'to-quoc-trong-tim',
        'tu-chien-tren-khong',
        'tee-yod-3',
        'tron-ares',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 1,
    );
  }

  /// 7️⃣ Lotte Cinema Nam Sài Gòn - HCM (4 phòng)
  static List<Map<String, dynamic>> get lotteNamSaigonShowtimes {
    return HardcodedShowtimesData.generateTheaterShowtimes(
      theaterExternalId: 'lotte-nam-saigon-hcm',
      movieIds: [
        'cuc-vang-cua-ngoai',
        'nha-ma-xo',
        'tu-chien-tren-khong',
        'tay-anh-giu-mot-vi-sao',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 0,
    );
  }

  /// 8️⃣ Galaxy Cinema Nguyễn Du - HCM (4 phòng)
  static List<Map<String, dynamic>> get galaxyNguyenDuHCMShowtimes {
    return HardcodedShowtimesData.generateTheaterShowtimes(
      theaterExternalId: 'galaxy-nguyen-du-hcm',
      movieIds: [
        'van-may',
        'to-quoc-trong-tim',
        'tee-yod-3',
        'nha-ma-xo',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 0,
    );
  }

  /// ✅ Tất cả showtimes HCM (18 phòng × 6 suất = 108 templates)
  static List<Map<String, dynamic>> get allHCMShowtimes => [
    ...cgvDongKhoiShowtimes,
    ...cgvLandmark81Showtimes,
    ...lotteNamSaigonShowtimes,
    ...galaxyNguyenDuHCMShowtimes,
  ];
}
