// lib/services/seed/hardcoded_theaters_data.dart

/// Dữ liệu CỨNG cho Theaters
/// 
/// ✅ 11 rạp: 4 Hà Nội + 4 TP.HCM + 3 Đà Nẵng
/// ✅ Mỗi rạp có externalId duy nhất
/// ✅ Địa chỉ thực tế và chính xác
class HardcodedTheatersData {
  
  /// 🏢 4 rạp tại Hà Nội
  static List<Map<String, dynamic>> get hanoiTheaters => [
    {
      "externalId": "cgv-vincom-ba-trieu-hn",
      "name": "CGV Vincom Center Bà Triệu",
      "address": "Tầng 5, Vincom Center, 191 Bà Triệu, Hai Bà Trưng, Hà Nội",
      "city": "Hà Nội",
      "phone": "1900 6017",
    },
    {
      "externalId": "bhd-vincom-pham-ngoc-thach-hn",
      "name": "BHD Star Vincom Phạm Ngọc Thạch",
      "address": "Tầng 6, Vincom Center, 2 Phạm Ngọc Thạch, Đống Đa, Hà Nội",
      "city": "Hà Nội",
      "phone": "1900 2099",
    },
    {
      "externalId": "lotte-west-lake-hn",
      "name": "Lotte Cinema West Lake",
      "address": "Tầng 3, Lotte Center, 54 Liễu Giai, Ba Đình, Hà Nội",
      "city": "Hà Nội",
      "phone": "1900 5555",
    },
    {
      "externalId": "galaxy-nguyen-du-hn",
      "name": "Galaxy Cinema Nguyễn Du",
      "address": "116 Nguyễn Du, Hai Bà Trưng, Hà Nội",
      "city": "Hà Nội",
      "phone": "1900 2224",
    },
  ];

  /// 🏢 4 rạp tại TP.HCM
  static List<Map<String, dynamic>> get hcmTheaters => [
    {
      "externalId": "cgv-vincom-dong-khoi-hcm",
      "name": "CGV Vincom Đồng Khởi",
      "address": "Tầng 4, Vincom Center B, 72 Lê Thánh Tôn, Quận 1, TP.HCM",
      "city": "TP.HCM",
      "phone": "1900 6017",
    },
    {
      "externalId": "cgv-landmark-81-hcm",
      "name": "CGV Landmark 81",
      "address": "Tầng 5, Vinhomes Central Park, 720A Điện Biên Phủ, Bình Thạnh, TP.HCM",
      "city": "TP.HCM",
      "phone": "1900 6017",
    },
    {
      "externalId": "lotte-nam-saigon-hcm",
      "name": "Lotte Cinema Nam Sài Gòn",
      "address": "Tầng 3, TTTM Lotte Mart, 469 Nguyễn Hữu Thọ, Quận 7, TP.HCM",
      "city": "TP.HCM",
      "phone": "1900 5555",
    },
    {
      "externalId": "galaxy-nguyen-du-hcm",
      "name": "Galaxy Cinema Nguyễn Du",
      "address": "116 Nguyễn Du, Quận 1, TP.HCM",
      "city": "TP.HCM",
      "phone": "1900 2224",
    },
  ];

  /// 🏢 3 rạp tại Đà Nẵng
  static List<Map<String, dynamic>> get daNangTheaters => [
    {
      "externalId": "cgv-vincom-da-nang",
      "name": "CGV Vincom Đà Nẵng",
      "address": "Tầng 5, Vincom Plaza Đà Nẵng, 910A Ngô Quyền, Sơn Trà, Đà Nẵng",
      "city": "Đà Nẵng",
      "phone": "1900 6017",
    },
    {
      "externalId": "lotte-vinh-trung-plaza-dn",
      "name": "Lotte Cinema Vĩnh Trung Plaza",
      "address": "Tầng 4, Vĩnh Trung Plaza, 255-257 Hùng Vương, Đà Nẵng",
      "city": "Đà Nẵng",
      "phone": "1900 5555",
    },
    {
      "externalId": "bhd-lotte-mart-da-nang",
      "name": "BHD Star Lotte Mart Đà Nẵng",
      "address": "Tầng 3, Lotte Mart, 06 Nại Nam, Hòa Cường Bắc, Hải Châu, Đà Nẵng",
      "city": "Đà Nẵng",
      "phone": "1900 2099",
    },
  ];

  /// ✅ Tất cả rạp (11 rạp)
  static List<Map<String, dynamic>> get allTheaters => [
    ...hanoiTheaters,
    ...hcmTheaters,
    ...daNangTheaters,
  ];
}
