import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:e_commerce_app/feature/checkout/data/service/vnpay_service.dart';

class VnpayPaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const VnpayPaymentScreen({super.key, required this.paymentUrl});

  @override
  State<VnpayPaymentScreen> createState() => _VnpayPaymentScreenState();
}

class _VnpayPaymentScreenState extends State<VnpayPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
            _checkReturnUrl(url);
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
            _checkReturnUrl(url);
          },
          onNavigationRequest: (request) {
            if (_checkReturnUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _checkReturnUrl(String url) {
    if (url.startsWith(VnpayService.returnUrl)) {
      final uri = Uri.parse(url);
      final responseCode = uri.queryParameters['vnp_ResponseCode'];
      
      // Response code '00' đại diện cho giao dịch thành công trong hệ thống VNPAY
      if (responseCode == '00') {
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context, false);
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cổng thanh toán VNPAY'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0F766E),
              ),
            ),
        ],
      ),
    );
  }
}
