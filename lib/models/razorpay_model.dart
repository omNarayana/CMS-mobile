/// Data received from /v1/student/portal/fees/pay/create-order
class RazorpayOrderData {
  final String orderId;
  final double amount;
  final int amountInPaise;
  final String currency;
  final String keyId;
  final String? displayName;
  final String? themeColor;
  final String studentName;
  final String studentEmail;
  final String studentPhone;
  final String demandId;
  final String demandNumber;

  RazorpayOrderData({
    required this.orderId,
    required this.amount,
    required this.amountInPaise,
    required this.currency,
    required this.keyId,
    this.displayName,
    this.themeColor,
    required this.studentName,
    required this.studentEmail,
    required this.studentPhone,
    required this.demandId,
    required this.demandNumber,
  });

  factory RazorpayOrderData.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>? ?? {};
    final demand = json['demand'] as Map<String, dynamic>? ?? {};

    return RazorpayOrderData(
      orderId: json['order_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountInPaise: (json['amount_in_paise'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      keyId: json['key_id']?.toString() ?? '',
      displayName: json['display_name']?.toString(),
      themeColor: json['theme_color']?.toString() ?? '#1E40AF',
      studentName: student['name']?.toString() ?? '',
      studentEmail: student['email']?.toString() ?? '',
      studentPhone: student['phone']?.toString() ?? '',
      demandId: demand['id']?.toString() ?? '',
      demandNumber: demand['demand_number']?.toString() ?? '',
    );
  }
}

/// Verification result returned by /v1/student/portal/fees/pay/verify
class PaymentVerificationResult {
  final bool success;
  final String message;
  final String receiptNo;
  final double amount;

  PaymentVerificationResult({
    required this.success,
    required this.message,
    required this.receiptNo,
    required this.amount,
  });

  factory PaymentVerificationResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return PaymentVerificationResult(
      success: json['status'] == true,
      message: json['message']?.toString() ?? 'Payment verified successfully',
      receiptNo: data['receipt_no']?.toString() ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
