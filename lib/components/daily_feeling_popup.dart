import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/feed_provider.dart';

class DailyFeelingPopup extends StatefulWidget {
  final Function(String feeling, String emoji)? onSelected;

  const DailyFeelingPopup({super.key, this.onSelected});

  static Future<void> show(
    BuildContext context, {
    Function(String feeling, String emoji)? onSelected,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DailyFeelingPopup(onSelected: onSelected),
    );
  }

  @override
  State<DailyFeelingPopup> createState() => _DailyFeelingPopupState();
}

class _DailyFeelingPopupState extends State<DailyFeelingPopup> with SingleTickerProviderStateMixin {
  double _currentSliderValue = 0;
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FeedProvider>(context, listen: false);
      provider.loadFeelingsMetadata().then((_) {
        if (mounted) {
          final index = provider.feelingsMetadata.indexWhere(
            (f) => f['feeling'].toString().toLowerCase() == 'thanksful' || 
                   f['feeling'].toString().toLowerCase() == 'thankful'
          );
          if (index != -1) {
            setState(() {
              _currentSliderValue = index.toDouble();
            });
          }
        }
      });
    });
  }

  void _submitFeeling(FeedProvider feedProvider) async {
    if (feedProvider.feelingsMetadata.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final index = _currentSliderValue.toInt();
      final feelingData = feedProvider.feelingsMetadata[index];
      final feeling = feelingData['feeling'];
      final emoji = feelingData['emoji'];

      if (widget.onSelected != null) {
        widget.onSelected!(feeling, emoji);
      } else {
        final token = Provider.of<AuthProvider>(context, listen: false).token;
        if (token != null) {
          await feedProvider.changeFeeling(
            token,
            feeling,
            emoji,
          );
        }
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

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getFeelingColor(int index, int max) {
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
        final double baseHue = (currentIndex / (maxIndex > 0 ? maxIndex : 1)) * 360;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'How are you\nfeeling today?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Mood Art with Pulse
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        // Shift the color hue continuously during the pulse
                        final currentHue = (baseHue + (_pulseController.value * 90)) % 360;
                        final dynamicPulseColor = HSLColor.fromAHSL(1.0, currentHue, 0.8, 0.6).toColor();

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 200 * _pulseAnimation.value,
                              height: 200 * _pulseAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: dynamicPulseColor.withValues(alpha: 0.5),
                                    blurRadius: 50,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            child!,
                          ],
                        );
                      },
                      child: Image.asset(
                        'assets/images/mood-art.png',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 30),
                    Text(
                      feelingLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Slider Custom Track
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333), // Dark grey track
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: Colors.transparent,
                          inactiveTrackColor: Colors.transparent,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withValues(alpha: 0.1),
                          trackHeight: 40,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 16,
                            elevation: 0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 24,
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
                
                // Close Button
                Positioned(
                  top: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
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
