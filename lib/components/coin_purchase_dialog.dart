import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/economy_provider.dart';
import 'package:quest/theme/theme.dart';
import 'package:hugeicons/hugeicons.dart';

class CoinPurchaseDialog extends StatelessWidget {
  final String title;
  final String description;

  const CoinPurchaseDialog({
    super.key,
    this.title = "Coins Exhausted",
    this.description = "You need more coins to perform this action. Purchase a coin pack below.",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final economy = context.watch<EconomyProvider>();

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCoins01,
              size: 40,
              color: AppTheme.purpleColor,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textColor2,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 25),
            if (economy.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (!economy.isAvailable || economy.products.isEmpty)
              Text(
                "No coin packages available at the moment.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.redColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              ...economy.products.map((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purpleColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      economy.buyProduct(product);
                    },
                    child: Text(
                      "${product.title.split('(').first.trim()} - ${product.price}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
