import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formattedDate = '${today.day}/${today.month}/${today.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Checkmark animation wrapper
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF0F766E),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đặt hàng thành công!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cảm ơn bạn đã tin tưởng mua sắm tại E-Commerce. Đơn hàng của bạn đã được tiếp nhận và đang xử lý.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Invoice-like detail box
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CHI TIẾT ĐƠN HÀNG',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F766E),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildReceiptRow('Mã đơn hàng', orderId, highlight: true),
                      _buildReceiptRow('Ngày đặt hàng', formattedDate),
                      _buildReceiptRow('Trạng thái', 'Chờ xử lý', isStatus: true),
                      _buildReceiptRow('Phương thức giao hàng', 'Giao hàng tiêu chuẩn'),
                      const Divider(height: 24),
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nhân viên vận chuyển sẽ liên hệ xác nhận hành trình giao hàng qua số điện thoại của bạn.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Bottom primary actions
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    // Quay về HomeScreen (giữ lại HomeScreen ở dưới cùng)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục mua sắm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool highlight = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD97706),
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight ? const Color(0xFF0F766E) : const Color(0xFF111827),
              ),
            ),
        ],
      ),
    );
  }
}
