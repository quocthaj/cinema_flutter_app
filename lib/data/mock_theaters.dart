class Theater {
  final String id;
  final String name;
  final String address;
  final String logoUrl;
  final String description;

  Theater({
    required this.id,
    required this.name,
    required this.address,
    required this.logoUrl,
    required this.description,
  });
}

final List<Theater> mockTheaters = [
  Theater(
    id: '1',
    name: 'CGV Vincom Nguyễn Chí Thanh',
    address: '54A Nguyễn Chí Thanh, Hà Nội',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/5/5b/CGV_logo.svg',
    description:
        'Rạp CGV hiện đại với công nghệ 4DX, IMAX và dịch vụ cao cấp tại trung tâm Hà Nội.',
  ),
  Theater(
    id: '2',
    name: 'Galaxy Nguyễn Du',
    address: '116 Nguyễn Du, Quận 1, TP.HCM',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/vi/4/48/Galaxy_Cinema_logo.png',
    description:
        'Rạp Galaxy nổi tiếng với giá vé phải chăng, chất lượng âm thanh và hình ảnh tuyệt hảo.',
  ),
  Theater(
    id: '3',
    name: 'Lotte Cinema Gò Vấp',
    address: '242 Nguyễn Văn Lượng, Gò Vấp, TP.HCM',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/d8/Lotte_Cinema_logo.svg',
    description:
        'Rạp Lotte có không gian rộng, phục vụ tận tình và công nghệ chiếu phim tiên tiến.',
  ),
  Theater(
    id: '4',
    name: 'Beta Cineplex Mỹ Đình',
    address: 'Tầng 3, TTTM The Garden, Mỹ Đình, Hà Nội',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/vi/e/e8/Beta_Cineplex_logo.png',
    description:
        'Rạp Beta hướng tới giới trẻ, giá vé rẻ, phong cách trẻ trung và nhiều ưu đãi hấp dẫn.',
  ),
];
