import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/new_and_promotion.dart';
import '../home/bottom_nav_bar.dart';
import '../movie/movie_screen.dart';
import '../theater/theaters_screen.dart';
import '../home/home_screen.dart';
import '../reward/reward_screen.dart';
import 'news_details.dart';

class NewsAndPromotionsPage extends StatefulWidget {
  const NewsAndPromotionsPage({super.key});

  @override
  State<NewsAndPromotionsPage> createState() => _NewsAndPromotionsPageState();
}

class _NewsAndPromotionsPageState extends State<NewsAndPromotionsPage> {
  int _currentIndex = 4;

  /// 🔥 Lấy dữ liệu từ Firestore (collection: posts)
  Stream<List<New>> getPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => New.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// 🔹 Upload nhiều bài viết mẫu (news + promotion)
  void uploadSamplePosts() async {
    final List<Map<String, dynamic>> samplePosts = [
      {
        'title': 'Giảm 50% vé xem phim thứ 3',
        'content': 'Áp dụng cho tất cả các rạp vào thứ 3 hàng tuần.',
        'imageUrl':'https://www.galaxycine.vn/media/2024/2/7/1800x1200_1707310837547.jpg',
        'createdAt': Timestamp.now(),
        'type': 'promotion',
      },
      {
        'title': 'Tin tức: Phim mới ra mắt tháng 11',
        'content': 'Thông tin về các bộ phim mới chuẩn bị công chiếu.',
        'imageUrl': 'https://cdn-media.sforum.vn/storage/app/media/wp-content/uploads/2023/10/phim-chieu-rap-thang-11-2023-thumb.jpg',
        'createdAt': Timestamp.now(),
        'type': 'news',
      },
      {
        'title': 'Khuyến mãi combo bắp + nước',
        'content': 'Mua combo bắp + nước giảm 30% vào cuối tuần.',
        'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaJfRJsvcr_XATwXb8wWbi9Ow4Ofh0qX_tLg&s',
        'createdAt': Timestamp.now(),
        'type': 'promotion',
      },
      {
        'title': 'Tin nóng: Lịch chiếu phim bom tấn',
        'content': 'Cập nhật lịch chiếu của các phim bom tấn trong tháng.',
        'imageUrl': 'https://aeonmall-review-rikkei.cdn.vccloud.vn/public/wp/16/editors/8RSDusmIaAFztmEi5s0XXgIDDDDSNCII9EBC87cG.png',
        'createdAt': Timestamp.now(),
        'type': 'news',
      },
      {
        'title': 'Khuyến mãi đặc biệt cuối tháng',
        'content': 'Giảm 20% tất cả vé xem phim cho khách hàng VIP.',
        'imageUrl': 'https://scontent.fsgn2-9.fna.fbcdn.net/v/t39.30808-6/488910096_1069547325207054_6324108308942983011_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeG4aO3ilkEdShS-8N_6Y3f_cXrNtX3uXyNxes21fe5fI59fxKA0g9BoDm_7n4I0SVYoF4lw77isVIML3NBqsugP&_nc_ohc=Q2-nA0rhzQ8Q7kNvwHu4i-3&_nc_oc=AdmDdhBQXtn5wVuI0fBzlShF91upF53Ym28AmJbD3I4Om1VmZ5e_dvSci2htFKfOYOQ&_nc_zt=23&_nc_ht=scontent.fsgn2-9.fna&_nc_gid=7qdsDRxJapecZSGimRovSQ&oh=00_Afd8Iqisd4B1_uxnjMhV-mRRh2TtWGRUF0WO1dZ00TacOQ&oe=69092E8A',
        'createdAt': Timestamp.now(),
        'type': 'promotion',
      },
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance.collection('posts');

      for (var post in samplePosts) {
        final docRef = collection.doc();
        batch.set(docRef, post);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã upload dữ liệu mẫu thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tin tức & Khuyến mãi'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: uploadSamplePosts,
            tooltip: "Upload dữ liệu mẫu",
          )
        ],
      ),

      /// 🔄 Nội dung chính
      body: StreamBuilder<List<New>>(
        stream: getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Hiện chưa có tin tức hoặc khuyến mãi nào.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailsPage(
                          promotion: {
                            'title': post.title,
                            'content': post.content,
                            'image': post.imageUrl,
                            'date':
                                '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                          },
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🖼 Ảnh bài viết
                      Stack(
                        children: [
                          Image.network(
                            post.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey[800],
                                child: const Icon(Icons.broken_image, color: Colors.white),
                              );
                            },
                          ),
                          // 🔖 Badge loại bài
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: post.type == 'promotion'
                                    ? Colors.redAccent
                                    : Colors.blueAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                post.type == 'promotion' ? "Khuyến mãi" : "Tin mới",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📰 Tiêu đề
                            Text(
                              post.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // 🗓 Ngày đăng
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, color: Colors.white54, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}",
                                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      /// 🔻 Thanh điều hướng dưới
      bottomNavigationBar: BottomNavBar(
        initialIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const MovieScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const RewardScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const TheatersScreen()));
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}
