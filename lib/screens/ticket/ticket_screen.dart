import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/ticket.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách vé đã đặt (dữ liệu giả)
    final List<Ticket> userTickets = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé của tôi'),
        centerTitle: true,
      ),
      body: userTickets.isEmpty
          ? _buildEmptyState(context)
          : _buildTicketList(context, userTickets),
    );
  }

  // Widget khi không có vé
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_activity_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Bạn chưa có vé nào',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy bắt đầu đặt vé và trải nghiệm phim hay!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // Widget danh sách vé
  Widget _buildTicketList(BuildContext context, List<Ticket> tickets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _buildTicketCard(context, ticket);
      },
    );
  }

  // Widget cho mỗi vé
  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ticket.movie.posterUrl,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        width: 80,
                        height: 120,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 120,
                        color: AppTheme.cardColor,
                        child: const Icon(
                          Icons.movie_creation_outlined,
                          color: Colors.white54,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.movie.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.calendar_today,
                          '${ticket.showtime.date} - ${ticket.showtime.time}'),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.theaters, ticket.showtime.theater),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                          Icons.chair, 'Ghế: ${ticket.seats.join(', ')}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${ticket.totalPrice.toStringAsFixed(0)} VNĐ',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppTheme.primaryColor, fontSize: 18),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondaryColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
