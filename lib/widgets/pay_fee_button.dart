import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fees_model.dart';
import '../services/razorpay_gateway_service.dart';

class PayFeeBottomSheet extends StatefulWidget {
  final FeeInvoice invoice;
  final RazorpayGatewayService paymentService;
  final VoidCallback onPaymentCompleted;

  const PayFeeBottomSheet({
    Key? key,
    required this.invoice,
    required this.paymentService,
    required this.onPaymentCompleted,
  }) : super(key: key);

  @override
  State<PayFeeBottomSheet> createState() => _PayFeeBottomSheetState();
}

class _PayFeeBottomSheetState extends State<PayFeeBottomSheet> {
  late final TextEditingController _amountController;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Default to the full due amount
    _amountController = TextEditingController(
      text: widget.invoice.due.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _proceedToPay() {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);

    if (amount == null || amount <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }
    if (amount > widget.invoice.due) {
      setState(() => _error = 'Amount cannot exceed due amount of ₹${widget.invoice.due}');
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    widget.paymentService.startPayment(
      feeDemandId: widget.invoice.id,
      amount: amount,
      onSuccess: (result) {
        if (!mounted) return;
        Navigator.pop(context); // Close bottom sheet

        // Show Success Dialog with Receipt
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Payment Successful'),
              ],
            ),
            content: Text(
              'Receipt No: ${result.receiptNo}\nAmount Paid: ₹${result.amount}\n\nYour fee balance has been updated.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onPaymentCompleted(); // Reload fees dashboard
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _error = err;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pay Invoice Fee',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.invoice.invoiceNumber} • ${widget.invoice.termName}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Outstanding Due:', style: TextStyle(fontSize: 14)),
              Text(
                '₹ ${fmt.format(widget.invoice.due)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Payment Amount (₹)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixText: '₹ ',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _proceedToPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isProcessing
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Proceed with Razorpay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
