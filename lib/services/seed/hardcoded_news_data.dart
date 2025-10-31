// lib/services/seed/hardcoded_news_data.dart

import '../../models/news_model.dart';

class HardcodedNewsData {
  static List<NewsModel> getAllNews() {
    return [
      // ========== KHUYẾN MÃI (PROMOTIONS) ==========
      NewsModel(
        id: 'news_001',
        title: 'ĐẶT VÉ XEM PHIM ĐỒNG GIÁ - CHỈ TỪ 75K',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/66c229603b344b568f91941ead9c7991.jpg',
        content: '''Cuối năm biết toàn bom tấn đổ bộ, Lotte Cinema và VNPAY tắt tay khao ngay ưu đãi đồng giá vé cực hời.

Đoàn mình đi xem phim thì cứ mở app đặt vé trước vừa nhanh vừa hời nha!

---

- Đăng nhập App ngân hàng (Vietcombank, BIDV, Agribank, VietinBank...) và VNPAY
- Chọn tính năng đặt vé xem phim
- Chọn phim, chọn rạp Lotte Cinema, chọn suất chiếu
- Áp mã siêu hời

*Deal cho bạn mới đặt vé: Đồng giá 75K
*Deal cho bạn quen: Thứ 2 - 5: 84K | Thứ 6 - CN: 89K''',
        notes: '''*Lưu ý: Áp dụng cho vé 2D, KHÔNG áp dụng cho các phòng chiếu đặc biệt và KHÔNG áp dụng đồng thời các chương trình khuyến mại khác
Hotline dịch vụ: *6789''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 11, 30),
        category: 'promotion',
        isActive: true,
        createdAt: DateTime(2025, 10, 25),
      ),

      NewsModel(
        id: 'news_002',
        title: 'SIÊU PHẨM ĐÃ LỘ DIỆN - UBERMENSCH MERCHANDISE',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/c079fa0b32cd425e8f3958bdb0b19ae7.jpg',
        content: '''SIÊU PHẨM ĐÃ LỘ DIỆN!

Merchandise G-DRAGON ÜBERMENSCH COMBO đã lên kệ các cụm rạp LOTTE Cinema:

- Hà Nội: West Lake, Kosmo, Hà Đông, Thăng Long

- TP.HCM: Nam Sài Gòn, Gò Vấp, Cộng Hòa, Cantavil, Nowzone, Gold View, Phú Thọ (Q11), Moonlight, Thủ Đức, Dĩ An, Vũng Tàu

- Khác: Đồng Nai, Biên Hòa, Nha Trang Trần Phú, Phan Thiết, Đà Nẵng, Bắc Ninh''',
        startDate: DateTime(2025, 11, 11),
        endDate: DateTime(2025, 12, 11),
        category: 'promotion',
        isActive: true,
        createdAt: DateTime(2025, 10, 28),
      ),

      NewsModel(
        id: 'news_003',
        title: '🔥 BLACK FRIDAY DEAL CỰC CHẤT - GIÁ HỜI HẾT NẮC!',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/d53815988fbb4db1b18b4cae18bc2a4e.png',
        content: '''🔥 BLACK FRIDAY DEAL CỰC CHẤT – GIÁ HỜI HẾT NẮC! 🔥

Combo bắp + nước siêu hời nay còn hấp dẫn hơn khi đi kèm merchandise cực xịn

Chớp ngay deal "có 1-0-2", vừa thưởng thức phim vừa rinh quà về tay – chỉ trong dịp Black Friday này thôi đó!

🎬 Giới hạn số lượng – nhanh tay kẻo lỡ!''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 11, 30),
        category: 'promotion',
        isActive: true,
        createdAt: DateTime(2025, 10, 25),
      ),

      NewsModel(
        id: 'news_004',
        title: 'RA MẮT LY MỚI PHIÊN BẢN HALLOWEEN 2025',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/5bb61105185d44158c2e50326cdfa05e.jpg',
        content: '''RA MẮT LY MỚI PHIÊN BẢN HALLOWEEN 2025

Đón mùa Halloween năm nay tại rạp với nhiều phim hay cùng chiếc ly nước thiết kế đặc biệt!

Mẫu ly sẽ sớm có mặt tại tất cả cụm rạp LOTTE Cinema trên toàn quốc.''',
        startDate: DateTime(2025, 10, 25),
        endDate: DateTime(2025, 11, 5),
        category: 'promotion',
        isActive: true,
        createdAt: DateTime(2025, 10, 20),
      ),

      NewsModel(
        id: 'news_005',
        title: 'PIZZA COMBO - VỊ NGON KHÓ CƯỠNG!',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/5857f39255bf4cada4e0d50e3a191125.jpg',
        content: '''Đổi gió với Pizza Tôm nóng hổi, giòn thơm tại Lotte Cinema – vừa no bụng vừa chill cực đã:

COMBO 1: 1 bắp + 1 nước ngọt bất kỳ + 1 pizza tôm

COMBO 2: 1 bắp + 2 nước ngọt bất kỳ + 2 pizza tôm

Vị pizza tôm béo ngậy, ăn kèm bắp rang bơ quen thuộc – combo chuẩn gu một phim!''',
        notes: '''Áp dụng tại toàn bộ cụm rạp Lotte Cinema''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 11, 30),
        category: 'promotion',
        isActive: true,
        createdAt: DateTime(2025, 10, 28),
      ),

      NewsModel(
        id: 'news_006',
        title: 'MERCHANDISE KHẾ ƯỚC BÁN ĐẦU',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/471f02b5b925490c930979fdfb72e446.jpg',
        content: '''Chiếc ly đặc biệt được thiết kế với tạo hình bí ẩn, lấy cảm hứng trực tiếp từ bộ phim kinh dị Việt Nam "Khế Ước Bán Đầu" - chuyển thể từ tác phẩm cùng tên của nhà văn Thục Linh. 

Với tạo hình ma mị ấn tượng, mang đến cảm giác bí ẩn và độc đáo – cực kỳ thích hợp để sưu tầm.

Mẫu ly sẽ sớm có mặt tại tất cả cụm rạp LOTTE Cinema trên toàn quốc.''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 11, 30),
        category: 'promotion',
        isActive: true,
        createdAt: DateTime(2025, 10, 28),
      ),

      NewsModel(
        id: 'news_007',
        title: 'ƯU ĐÃI MOMO X LOTTE CINEMA',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/1ea59b8eb57c4ecea24a18163e252c16.jpg',
        content: '''Giải pháp mua trước trả sau mang đến những đãi cực shock cho khách hàng lần đầu sử dụng FUNDIIN làm phương thức thanh toán:

■  Nhập XINCHAO20 - Giảm 20% (tối đa 30K) cho đơn từ 0 đồng

■  Diễn ra từ 15.11.2024 đến khi có thông báo mới

■  Ưu đãi áp dụng cho đơn hàng đầu tiên thanh toán qua Fundiin. Chương trình áp dụng toàn bộ cụm rạp LOTTE, cả hình thức online & offline.

*Về FUNDIIN:

Fundiin là phương thức MUA TRƯỚC TRẢ SAU phổ biến nhất tại Việt Nam (Nguồn: Merchant Machine), hoàn toàn Miễn lãi cho người dùng. Với Fundiin, khách hàng có thể dễ dàng trả sau các dịch vụ tại LOTTE Cinema, thanh toán 100% giá trị đơn sau 30 ngày.

Fundiin đã thu hút tổng vốn đầu tư hơn 6.8 triệu USD, được hỗ trợ bởi các quỹ đầu tư hàng đầu như Trihill Capital, ThinkZone Ventures, Genesia Ventures, 1982 Ventures, Jafco Asia, Zone Startups Ventures. Ngoài ra, nhiều trang báo uy tín như Cafef, Cafebiz, VNEconomy, Dantri, Baodautu, TheLeader, VietnamBiz, Forbes, Nhipcaudautu, Tech in Asia và DealStreetAsia đã đưa tin về Fundiin.''',
        notes: '''- Không áp dụng cho nạp điện thoại, Medpro, VietQR''',
        startDate: DateTime(2025, 8, 14),
        endDate: DateTime(2025, 12, 31),
        category: 'promotion',
        isActive: true,
        createdAt: DateTime(2025, 8, 10),
      ),

      // ========== TIN TỨC (NEWS) ==========
      NewsModel(
        id: 'news_008',
        title: 'HOTTEOK COMBO - THÊM LỰA CHỌN ĂN VẶT MỚI',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/1d30e4289bc94096b8237cffd95b75ed.png',
        content: '''Thêm lựa chọn ăn vặt mới tại Lotte Cinema, ngọt ngào giòn rum khó cưỡng:

COMBO 1: 1 bắp + 1 nước ngọt bất kỳ + 1 bánh Hotteok (Mix cheese/ Bí đỏ/ Mozzarella)

COMBO 2: 1 bắp + 2 nước ngọt bất kỳ + 2 bánh Hotteok (Mix cheese/ Bí đỏ/ Mozzarella)

Vừa nhâm nhi bắp rang, vừa thưởng thức bánh Hotteok nóng hổi – combo hoàn hảo cho buổi xem phim trọn vị!''',
        notes: '''Áp dụng tại toàn bộ cụm rạp Lotte Cinema!''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 12, 31),
        category: 'news',
        isActive: true,
        createdAt: DateTime(2025, 10, 28),
      ),

      NewsModel(
        id: 'news_009',
        title: 'FISH CAKE COMBO - NGON NGÀO KHÓ CƯỠNG',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/34590f7f17f3429592c5919a99cf26f8.jpg',
        content: '''Thưởng thức ngay Fish Cake Combo mới lạ tại Lotte Cinema, ngọt ngào khó cưỡng:

Combo 1: 1 bắp rang bơ, 1 nước ngọt tự chọn, 1 bánh cá (Đậu đỏ / Chocolate)

Combo 2: 1 bắp rang bơ, 2 nước ngọt tự chọn, 2 bánh cá (Đậu đỏ / Chocolate)

Ăn vặt ngọt ngào – xem phim thêm hứng khởi!''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 12, 31),
        category: 'news',
        isActive: true,
        createdAt: DateTime(2025, 10, 28),
      ),

      NewsModel(
        id: 'news_010',
        title: 'COMBO ADE SIÊU HOT',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/1d1fabf8ac8345e0b81747d7ade449db.jpg',
        content: '''COMBO ADE SIÊU HOT

Chỉ có tại Lotte Cinema với 2 lựa chọn cực chill:

Combo 1: 1 bắp + 1 nước soda (Xoài/Ổi hồng/Me) + 1 bánh tráng trộn

Combo 2: 1 bắp + 2 nước soda (Xoài/Ổi hồng/Me) + 1 bánh tráng trộn

Toàn bộ cụm rạp Lotte Cinema!''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 12, 31),
        category: 'news',
        isActive: true,
        createdAt: DateTime(2025, 10, 28),
      ),

      NewsModel(
        id: 'news_011',
        title: 'KID COMBO - DÀNH RIÊNG CHO CÁC BÉ',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/3215d26ad7ed490f8a8594c124a198ef.jpg',
        content: '''Lotte Cinema mang đến combo dành riêng cho các bé:

Combo 1: 1 bắp rang bơ, 1 nước vị sữa chua Dora Drink, 1 bánh tự chọn (Lottepie / Bouchee chocolat / Socola / Cheese)

Combo 2: 1 bắp rang bơ, 1 nước vị sữa chua Dora Drink, 1 bánh tự chọn (Lottepie / Bouchee chocolat / Socola / Cheese), thêm 1 nước ngọt bất kỳ.

Vui trọn buổi xem phim – ngọt ngào vừa đủ cho bé thích mê!''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 12, 31),
        category: 'news',
        isActive: true,
        createdAt: DateTime(2025, 10, 28),
      ),

      NewsModel(
        id: 'news_012',
        title: 'JUICY COMBO - NƯỚC ÉP TRÁI CÂY TƯƠI MÁT',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/92ccf408f5ef4369a4cc8540b48f6b2f.jpg',
        content: '''Thưởng thức ngay Juicy Combo với nước ép trái cây tươi mát, cực hợp để vừa nhâm nhi vừa xem phim:

COMBO 1: 1 bắp + 1 nước (Lựu Đỏ Táo Giòn / Kiwi Táo Giòn)

COMBO 2: 1 bắp + 2 nước (Lựu Đỏ Táo Giòn / Kiwi Táo Giòn)

Giá siêu ưu đãi – ngọt thanh mát lạnh, chuẩn gu một phim!''',
        notes: '''Toàn bộ cụm rạp Lotte Cinema''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 12, 31),
        category: 'news',
        isActive: true,
        createdAt: DateTime(2025, 10, 28),
      ),

      NewsModel(
        id: 'news_013',
        title: 'CHARLOTTE - PHÒNG CHIẾU CAO CẤP',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/0d739e0fdff546cf9e658c23653c8670.jpg',
        content: '''Nằm trong hệ thống phòng chiếu cao cấp của LOTTE Cinema Việt Nam, CharLotte thuộc phân khúc sang trọng bậc nhất với trải nghiệm điện ảnh hạng "thượng gia" cho khách hàng.

⭐ Ghế ngồi đẳng cấp, sang trọng và dễ dàng điều chỉnh độ ngả theo ý muốn.

⭐ Welcome Set – Phần ăn nhẹ miễn phí tại khu vực phòng chờ riêng dành cho khách xem phòng CharLotte.

⭐ Trang bị màn hình sắc nét, âm thanh sống động và dịch vụ hỗ trợ ngay tại chỗ chỉ với 01 nút bấm.

⭐ Các dịch vụ đi kèm: Sử dụng Tủ chăn sốc giấy thông minh, chăn ấm và menu đặc biệt của CharLotte.

Hãy mau ra rạp trải nghiệm phòng chiếu cao cấp này cùng người thân & bạn bè nhé!!!''',
        notes: '''Phòng chiếu hiện đang có mặt tại cụm rạp:

LOTTE Cinema West Lake - Tầng 4 Lotte Mall West Lake Hanoi, 683 đường Lạc Long Quân, Tây Hồ, Hà Nội.''',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 12, 31),
        category: 'news',
        isActive: true,
        createdAt: DateTime(2025, 10, 28),
      ),

      NewsModel(
        id: 'news_014',
        title: 'HALLOWEEN COSPLAY FESTIVAL 2025',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/6ab98554dbfd408b8f6071f42162f7c2.jpg',
        content: '''🎃 COSPLAY XIN - NHẬN QUÀ KHỦNG!

Nhằm tạo sân chơi sáng tạo và vui nhộn dành cho khách hàng nhân dịp Halloween 2025, khuyến khích cộng đồng yêu điện ảnh thể hiện cá tính qua cosplay và lan tỏa tinh thần lễ hội cùng TNT Cinema.

*Gửi ảnh qua link BTC.

* Kêu gọi tương tác (React, Comment, Share) khi ảnh được đăng trên Fanpage TNT Cinema để tích điểm.

Cách tính điểm (Top 10 tổng điểm cao nhất thắng giải):

* React = 1 điểm * Comment = 3 điểm * Share (công khai) = 5 điểm

10 GIẢI XUẤT SẮC NHẤT: 1 năm xem phim miễn phí (24 vé) + 1 năm sử dụng bắp Harmony (12 voucher).

10 GIẢI KHUYẾN KHÍCH: Mỗi giải 01 cặp vé xem phim.

Đối tượng: Khách hàng từ 13 tuổi trở lên, chụp ảnh cosplay tại rạp TNT Cinema.

Thời gian:
*Gửi ảnh dự thi: 29/10 – 02/11/2025

*Bình chọn (tính điểm): 04/11 – 09/11/2025

*Công bố kết quả: 10/11/2025

Phạm vi: Tất cả các rạp TNT Cinema trên toàn quốc.

Cách thức tham gia:
*Cosplay và chụp ảnh tại rạp (29/10 – /10).''',
        notes: '''Người tham gia không được sử dụng các hành vi gian lận, bao gồm nhưng không giới hạn ở việc: sử dụng tài khoản ảo, công cụ tự động tăng tương tác, mua like/share/comment hoặc thao túng kết quả.
BTC có quyền kiểm tra, xác minh và loại bỏ các bài dự thi vi phạm thể lệ.
Khi tham gia, người dự thi đồng ý cho phép TNT Cinema sử dụng hình ảnh và tên hiển thị cho mục đích truyền thông, quảng bá mà không cần thêm bất kỳ khoản phí nào.
Quyết định của TNT Cinema là quyết định cuối cùng.''',
        startDate: DateTime(2025, 10, 29),
        endDate: DateTime(2025, 11, 11),
        category: 'news',
        isActive: true,
        createdAt: DateTime(2025, 10, 18),
      ),

      NewsModel(
        id: 'news_015',
        title: 'MUA TRƯỚC - TRẢ SAU CÙNG FUNDIIN',
        imageUrl: 'https://media.lottecinemavn.com/Media/Event/6381da64610745ac878c1ae9930f2b73.jpg',
        content: '''**Cách nhận quà:

1.Tải ứng dụng MoMo và đăng ký tài khoản mới.

2.Vào mục Ưu đãi → Nhập mã, nhập mã: MOMOLOTTE.

3.Liên kết tài khoản ngân hàng + nạp tối thiểu 10.000đ.

4.Hoàn tất xác thực sinh trắc học (CCCD gắn chip + khuôn mặt).


**Quà tặng: Thẻ quà 135.000đ để đổi combo bắp nước Harmony tại LOTTE Cinema.

**Thời gian áp dụng: 14/08/2025 – 31/12/2025 (hoặc đến khi có thông báo mới).''',
        notes: '''-Chi áp dụng cho khách hàng mới lần đầu liên kết ngân hàng với MoMo.

-Mỗi khách hàng chỉ được nhận 01 lần duy nhất (1 tài khoản MoMo / 1 CCCD / 1 ngân hàng / 1 thiết bị).

-Không áp dụng đồng thời với ưu đãi khách hàng mới khác.''',
        startDate: DateTime(2025, 8, 14),
        endDate: DateTime(2025, 12, 31),
        category: 'promotion',
        isActive: true,
        createdAt: DateTime(2025, 8, 10),
      ),
    ];
  }

  /// Lấy chỉ tin khuyến mãi
  static List<NewsModel> getPromotions() {
    return getAllNews().where((news) => news.category == 'promotion').toList();
  }

  /// Lấy chỉ tin tức
  static List<NewsModel> getNews() {
    return getAllNews().where((news) => news.category == 'news').toList();
  }

  /// Lấy tin còn hiệu lực
  static List<NewsModel> getActiveNews() {
    return getAllNews().where((news) => news.isValid).toList();
  }
}
