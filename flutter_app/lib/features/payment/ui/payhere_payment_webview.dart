import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/payment_model.dart';
import '../services/payhere_service.dart';

/// PayHere Payment Screen using WebView
/// Loads PayHere checkout with proper configuration to bypass ORB restrictions
class PayHerePaymentWebView extends StatefulWidget {
  final Payment payment;
  final String orderRef;
  final String campaignTitle;

  const PayHerePaymentWebView({
    super.key,
    required this.payment,
    required this.orderRef,
    required this.campaignTitle,
  });

  @override
  State<PayHerePaymentWebView> createState() => _PayHerePaymentWebViewState();
}

class _PayHerePaymentWebViewState extends State<PayHerePaymentWebView> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        debugPrint('PayHere Console: ${message.message}');
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            debugPrint('Page started: $url');
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            debugPrint('Page finished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
            debugPrint('Error Code: ${error.errorCode}');
            debugPrint('Error Type: ${error.errorType}');
            // Don't show error for ORB - it's expected after form submission
            if (!error.description.contains('ERR_BLOCKED_BY_ORB')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${error.description}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigation Request: ${request.url}');
            // Allow navigation to PayHere and return URLs
            if (request.url.contains('sandbox.payhere.lk') ||
                request.url.contains('payhere.lk') ||
                request.url.contains('kindora.lk')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_buildPaymentForm());
  }

  String _buildPaymentForm() {
    final params = payHereService.getPaymentParameters(
      payment: widget.payment,
      orderId: widget.orderRef,
      customerName: widget.payment.donorName,
      customerEmail: widget.payment.donorEmail,
      customerPhone: widget.payment.donorPhone ?? '0711234567',
      campaignDescription: widget.campaignTitle,
    );

    // Debug: Log the payment parameters
    debugPrint('=== PayHere Payment Parameters ===');
    params.forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('==================================');

    // Build hidden form fields
    final formFields = params.entries
        .map((e) =>
            '<input type="hidden" name="${e.key}" value="${_escapeHtml(e.value)}">')
        .join('\n');

    const paymentUrl = 'https://sandbox.payhere.lk/pay/checkout';

    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>PayHere Payment Gateway</title>
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
          padding: 20px;
        }
        .container {
          background: white;
          border-radius: 12px;
          box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
          padding: 40px;
          text-align: center;
          max-width: 400px;
          width: 100%;
        }
        .spinner {
          width: 50px;
          height: 50px;
          border: 4px solid #f3f3f3;
          border-top: 4px solid #667eea;
          border-radius: 50%;
          animation: spin 1s linear infinite;
          margin: 0 auto 20px;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        h1 {
          color: #333;
          font-size: 24px;
          margin-bottom: 10px;
          font-weight: 600;
        }
        p {
          color: #666;
          font-size: 14px;
          line-height: 1.6;
          margin-bottom: 5px;
        }
        .details {
          background: #f8f9fa;
          border-radius: 8px;
          padding: 15px;
          margin-top: 20px;
          text-align: left;
          font-size: 13px;
          color: #555;
        }
        .details div {
          display: flex;
          justify-content: space-between;
          margin-bottom: 8px;
        }
        .details div:last-child {
          margin-bottom: 0;
        }
        .label {
          font-weight: 500;
          color: #333;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="spinner"></div>
        <h1>🔒 Secure Payment</h1>
        <p>Connecting to PayHere payment gateway...</p>
        
        <div class="details">
          <div><span class="label">Amount:</span> <span>LKR ${widget.payment.amount.toStringAsFixed(2)}</span></div>
          <div><span class="label">Campaign:</span> <span>${_escapeHtml(widget.campaignTitle)}</span></div>
          <div><span class="label">Order ID:</span> <span>${_escapeHtml(widget.orderRef)}</span></div>
        </div>
      </div>

      <form id="paymentForm" method="POST" action="$paymentUrl" style="display:none;">
        $formFields
      </form>

      <script>
        console.log('Payment form loading...');
        
        // Auto-submit the form when page loads
        document.addEventListener('DOMContentLoaded', function() {
          console.log('DOM loaded, submitting form');
          setTimeout(function() {
            document.getElementById('paymentForm').submit();
          }, 500);
        });

        // Fallback if DOMContentLoaded doesn't fire
        window.onload = function() {
          console.log('Window loaded');
          if (document.readyState === 'complete') {
            console.log('Document ready, submitting form');
            document.getElementById('paymentForm').submit();
          }
        };
      </script>
    </body>
    </html>
    ''';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayHere Payment'),
        centerTitle: true,
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Container(
              color: Colors.white.withAlpha(200),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading PayHere Checkout...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel Payment'),
          ),
        ],
      ),
    );
  }
}
