// import 'package:dio/dio.dart';
// import '../models/fees_model.dart';
// import '../core/network/dio_client.dart';
//
// class FeesApiService {
//   final Dio _dio = DioClient.dio;
//
//   /// Fetch aggregated fee dashboard data by calling two real endpoints in parallel:
//   /// GET /v1/student/portal/fees/demands   -> fee invoices / demands
//   /// GET /v1/student/portal/fees/payments  -> payment transaction history
//   Future<FeeDashboardData> fetchFeeDashboard() async {
//     try {
//       // Execute both requests in parallel for better performance
//       final results = await Future.wait([
//         _fetchDemands(),
//         _fetchPayments(),
//       ]);
//
//       final invoices = results[0] as List<FeeInvoice>;
//       final transactions = results[1] as List<FeeTransaction>;
//
//       // Calculate overview totals from the list of demands/invoices
//       double totalFees = 0;
//       double totalPaid = 0;
//       double totalDue = 0;
//       double totalConcession = 0;
//
//       for (final inv in invoices) {
//         totalFees += inv.amount;
//         totalPaid += inv.paid;
//         totalDue += inv.due;
//         totalConcession += inv.concession;
//       }
//
//       final overview = FeeOverview(
//         totalFees: totalFees,
//         totalPaid: totalPaid,
//         totalDue: totalDue,
//         totalConcession: totalConcession,
//         // If your model has a currency field, you can set it here
//         currency: invoices.isNotEmpty ? 'INR' : 'INR',
//       );
//
//       return FeeDashboardData(
//         overview: overview,
//         invoices: invoices,
//         transactions: transactions,
//         concessions: const [],
//       );
//     } on DioException catch (e) {
//       final message = e.response?.data?['message'] ?? 'Failed to load fee dashboard';
//       throw Exception(message);
//     }
//   }
//
//   /// GET /v1/student/portal/fees/demands
//   Future<List<FeeInvoice>> _fetchDemands() async {
//     final response = await _dio.get('/v1/student/portal/fees/demands');
//
//     // Accessing 'data' based on your JSON structure: {"status": true, "data": [...]}
//     final List<dynamic> data = response.data['data'] ?? [];
//
//     return data
//         .map((json) => FeeInvoice.fromJson(json as Map<String, dynamic>))
//         .toList();
//   }
//
//   /// GET /v1/student/portal/fees/payments
//   Future<List<FeeTransaction>> _fetchPayments() async {
//     try {
//       final response = await _dio.get('/v1/student/portal/fees/payments');
//
//       final List<dynamic> data = response.data['data'] ?? [];
//
//       return data
//           .map((json) => FeeTransaction.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       // Return empty list if payments fail to load to prevent crashing the whole dashboard
//       return [];
//     }
//   }
//
//   /// GET /v1/student/portal/fees/receipts/:id
//   Future<Map<String, dynamic>> fetchReceipt(String paymentId) async {
//     try {
//       final response = await _dio.get('/v1/student/portal/fees/receipts/$paymentId');
//       return (response.data['data'] as Map<String, dynamic>?) ?? {};
//     } on DioException catch (e) {
//       throw Exception('Failed to fetch receipt: ${e.message}');
//     }
//   }
// }

import 'package:dio/dio.dart';
import '../models/fees_model.dart';
import '../models/razorpay_model.dart';
import '../core/network/dio_client.dart';

class FeesApiService {
  final Dio _dio = DioClient.dio;

  /// Fetches complete fee dashboard & ledger in a single call.
  /// Hits: GET /v1/student/portal/fees/ledger
  /// Returns: summary (totals), demands (invoices), payments (transactions), and student info.
  Future<FeeDashboardData> fetchFeeDashboard() async {
    try {
      final response = await _dio.get('/v1/student/portal/fees/ledger');

      final payload = response.data['data'] ?? response.data;
      if (payload is Map<String, dynamic>) {
        return FeeDashboardData.fromJson(payload);
      }

      throw Exception('Invalid response format from fee ledger API.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Access unauthorized (${e.response?.statusCode}). Please log in again.');
      }
      // If ledger route is ever unavailable, gracefully fallback to separate calls
      return await _fetchFallback();
    } catch (e) {
      // Fallback in case of parsing or unexpected errors
      return await _fetchFallback();
    }
  }

  /// Fallback: calls /fees/demands and /fees/payments in parallel if ledger endpoint fails
  Future<FeeDashboardData> _fetchFallback() async {
    try {
      final results = await Future.wait([
        _fetchDemands(),
        _fetchPayments(),
      ]);

      final invoices = results[0] as List<FeeInvoice>;
      final transactions = results[1] as List<FeeTransaction>;

      double totalBilled = 0;
      double totalPaid = 0;
      double totalDue = 0;
      double totalDiscount = 0;

      for (final inv in invoices) {
        totalBilled += inv.amount;
        totalPaid += inv.paid;
        totalDue += inv.due;
        totalDiscount += inv.concession;
      }

      return FeeDashboardData(
        overview: FeeOverview(
          totalFees: totalBilled,
          totalPaid: totalPaid,
          totalDue: totalDue,
          totalConcession: totalDiscount,
          currency: 'INR',
        ),
        invoices: invoices,
        transactions: transactions,
        concessions: const [],
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Access unauthorized (${e.response?.statusCode}). Please log in.');
      }
      throw Exception(e.response?.data?['message'] ?? 'Failed to load fee dashboard data.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// GET /v1/student/portal/fees/demands
  Future<List<FeeInvoice>> _fetchDemands() async {
    final response = await _dio.get('/v1/student/portal/fees/demands');
    final List<dynamic> data = response.data['data'] ?? [];
    return data
        .map((json) => FeeInvoice.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET /v1/student/portal/fees/payments
  Future<List<FeeTransaction>> _fetchPayments() async {
    try {
      final response = await _dio.get('/v1/student/portal/fees/payments');
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((json) => FeeTransaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// GET /v1/student/portal/fees/receipts/:id
  Future<Map<String, dynamic>> fetchReceipt(String paymentId) async {
    try {
      final response = await _dio.get('/v1/student/portal/fees/receipts/$paymentId');
      return (response.data['data'] as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch receipt: ${e.message}');
    }
  }

  /// 1. Create Razorpay order on backend
  /// POST /v1/student/portal/fees/pay/create-order
  Future<RazorpayOrderData> createRazorpayOrder({
    required String feeDemandId,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/student/portal/fees/pay/create-order',
        data: {
          'fee_demand': feeDemandId,
          'amount': amount,
          'provider': 'RAZORPAY',
        },
      );

      final payload = response.data['data'] ?? response.data;
      return RazorpayOrderData.fromJson(payload as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Failed to create payment order';
      throw Exception(errorMsg);
    }
  }

  /// 2. Verify Razorpay payment signature & receive official receipt
  /// POST /v1/student/portal/fees/pay/verify
  Future<PaymentVerificationResult> verifyRazorpayPayment({
    required String feeDemandId,
    required double amount,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String gatewaySignature,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/student/portal/fees/pay/verify',
        data: {
          'fee_demand': feeDemandId,
          'amount': amount,
          'gateway_order_id': gatewayOrderId,
          'gateway_payment_id': gatewayPaymentId,
          'gateway_signature': gatewaySignature,
          'provider': 'RAZORPAY',
        },
      );

      return PaymentVerificationResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Payment verification failed';
      throw Exception(errorMsg);
    }
  }

}
