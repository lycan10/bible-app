import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/feed_provider.dart';

class DailyFeelingPopup extends StatefulWidget {
  const DailyFeelingPopup({super.key});

  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const DailyFeelingPopup(),
    );
  }

  @override
  State<DailyFeelingPopup> createState() => _DailyFeelingPopupState();
}

class _DailyFeelingPopupState extends State<DailyFeelingPopup> {
  double _currentSliderValue = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).loadFeelingsMetadata();
    });
  }

  void _submitFeeling(FeedProvider feedProvider) async {
    if (feedProvider.feelingsMetadata.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final index = _currentSliderValue.toInt();
      final feelingData = feedProvider.feelingsMetadata[index];

      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        await feedProvider.changeFeeling(
          token,
          feelingData['feeling'],
          feelingData['emoji'],
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Returns a color matching the feeling somewhat dynamically
  Color _getFeelingColor(int index, int max) {
    // Generate a hue based on the index to sweep across colors
    final hue = (index / (max > 0 ? max : 1)) * 360;
    return HSLColor.fromAHSL(1.0, hue, 0.8, 0.6).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, provider, child) {
        if (provider.feelingsMetadata.isEmpty) {
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }

        final maxIndex = provider.feelingsMetadata.length - 1;
        final currentIndex = _currentSliderValue.toInt();
        final currentFeeling = provider.feelingsMetadata[currentIndex];
        final String feelingLabel = currentFeeling['feeling'];
        final String feelingEmoji = currentFeeling['emoji'];
        final Color flowerColor = _getFeelingColor(currentIndex, maxIndex);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How are you\nfeeling today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // Flower representation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: flowerColor.withAlpha(100),
                            blurRadius: 50,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    // Multi-rotated containers to make a flower
                    ...List.generate(6, (index) {
                      return Transform.rotate(
                        angle: index * (3.14159 / 6),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [flowerColor, flowerColor.withAlpha(0)],
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      );
                    }),
                    Text(
                      feelingEmoji,
                      style: TextStyle(
                        fontSize: 64,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                Text(
                  feelingLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.24),
                    inactiveTrackColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.1),
                    thumbColor: Theme.of(context).colorScheme.onSurface,
                    overlayColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.24),
                    trackHeight: 30,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 15,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                  ),
                  child: Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: maxIndex.toDouble(),
                    divisions: maxIndex > 0 ? maxIndex : 1,
                    onChanged: (value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _submitFeeling(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
