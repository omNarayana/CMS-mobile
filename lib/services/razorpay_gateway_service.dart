import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/razorpay_model.dart';
import '../services/fees_service.dart';

class RazorpayGatewayService {
  final FeesApiService apiService;
  late final Razorpay _razorpay;

  // Active transaction context
  RazorpayOrderData? _activeOrder;
  Function(PaymentVerificationResult result)? _onSuccess;
  Function(String error)? _onError;

  RazorpayGatewayService({required this.apiService}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Starts full checkout flow:
  /// 1. Calls backend /create-order
  /// 2. Opens Razorpay Native/Web Checkout
  /// 3. Catches success -> calls /verify -> triggers onSuccess callback
  Future<void> startPayment({
    required String feeDemandId,
    required double amount,
    required Function(PaymentVerificationResult result) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      _onSuccess = onSuccess;
      _onError = onError;

      // 1. Create order on backend
      _activeOrder = await apiService.createRazorpayOrder(
        feeDemandId: feeDemandId,
        amount: amount,
      );

      // 2. Configure checkout options
      final options = {
        'key': _activeOrder!.keyId,
        'amount': _activeOrder!.amountInPaise,
        'name': _activeOrder!.displayName ?? 'Institution Fee Portal',
        'description': 'Fee Demand #${_activeOrder!.demandNumber}',
        'order_id': _activeOrder!.orderId,
        'prefill': {
          'contact': _activeOrder!.studentPhone,
          'email': _activeOrder!.studentEmail,
          'name': _activeOrder!.studentName,
        },
        'theme': {
          'color': _activeOrder!.themeColor ?? '#1E40AF',
        },
        'retry': {
          'enabled': true,
          'max_count': 3,
        }
      };

      // 3. Open Razorpay Gateway
      _razorpay.open(options);
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ─── Razorpay Event Callbacks ─────────────────────────────────────────────

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_activeOrder == null) return;

    try {
      // Send gateway credentials back to backend for HMAC verification
      final verification = await apiService.verifyRazorpayPayment(
        feeDemandId: _activeOrder!.demandId,
        amount: _activeOrder!.amount,
        gatewayOrderId: response.orderId ?? _activeOrder!.orderId,
        gatewayPaymentId: response.paymentId ?? '',
        gatewaySignature: response.signature ?? '',
      );

      _onSuccess?.call(verification);
    } catch (e) {
      _onError?.call('Payment received by gateway, but verification failed: $e');
    } finally {
      _activeOrder = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final msg = response.message ?? 'Payment cancelled or failed';
    _onError?.call(msg);
    _activeOrder = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _onError?.call('External wallet selected (${response.walletName}). Please complete payment.');
  }

  void dispose() {
    _razorpay.clear();
  }
}
