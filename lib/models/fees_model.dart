import 'package:intl/intl.dart';

/// Fees module data models reflecting backend SIS fee structures.
class FeeDashboardData {
  final FeeOverview overview;
  final List<FeeInvoice> invoices;
  final List<FeeTransaction> transactions;
  final List<FeeConcession> concessions;

  FeeDashboardData({
    required this.overview,
    required this.invoices,
    required this.transactions,
    required this.concessions,
  });

  // factory FeeDashboardData.fromJson(Map<String, dynamic> json) {
  //   return FeeDashboardData(
  //     overview: FeeOverview.fromJson(json['overview'] ?? {}),
  //     invoices: (json['invoices'] as List? ?? [])
  //         .map((i) => FeeInvoice.fromJson(i))
  //         .toList(),
  //     transactions: (json['transactions'] as List? ?? [])
  //         .map((t) => FeeTransaction.fromJson(t))
  //         .toList(),
  //     concessions: (json['concessions'] as List? ?? [])
  //         .map((c) => FeeConcession.fromJson(c))
  //         .toList(),
  //   );
  // }
  factory FeeDashboardData.fromJson(Map<String, dynamic> json) {
    // The ledger API returns "summary", "demands", and "payments"
    final summaryMap = json['summary'] as Map<String, dynamic>? ?? {};
    final rawDemands = json['demands'] as List? ?? [];
    final rawPayments = json['payments'] as List? ?? [];

    return FeeDashboardData(
      overview: FeeOverview.fromJson(summaryMap),
      invoices: rawDemands
          .map((i) => FeeInvoice.fromJson(i as Map<String, dynamic>))
          .toList(),
      transactions: rawPayments
          .map((t) => FeeTransaction.fromJson(t as Map<String, dynamic>))
          .toList(),
      concessions: const [], // Map if available in ledger
    );
  }

}

class FeeOverview {
  final double totalFees;
  final double totalPaid;
  final double totalDue;
  final double totalConcession;
  final String currency;

  FeeOverview({
    required this.totalFees,
    required this.totalPaid,
    required this.totalDue,
    required this.totalConcession,
    this.currency = 'INR',
  });

  double get paidPercentage =>
      totalFees > 0 ? (totalPaid / totalFees).clamp(0.0, 1.0) : 0.0;

  // factory FeeOverview.fromJson(Map<String, dynamic> json) {
  //   return FeeOverview(
  //     totalFees: (json['total_fees'] as num?)?.toDouble() ?? 0.0,
  //     totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
  //     totalDue: (json['total_due'] as num?)?.toDouble() ?? 0.0,
  //     totalConcession: (json['total_concession'] as num?)?.toDouble() ?? 0.0,
  //     currency: json['currency']?.toString() ?? 'INR',
  //   );
  // }
  factory FeeOverview.fromJson(Map<String, dynamic> json) {
    return FeeOverview(
      // Match the "summary" keys from your log: totalBilled, totalPaid, totalDue, totalDiscount
      totalFees: (json['totalBilled'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0.0,
      totalConcession: (json['totalDiscount'] as num?)?.toDouble() ?? 0.0,
      currency: 'INR',
    );
  }
}

class FeeInvoice {
  final String id;
  final String invoiceNumber;
  final String academicYear;
  final String termName;
  final double amount;
  final double paid;
  final double due;
  final double concession;
  final String status;
  final DateTime? dueDate;
  final List<FeeLineItem> lineItems;

  FeeInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.academicYear,
    required this.termName,
    required this.amount,
    required this.paid,
    required this.due,
    required this.concession,
    required this.status,
    this.dueDate,
    this.lineItems = const [],
  });

  bool get isOverdue =>
      status == 'OVERDUE' ||
          (due > 0 && dueDate != null && dueDate!.isBefore(DateTime.now()));

  // factory FeeInvoice.fromJson(Map<String, dynamic> json) {
  //   return FeeInvoice(
  //     id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
  //     invoiceNumber: json['demand_number']?.toString() ?? '',
  //     academicYear: json['academic_year'] is Map
  //         ? json['academic_year']['name']?.toString() ?? ''
  //         : '',
  //     termName: json['academic_term'] is Map
  //         ? json['academic_term']['name']?.toString() ?? ''
  //         : '',
  //     status: json['status']?.toString() ?? '',
  //     dueDate: DateTime.tryParse(json['due_date']?.toString() ?? ''),
  //     amount: (json['total_original_amount'] as num?)?.toDouble() ?? 0.0,
  //     paid: (json['total_paid_amount'] as num?)?.toDouble() ?? 0.0,
  //     due: (json['balance_amount'] as num?)?.toDouble() ?? 0.0,
  //     concession: (json['total_discount'] as num?)?.toDouble() ?? 0.0,
  //     lineItems: (json['items'] as List? ?? [])
  //         .map((item) => FeeLineItem.fromJson(item))
  //         .toList(),
  //   );
  // }
  // factory FeeInvoice.fromJson(Map<String, dynamic> json) {
  //   return FeeInvoice(
  //     id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
  //     invoiceNumber: json['demand_number']?.toString() ?? '',
  //     // Extract academic year name safely from the nested object
  //     academicYear: json['academic_year'] is Map
  //         ? json['academic_year']['name']?.toString() ?? ''
  //         : json['academic_year']?.toString() ?? '',
  //     // Extract term name safely from the nested object
  //     termName: json['academic_term'] is Map
  //         ? json['academic_term']['name']?.toString() ?? ''
  //         : json['academic_term']?.toString() ?? '',
  //     amount: (json['total_original_amount'] as num?)?.toDouble() ??
  //         (json['totalBilled'] as num?)?.toDouble() ?? 0.0,
  //     paid: (json['total_paid_amount'] as num?)?.toDouble() ?? 0.0,
  //     due: (json['balance_amount'] as num?)?.toDouble() ?? 0.0,
  //     concession: (json['total_discount'] as num?)?.toDouble() ?? 0.0,
  //     status: json['status']?.toString() ?? '',
  //     // Don't forget to parse the due_date as well
  //     dueDate: DateTime.tryParse(json['due_date']?.toString() ?? ''),
  //     lineItems: (json['items'] as List? ?? [])
  //         .map((e) => FeeLineItem.fromJson(e as Map<String, dynamic>))
  //         .toList(),
  //   );
  // }
  factory FeeInvoice.fromJson(Map<String, dynamic> json) {
    return FeeInvoice(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      invoiceNumber: json['demand_number']?.toString() ?? '',
      academicYear: json['academic_year'] is Map
          ? json['academic_year']['name']?.toString() ?? ''
          : json['academic_year']?.toString() ?? '',
      termName: json['academic_term'] is Map
          ? json['academic_term']['name']?.toString() ?? ''
          : json['academic_term']?.toString() ?? '',
      amount: (json['net_payable_amount'] as num?)?.toDouble() ??
          (json['total_original_amount'] as num?)?.toDouble() ??
          (json['totalBilled'] as num?)?.toDouble() ??
          0.0,

      // ✅ FIX: Read `paid_amount`
      paid: (json['paid_amount'] as num?)?.toDouble() ??
          (json['total_paid_amount'] as num?)?.toDouble() ??
          0.0,

      // ✅ FIX: Read `due_amount`
      due: (json['due_amount'] as num?)?.toDouble() ??
          (json['balance_amount'] as num?)?.toDouble() ??
          0.0,

      concession: (json['total_discount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      dueDate: DateTime.tryParse(json['due_date']?.toString() ?? ''),
      lineItems: (json['items'] as List? ?? [])
          .map((e) => FeeLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

}

class FeeLineItem {
  final String name;
  final String? category;
  final double amount;
  final double concession;

  FeeLineItem({
    required this.name,
    this.category,
    required this.amount,
    this.concession = 0.0,
  });

  factory FeeLineItem.fromJson(Map<String, dynamic> json) {
    // Maps to nested 'fee_head' object found in SIS backend
    final feeHead = json['fee_head'] as Map<String, dynamic>?;

    return FeeLineItem(
      name: feeHead?['name']?.toString() ?? 'Fee Component',
      category: feeHead?['type']?.toString(),
      amount: (json['original_amount'] as num?)?.toDouble() ?? 0.0,
      concession: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FeeTransaction {
  final String id;
  final String transactionId; // Maps to receipt_no
  final double amount;
  final String mode; // Maps to payment_method
  final String status; // Helper for UI: Hardcoded to 'SUCCESS'
  final DateTime? date; // Maps to paid_at
  final String? remarks; // Maps to gateway_payment_id

  // Metadata from nested fee_demand
  final String? demandNumber;
  final String? academicYear;
  final String? termName;

  FeeTransaction({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.mode,
    required this.status,
    this.date,
    this.remarks,
    this.demandNumber,
    this.academicYear,
    this.termName,
  });

  factory FeeTransaction.fromJson(Map<String, dynamic> json) {
    // Safe navigation of the nested fee_demand object
    final demand = json['fee_demand'] is Map<String, dynamic>
        ? json['fee_demand'] as Map<String, dynamic>
        : <String, dynamic>{};

    final academicYearName = demand['academic_year'] is Map
        ? demand['academic_year']['name']?.toString()
        : null;

    final termNameVal = demand['academic_term'] is Map
        ? demand['academic_term']['name']?.toString()
        : null;

    return FeeTransaction(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      transactionId: json['receipt_no']?.toString() ?? 'N/A',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      mode: json['payment_method']?.toString() ?? 'CASH',
      // The backend doesn't return status because a receipt implies success.
      // We hardcode it here so the UI (FeesScreen) can apply success styling.
      status: 'SUCCESS',
      date: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
      remarks: json['gateway_payment_id']?.toString(),
      demandNumber: demand['demand_number']?.toString(),
      academicYear: academicYearName,
      termName: termNameVal,
    );
  }
}

class FeeConcession {
  final String id;
  final String name;
  final String type;
  final double amount;
  final String? academicYear;

  FeeConcession({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.academicYear,
  });

  factory FeeConcession.fromJson(Map<String, dynamic> json) {
    final year = json['academic_year'];
    return FeeConcession(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Concession',
      type: json['type']?.toString() ?? 'DISCOUNT',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      academicYear: year is Map ? year['name']?.toString() : year?.toString(),
    );
  }
}