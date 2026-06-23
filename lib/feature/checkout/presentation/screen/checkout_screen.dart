import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_app/feature/cart/presentation/cubit/cart_cubit.dart';
import 'package:e_commerce_app/feature/cart/presentation/cubit/cart_state.dart';
import 'package:e_commerce_app/feature/checkout/presentation/screen/order_success_screen.dart';
import 'package:e_commerce_app/feature/checkout/data/service/vnpay_service.dart';
import 'package:e_commerce_app/feature/checkout/presentation/screen/vnpay_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Credit Card Controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String _paymentMethod = 'cod'; // 'cod', 'bank', 'card'
  late final String _orderId;

  @override
  void initState() {
    super.initState();
    // Tạo mã đơn hàng ngẫu nhiên
    final random = Random();
    _orderId = 'ORD-${random.nextInt(900000) + 100000}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _submitOrder(double totalAmount) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_paymentMethod == 'card') {
      if (_cardNumberController.text.isEmpty ||
          _cardHolderController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin thẻ tín dụng'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (_paymentMethod == 'vnpay') {
      final vnpayService = VnpayService();
      final paymentUrl = vnpayService.generatePaymentUrl(
        orderId: _orderId,
        amountInUsd: totalAmount,
      );

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => VnpayPaymentScreen(paymentUrl: paymentUrl),
        ),
      );

      if (result != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán VNPAY không thành công hoặc đã bị hủy'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    // Đặt hàng thành công:
    // 1. Lưu thông tin đơn hàng (giả lập hoặc truyền sang màn success)
    // 2. Clear giỏ hàng
    if (mounted) {
      context.read<CartCubit>().clearCart();

      // 3. Điều hướng đến trang Success và loại bỏ màn checkout khỏi navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(orderId: _orderId),
        ),
        (route) => route.isFirst, // Giữ lại HomeScreen ở dưới cùng
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('Không có sản phẩm để thanh toán'));
          }

          const double shippingFee = 2.0;
          final totalAmount = state.totalPrice + shippingFee;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('1. Thông tin giao hàng'),
                  _buildShippingForm(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('2. Phương thức thanh toán'),
                  _buildPaymentMethodSelector(totalAmount),
                  const SizedBox(height: 20),
                  _buildSectionTitle('3. Tóm tắt đơn hàng'),
                  _buildOrderSummary(state, shippingFee, totalAmount),
                  const SizedBox(height: 30),
                  _buildSubmitButton(totalAmount),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildShippingForm() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Họ và tên người nhận',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Vui lòng nhập số điện thoại' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Địa chỉ giao hàng',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Vui lòng nhập địa chỉ nhận hàng' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector(double totalAmount) {
    return Column(
      children: [
        _buildPaymentMethodCard(
          method: 'cod',
          title: 'Thanh toán khi nhận hàng (COD)',
          subtitle: 'Thanh toán bằng tiền mặt khi shipper giao hàng',
          icon: Icons.local_shipping_outlined,
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodCard(
          method: 'bank',
          title: 'Chuyển khoản ngân hàng (QR)',
          subtitle: 'Hiển thị mã QR và thông tin chuyển khoản tài khoản',
          icon: Icons.qr_code_scanner_outlined,
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodCard(
          method: 'vnpay',
          title: 'Cổng thanh toán VNPAY (Sandbox)',
          subtitle: 'Thanh toán qua ví VNPAY hoặc tài khoản ngân hàng thử nghiệm',
          icon: Icons.payment_outlined,
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodCard(
          method: 'card',
          title: 'Thẻ quốc tế Credit / Debit',
          subtitle: 'Hỗ trợ thẻ Visa, Mastercard, JCB...',
          icon: Icons.credit_card_outlined,
        ),
        if (_paymentMethod == 'bank') ...[
          const SizedBox(height: 12),
          _buildBankTransferDetails(totalAmount),
        ] else if (_paymentMethod == 'card') ...[
          const SizedBox(height: 12),
          _buildCreditCardForm(),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required String method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F766E) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF0F766E).withAlpha(20), blurRadius: 6)]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? const Color(0xFF0F766E) : Colors.grey.shade600,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: method,
              groupValue: _paymentMethod,
              activeColor: const Color(0xFF0F766E),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankTransferDetails(double totalAmount) {
    final formattedAmount = '${totalAmount.toStringAsFixed(2)} \$';
    final content = 'CK $_orderId';

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'THÔNG TIN CHUYỂN KHOẢN',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
            ),
            const SizedBox(height: 12),
            _buildInfoRowCopy('Ngân hàng', 'Vietcombank', copyable: false),
            _buildInfoRowCopy('Chủ tài khoản', 'CONG TY TNHH E-COMMERCE', copyable: false),
            _buildInfoRowCopy('Số tài khoản', '9988228833', copyText: '9988228833'),
            _buildInfoRowCopy('Số tiền', formattedAmount, copyText: totalAmount.toStringAsFixed(2)),
            _buildInfoRowCopy('Nội dung chuyển khoản', content, copyText: content),
            const Divider(height: 24),
            // Mã QR Mô phỏng cực kì cao cấp
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Quét mã để thanh toán nhanh',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  // Mock QR code design
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0F766E), width: 2),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 130,
                            color: Colors.grey.shade900,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_cart,
                              color: Color(0xFF0F766E),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hệ thống tự động duyệt sau khi nhận được tiền.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowCopy(String label, String value, {bool copyable = true, String? copyText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
            ),
          ),
          if (copyable && copyText != null)
            GestureDetector(
              onTap: () => _copyToClipboard(copyText, 'Đã sao chép: $value'),
              child: const Icon(
                Icons.copy,
                size: 16,
                color: Color(0xFF0F766E),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NHẬP THÔNG TIN THẺ',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Số thẻ quốc tế',
                hintText: '0000 0000 0000 0000',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardHolderController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Tên in trên thẻ',
                hintText: 'NGUYEN VAN A',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _CardExpiryFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Ngày hết hạn',
                      hintText: 'MM/YY',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Mã CVV',
                      hintText: '***',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartState state, double shippingFee, double totalAmount) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // List rút gọn các sản phẩm
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.title} (x${item.quantity})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${item.totalPrice.toStringAsFixed(2)} \$',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tạm tính',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                Text(
                  '${state.totalPrice.toStringAsFixed(2)} \$',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Phí vận chuyển',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                Text(
                  '${shippingFee.toStringAsFixed(2)} \$',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng số tiền',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                Text(
                  '${totalAmount.toStringAsFixed(2)} \$',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(double totalAmount) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: () => _submitOrder(totalAmount),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0F766E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          _paymentMethod == 'vnpay'
              ? 'Thanh toán qua VNPAY'
              : _paymentMethod == 'bank'
                  ? 'Xác nhận Đã chuyển khoản & Đặt hàng'
                  : 'Đặt hàng ngay (${totalAmount.toStringAsFixed(2)} \$)',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

// Card formatting helper classes
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      int nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      int nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
