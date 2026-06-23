import 'dart:convert';
import 'package:crypto/crypto.dart';

class VnpayService {
  static const String _tmnCode = '2QX152N2';
  static const String _hashSecret = '9UDB1Q8K8G69V1VFL6DHM8D11U8M11E5';
  static const String _vnpayUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String returnUrl = 'http://localhost/vnpay-return';

  String generatePaymentUrl({required String orderId, required double amountInUsd}) {
    // Quy đổi 1 USD = 1 VND để dễ test theo yêu cầu
    final amountInVnd = amountInUsd;
    // Số tiền nhân 100 theo chuẩn VNPAY
    final vnpAmount = (amountInVnd * 100).toInt();

    final now = DateTime.now();
    final createDate = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}'
        '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';

    final params = <String, dynamic>{
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': _tmnCode,
      'vnp_Amount': vnpAmount.toString(),
      'vnp_CreateDate': createDate,
      'vnp_CurrCode': 'VND',
      'vnp_IpAddr': '127.0.0.1',
      'vnp_Locale': 'vn',
      'vnp_OrderInfo': 'Thanh toan don hang $orderId',
      'vnp_OrderType': 'other',
      'vnp_ReturnUrl': returnUrl,
      'vnp_TxnRef': orderId,
    };

    final sortedKeys = params.keys.toList()..sort();
    final queryComponents = <String>[];

    for (final key in sortedKeys) {
      final value = params[key]!.toString();
      // VNPAY yêu cầu ký tự khoảng trắng được mã hóa thành %20 thay vì +
      final encodedValue = Uri.encodeQueryComponent(value).replaceAll('+', '%20');
      queryComponents.add('$key=$encodedValue');
    }

    final query = queryComponents.join('&');

    // Ký bảo mật HMAC-SHA512
    final keyBytes = utf8.encode(_hashSecret);
    final queryBytes = utf8.encode(query);
    final hmac = Hmac(sha512, keyBytes);
    final secureHash = hmac.convert(queryBytes).toString();

    // Trả về URL hoàn chỉnh
    return '$_vnpayUrl?$query&vnp_SecureHash=$secureHash';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
