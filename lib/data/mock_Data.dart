import '../models/movie.dart';

final List<Movie> mockMovies = [
  // 1. Phim Nổi bật 1 (Rating cao)
  Movie(
    id: "1",
    title: "Tử Chiến Trên Không",
    genre: "Action",
    duration: 118,
    rating: 9.8,
    posterUrl: "lib/images/poster1.jpg",
    status: "now_showing",
    releaseDate: "2025-09-19",
    description: "Trận chiến cuối cùng bảo vệ bầu trời khỏi thế lực xâm lược.",
  ),

  // 2. Phim Nổi bật 2 (Rating cao)
  Movie(
    id: "3",
    title: "Avengers: Endgame",
    genre: "Action",
    duration: 180,
    rating: 9.0,
    posterUrl: "lib/images/AvengersEndgame.jpg",
    status: "now_showing",
    releaseDate: "2019-04-26",
    description: "Trận chiến cuối cùng giữa Avengers và Thanos, hy vọng cuối cùng của vũ trụ.",
  ),

  // 3. Phim Sắp chiếu
  Movie(
    id: "2",
    title: "Batman: Kỵ Sĩ Bóng Đêm",
    genre: "Action/Crime",
    duration: 150,
    rating: 8.5,
    posterUrl: "lib/images/batman.jpg",
    status: "coming_soon",
    releaseDate: "2025-11-01",
    description: "Bruce Wayne đối đầu kẻ thù nguy hiểm nhất trong thành phố tội lỗi Gotham.",
  ),

  // --- THÊM MỚI ---

  // 4. Phim Đang chiếu (Hoạt hình)
  Movie(
    id: "4",
    title: "Vương Quốc Băng Giá II",
    genre: "Animation",
    duration: 103,
    rating: 7.9,
    posterUrl: "lib/images/frozen2.jpg", // Thay bằng ảnh thực tế
    status: "now_showing",
    releaseDate: "2019-11-22",
    description: "Elsa và Anna dấn thân vào một cuộc phiêu lưu mới vượt ra ngoài Arendelle.",
  ),

  // 5. Phim Đang chiếu (Kinh dị)
  Movie(
    id: "5",
    title: "Lời Nguyền Sa Mạc",
    genre: "Horror",
    duration: 95,
    rating: 6.5,
    posterUrl: "lib/images/horror1.jpg", // Thay bằng ảnh thực tế
    status: "now_showing",
    releaseDate: "2024-10-31",
    description: "Một nhóm bạn khám phá ra một bí mật cổ xưa bị chôn vùi dưới cát.",
  ),

  // 6. Phim Sắp chiếu (Hài hước)
  Movie(
    id: "6",
    title: "Đại Chiến Hàng Xóm",
    genre: "Comedy",
    duration: 105,
    rating: 7.2,
    posterUrl: "lib/images/comedy1.jpg", // Thay bằng ảnh thực tế
    status: "coming_soon",
    releaseDate: "2025-12-20",
    description: "Cuộc chiến không hồi kết giữa hai gia đình hàng xóm láng giềng.",
  ),

  // 7. Phim Đang chiếu (Lãng mạn)
  Movie(
    id: "7",
    title: "Mùa Hè Năm Ấy",
    genre: "Romance",
    duration: 110,
    rating: 8.1, // Rating cao để đôi khi xuất hiện ở mục nổi bật
    posterUrl: "lib/images/romance1.jpg", // Thay bằng ảnh thực tế
    status: "now_showing",
    releaseDate: "2024-07-01",
    description: "Một câu chuyện tình yêu vượt thời gian và những hiểu lầm lãng mạn.",
  ),
  
  // 8. Phim Sắp chiếu (Khoa học viễn tưởng)
  Movie(
    id: "8",
    title: "Hành Tinh Lạ",
    genre: "Sci-Fi",
    duration: 140,
    rating: 7.5,
    posterUrl: "lib/images/scifi1.jpg", // Thay bằng ảnh thực tế
    status: "coming_soon",
    releaseDate: "2026-01-15",
    description: "Phi hành đoàn khám phá một hành tinh mới với những sinh vật kỳ bí.",
  ),

  // 9. Phim Đang chiếu (Phần tiếp theo của phim nổi bật)
  Movie(
    id: "9",
    title: "Tử Chiến Trên Không II",
    genre: "Action",
    duration: 125,
    rating: 8.9, // Rating cao để xuất hiện ở mục nổi bật
    posterUrl: "lib/images/poster2.jpg", // Thay bằng ảnh thực tế
    status: "now_showing",
    releaseDate: "2025-10-10",
    description: "Phần tiếp theo gay cấn, trận chiến không gian mở rộng.",
  ),

  // 10. Phim Đang chiếu (Cổ trang)
  Movie(
    id: "10",
    title: "Đế Vương Chi Mộng",
    genre: "Historical",
    duration: 130,
    rating: 7.8,
    posterUrl: "lib/images/historical1.jpg", // Thay bằng ảnh thực tế
    status: "now_showing",
    releaseDate: "2024-05-01",
    description: "Cuộc đời thăng trầm của một vị vua trẻ xây dựng đế chế.",
  ),
];