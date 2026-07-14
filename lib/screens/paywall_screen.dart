import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/theme/theme.dart';
import '../providers/subscription_provider.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Access'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: subProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.star, size: 80, color: Colors.amber),
                  const SizedBox(height: 24),
                  const Text(
                    'Unlock Premium Features',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '• Create your own Community\n• Unlimited Audio/Video Uploads\n• Exclusive Content & Badges',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const Spacer(),
                  if (!subProvider.isAvailable)
                    const Text(
                      'Store is currently unavailable.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    )
                  else if (subProvider.products.isEmpty)
                    const Text(
                      'No subscription products found.',
                      textAlign: TextAlign.center,
                    )
                  else
                    ...subProvider.products.map((product) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          subProvider.subscribe(product);
                        },
                        child: Text('Subscribe for ${product.price}'),
                      );
                    }),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Implement Restore purchases if needed
                    },
                    child: const Text('Restore Purchases'),
                  )
                ],
              ),
            ),
    );
  }
}
