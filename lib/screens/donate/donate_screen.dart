import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:quest/theme/theme.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final TextEditingController _amountController = TextEditingController();

  void _processPayment(BuildContext context) {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (BuildContext context) => UsePaypal(
              sandboxMode: true,
              clientId:
                  "AW1TdvpSGbIM5iP4HJNI5BaSqgFz9sq3k1S0C2oK3FzVjK3W4x9r3-B5O20YnS6A9o6-h0eO-kU2YtFj", // Replace with your sandbox/live client ID
              secretKey:
                  "EByu0G3K4XJg9Q7N8rM52wX5S7LqXmH8K8r21m3D9-w4Z9M0L5h6kO7X1V6J9_w1B0D8X8c4M1V8V1b2", // Replace with your sandbox/live secret
              returnURL: "https://samplesite.com/return",
              cancelURL: "https://samplesite.com/cancel",
              transactions: [
                {
                  "amount": {
                    "total": amount.toStringAsFixed(2),
                    "currency": "USD",
                    "details": {
                      "subtotal": amount.toStringAsFixed(2),
                      "shipping": '0',
                      "shipping_discount": 0,
                    },
                  },
                  "description": "Donation to Shalom App.",
                  "item_list": {
                    "items": [
                      {
                        "name": "Donation",
                        "quantity": 1,
                        "price": amount.toStringAsFixed(2),
                        "currency": "USD",
                      },
                    ],
                  },
                },
              ],
              note: "Contact us for any questions on your donation.",
              onSuccess: (Map params) async {
                print("onSuccess: $params");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your donation!')),
                );
                Navigator.pop(context); // Pop back after success
              },
              onError: (error) {
                print("onError: $error");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment error: $error')),
                );
                Navigator.pop(context);
              },
              onCancel: (params) {
                print('cancelled: $params');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment cancelled')),
                );
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Donate'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/images/logo.png', width: 80, height: 80),
            const SizedBox(height: 24),
            Text(
              "Support Shalom App",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your contribution helps us keep the app free and available for everyone.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Donation Amount (USD)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _processPayment(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Pay with PayPal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
