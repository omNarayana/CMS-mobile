import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/fees_model.dart';
import '../providers/fees_provider.dart';
import '../theme/academic_theme.dart';
import '../services/razorpay_gateway_service.dart';
import '../widgets/pay_fee_button.dart';
import '../services/fees_service.dart';

class FeesScreen extends ConsumerStatefulWidget {
  const FeesScreen({super.key});

  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RazorpayGatewayService _razorpayService;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _razorpayService = RazorpayGatewayService(apiService: FeesApiService());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feesAsync = ref.watch(feesDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AcademicTheme.backgroundDark : AcademicTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Fees & Payments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: feesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AcademicTheme.primaryLight),
          ),
          error: (err, _) => _buildError(isDark, err.toString()),
          data: (data) => _buildContent(data, isDark),
        ),
      ),
    );
  }

  // Renamed from _buildBody to _buildContent to fix the error
  Widget _buildContent(FeeDashboardData data, bool isDark) {
    return Column(
      children: [
        _buildOverviewCard(data.overview, isDark),
        _buildTabBar(isDark),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInvoicesTab(data.invoices, isDark),
              _buildTransactionsTab(data.transactions, isDark),
              _buildConcessionsTab(data.concessions, isDark),
            ],
          ),
        ),
      ],
    );
  }

  // --- UI Components ---

  Widget _buildOverviewCard(FeeOverview overview, bool isDark) {
    final currency = overview.currency == 'INR' ? '₹' : overview.currency;
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AcademicTheme.academicHeaderGradient,
        borderRadius: AcademicTheme.borderRadiusMd,
        boxShadow: AcademicTheme.darkCardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                const Text('Fee Summary', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                _buildOverviewStatusPill(overview, currency, fmt),
              ],
            ),
            const SizedBox(height: 16),
            Text('$currency ${fmt.format(overview.totalFees)}',
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Total Fee Amount', style: TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: overview.paidPercentage,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  overview.totalDue > 0 ? AcademicTheme.warning : AcademicTheme.success,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(label: 'Paid', value: '$currency ${fmt.format(overview.totalPaid)}', color: AcademicTheme.success),
                const SizedBox(width: 8),
                _StatChip(label: 'Due', value: '$currency ${fmt.format(overview.totalDue)}',
                    color: overview.totalDue > 0 ? AcademicTheme.danger : AcademicTheme.success),
                const SizedBox(width: 8),
                _StatChip(label: 'Concession', value: '$currency ${fmt.format(overview.totalConcession)}', color: AcademicTheme.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStatusPill(FeeOverview overview, String currency, NumberFormat fmt) {
    final isDue = overview.totalDue > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isDue ? AcademicTheme.danger : AcademicTheme.success).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isDue ? AcademicTheme.danger : AcademicTheme.success).withOpacity(0.5)),
      ),
      child: Text(
        isDue ? '$currency ${fmt.format(overview.totalDue)} Due' : '✓ Fully Paid',
        style: TextStyle(color: isDue ? const Color(0xFFFF8080) : const Color(0xFF6EE7B7), fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    final border = isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight;
    final card = isDark ? AcademicTheme.cardDark : AcademicTheme.cardLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: AcademicTheme.borderRadiusSm,
        border: Border.all(color: border),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AcademicTheme.primaryLight,
        unselectedLabelColor: isDark ? AcademicTheme.textMutedDark : AcademicTheme.textMutedLight,
        tabs: const [
          Tab(text: 'Invoices'),
          Tab(text: 'Transactions'),
          Tab(text: 'Concessions'),
        ],
      ),
    );
  }

  // Widget _buildInvoicesTab(List<FeeInvoice> invoices, bool isDark) {
  //   if (invoices.isEmpty) return _buildEmpty('No invoices found', Icons.receipt_long_outlined);
  //   return ListView.separated(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: invoices.length,
  //     separatorBuilder: (_, __) => const SizedBox(height: 12),
  //     itemBuilder: (context, index) => _InvoiceCard(invoice: invoices[index], isDark: isDark),
  //   );
  // }

  Widget _buildInvoicesTab(List<FeeInvoice> invoices, bool isDark) {
    if (invoices.isEmpty) return _buildEmpty('No invoices found', Icons.receipt_long_outlined);

    // Make sure you have _razorpayService initialized in your _FeesScreenState
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _InvoiceCard(
        invoice: invoices[index],
        isDark: isDark,
        razorpayService: _razorpayService, // Pass service here
        onRefresh: () => ref.invalidate(feesDataProvider), // Pass refresh logic
      ),
    );
  }

  Widget _buildTransactionsTab(List<FeeTransaction> transactions, bool isDark) {
    if (transactions.isEmpty) return _buildEmpty('No transactions yet', Icons.payment_outlined);

    final fmt = NumberFormat('#,##,##0.00', 'en_IN');
    final textPrimary = isDark ? AcademicTheme.textPrimaryDark : AcademicTheme.textPrimaryLight;
    final textSecondary = isDark ? AcademicTheme.textSecondaryDark : AcademicTheme.textSecondaryLight;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final txn = transactions[index];
        final color = txn.status == 'SUCCESS' ? AcademicTheme.success : txn.status == 'PENDING' ? AcademicTheme.warning : AcademicTheme.danger;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AcademicTheme.cardDark : AcademicTheme.cardLight,
            borderRadius: AcademicTheme.borderRadiusSm,
            border: Border.all(color: isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight),
          ),
          child: ListTile(
            leading: Icon(_modeIcon(txn.mode), color: color),
            title: Text(txn.transactionId, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text(txn.mode, style: TextStyle(color: textSecondary, fontSize: 12)),
            trailing: Text('₹ ${fmt.format(txn.amount)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildConcessionsTab(List<FeeConcession> concessions, bool isDark) {
    if (concessions.isEmpty) return _buildEmpty('No concessions applied', Icons.card_giftcard_outlined);

    final fmt = NumberFormat('#,##,##0.00', 'en_IN');
    final textPrimary = isDark ? AcademicTheme.textPrimaryDark : AcademicTheme.textPrimaryLight;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: concessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final c = concessions[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AcademicTheme.cardDark : AcademicTheme.cardLight,
            borderRadius: AcademicTheme.borderRadiusSm,
            border: Border.all(color: isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight),
          ),
          child: ListTile(
            title: Text(c.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text(c.type, style: TextStyle(color: AcademicTheme.accent, fontSize: 11)),
            trailing: Text('- ₹ ${fmt.format(c.amount)}', style: const TextStyle(color: AcademicTheme.success, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildError(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AcademicTheme.danger),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.invalidate(feesDataProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AcademicTheme.textMutedLight),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AcademicTheme.textMutedLight, fontSize: 14)),
        ],
      ),
    );
  }

  IconData _modeIcon(String mode) {
    switch (mode.toUpperCase()) {
      case 'CASH': return Icons.payments_outlined;
      case 'DD': return Icons.article_outlined;
      case 'CHEQUE': return Icons.receipt_outlined;
      default: return Icons.credit_card_outlined;
    }
  }
}

// --- Helper Widgets ---

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// class _InvoiceCard extends StatefulWidget {
//   final FeeInvoice invoice;
//   final bool isDark;
//
//   const _InvoiceCard({required this.invoice, required this.isDark});
//
//   @override
//   State<_InvoiceCard> createState() => _InvoiceCardState();
// }
class _InvoiceCard extends StatefulWidget {
  final FeeInvoice invoice;
  final bool isDark;
  // Add these two fields
  final dynamic razorpayService;
  final VoidCallback onRefresh;

  const _InvoiceCard({
    required this.invoice,
    required this.isDark,
    required this.razorpayService, // Add this
    required this.onRefresh,       // Add this
  });

  @override
  State<_InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    debugPrint('--- Invoice Log ---');
    debugPrint('Invoice No: ${inv.invoiceNumber}');
    debugPrint('Academic Year: ${inv.academicYear}');
    debugPrint('Term: ${inv.termName}');
    debugPrint('Due Amount: ${inv.due}');
    debugPrint('Items Count: ${inv.lineItems.length}');
    debugPrint('-------------------');
    final isDark = widget.isDark;
    final border = isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight;
    final textPrimary = isDark ? AcademicTheme.textPrimaryDark : AcademicTheme.textPrimaryLight;
    final textSecondary = isDark ? AcademicTheme.textSecondaryDark : AcademicTheme.textSecondaryLight;
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isDark ? AcademicTheme.cardDark : AcademicTheme.cardLight,
        borderRadius: AcademicTheme.borderRadiusMd,
        border: Border.all(color: inv.isOverdue ? AcademicTheme.danger : border),
        boxShadow: isDark ? AcademicTheme.darkCardShadow : AcademicTheme.cardShadow,
      ),
      child: Column(
        children: [
          ListTile(
            onTap: inv.lineItems.isNotEmpty ? () => setState(() => _expanded = !_expanded) : null,
            title: Text(inv.invoiceNumber, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text('${inv.termName} • ${inv.academicYear}', style: TextStyle(color: textSecondary, fontSize: 12)),
            trailing: Text('₹ ${fmt.format(inv.amount)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
          ),

          // --- PAY NOW BUTTON START ---
          if (inv.due > 0)
              Padding(
                // Fixed: Use EdgeInsets.only to specify bottom padding alongside horizontal values
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment_rounded, size: 16),
                    label: const Text('Pay Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E40AF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => PayFeeBottomSheet(
                          invoice: inv,
                          paymentService: widget.razorpayService,
                          onPaymentCompleted: widget.onRefresh,
                        ),
                      );
                    },
                  ),
                ),
              ),
// --- PAY NOW BUTTON END ---
          // --- PAY NOW BUTTON END ---

          // if (_expanded)
          if (inv.lineItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: inv.lineItems.map((item) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name, style: TextStyle(color: textSecondary, fontSize: 12)),
                    Text('₹ ${fmt.format(item.amount)}', style: TextStyle(color: textPrimary, fontSize: 12)),
                  ],
                )).toList(),
              ),
            )
        ],
      ),
    );
  }
}
// class _InvoiceCardState extends State<_InvoiceCard> {
//   bool _expanded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final inv = widget.invoice;
//     final isDark = widget.isDark;
//     final border = isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight;
//     final textPrimary = isDark ? AcademicTheme.textPrimaryDark : AcademicTheme.textPrimaryLight;
//     final textSecondary = isDark ? AcademicTheme.textSecondaryDark : AcademicTheme.textSecondaryLight;
//     final fmt = NumberFormat('#,##,##0.00', 'en_IN');
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 250),
//       decoration: BoxDecoration(
//         color: isDark ? AcademicTheme.cardDark : AcademicTheme.cardLight,
//         borderRadius: AcademicTheme.borderRadiusMd,
//         border: Border.all(color: inv.isOverdue ? AcademicTheme.danger : border),
//         boxShadow: isDark ? AcademicTheme.darkCardShadow : AcademicTheme.cardShadow,
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             onTap: inv.lineItems.isNotEmpty ? () => setState(() => _expanded = !_expanded) : null,
//             title: Text(inv.invoiceNumber, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
//             subtitle: Text('${inv.termName} • ${inv.academicYear}', style: TextStyle(color: textSecondary, fontSize: 12)),
//             trailing: Text('₹ ${fmt.format(inv.amount)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
//           ),
//           if (_expanded)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Column(
//                 children: inv.lineItems.map((item) => Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(item.name, style: TextStyle(color: textSecondary, fontSize: 12)),
//                     Text('₹ ${fmt.format(item.amount)}', style: TextStyle(color: textPrimary, fontSize: 12)),
//                   ],
//                 )).toList(),
//               ),
//             )
//         ],
//       ),
//     );
//   }
// }

Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PAID': return AcademicTheme.success;
    case 'PARTIAL': return AcademicTheme.warning;
    case 'OVERDUE': return AcademicTheme.danger;
    default: return AcademicTheme.textMutedLight;
  }
}