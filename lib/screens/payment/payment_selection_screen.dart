// lib/screens/payment/payment_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Dùng để lấy Service (nếu bạn cung cấp)
// Import các file chúng ta vừa tạo
import 'package:doan_mobile/models/payment_model.dart';
import 'package:doan_mobile/services/payment_service.dart';
import 'transaction_status_screen.dart'; // Màn hình chờ kết quả
// Import theme
import 'package:doan_mobile/config/theme.dart';
import 'package:intl/intl.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  // final String userId; // Không cần nữa vì Service tự lấy từ Auth

  const PaymentSelectionScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  // Khởi tạo service (hoặc lấy từ Provider nếu bạn đã setup)
  late final PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    // Lấy service từ Provider (nếu bạn đã setup ở main.dart)
    _paymentService = Provider.of<PaymentService>(context, listen: false);
    // Hoặc khởi tạo mới nếu không dùng Provider
    // _paymentService = PaymentService();
  }

  // Đây là dữ liệu ví mẫu cho UI, bạn có thể thêm ZaloPay, VNPay...
  final List<EWalletConfig> _eWallets = [
    EWalletConfig(
        gatewayId: 'momo',
        name: 'Ví MoMo',
        logoAssetPath: 'assets/images/momo_logo.png' // Đảm bảo bạn có ảnh này
        ),
    // EWalletConfig(
    //   gatewayId: 'vnpay',
    //   name: 'VNPAY',
    //   logoAssetPath: 'assets/images/vnpay_logo.png'
    // ),
  ];

  EWalletConfig? _selectedWallet;
  bool _isLoading = false;

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  /// Bước 1 & 2: Gọi PaymentService
  Future<void> _handlePayment() async {
    if (_selectedWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chọn phương thức thanh toán.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Gọi hàm processPayment
    final String? paymentDocId = await _paymentService.processPayment(
      bookingId: widget.bookingId,
      amount: widget.amount,
      gateway: _selectedWallet!.gatewayId,
    );

    setState(() => _isLoading = false);

    // Bước 6: Xử lý kết quả
    if (paymentDocId != null && mounted) {
      // Nếu thành công (đã mở MoMo), điều hướng đến màn hình chờ
      Navigator.pushReplacement(
        // Dùng pushReplacement để không quay lại màn hình chọn
        context,
        MaterialPageRoute(
            builder: (_) => TransactionStatusScreen(
                  paymentDocId: paymentDocId, // Truyền ID qua
                )),
      );
    } else if (mounted) {
      // Nếu có lỗi (trả về null)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Khởi tạo thanh toán thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn phương thức thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Số tiền cần thanh toán:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormatter.format(widget.amount),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text('Chọn ví điện tử:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _eWallets.length,
                itemBuilder: (context, index) {
                  final wallet = _eWallets[index];
                  return PaymentMethodCard(
                    wallet: wallet,
                    isSelected: _selectedWallet?.gatewayId == wallet.gatewayId,
                    onTap: () {
                      setState(() {
                        _selectedWallet = wallet;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || _selectedWallet == null)
                    ? null
                    : _handlePayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        'Thanh toán ${_selectedWallet != null ? "qua ${_selectedWallet!.name}" : ""}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Card (Giữ nguyên)
class PaymentMethodCard extends StatelessWidget {
  final EWalletConfig wallet;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.wallet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[700]!,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: ListTile(
        // SỬA: Dùng Image.asset (đảm bảo bạn đã thêm ảnh vào assets)
        leading: Image.asset(wallet.logoAssetPath,
            height: 40,
            width: 40,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.payment, size: 40)), // Fallback
        title: Text(wallet.name),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
            : const Icon(Icons.circle_outlined, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
