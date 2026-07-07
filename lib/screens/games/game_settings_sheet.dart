import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/game_settings_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class GameSettingsSheet extends StatelessWidget {
  const GameSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
        child: Consumer<GameSettingsProvider>(
          builder: (context, provider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.tune_rounded, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      "Game Settings",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Sound Effects toggle + slider ─────────────────────────
                _buildToggle(
                  context: context,
                  secondary: const HugeIcon(
                    icon: HugeIcons.strokeRoundedVolumeUp,
                    color: Colors.grey,
                    size: 22,
                  ),
                  label: "Sound Effects",
                  value: provider.soundEffectsEnabled,
                  onChanged: (_) => provider.toggleSoundEffects(),
                ),
                if (provider.soundEffectsEnabled)
                  _buildVolumeSlider(
                    context: context,
                    label: "SFX Volume",
                    icon: Icons.graphic_eq_rounded,
                    value: provider.sfxVolume,
                    onChanged: provider.setSfxVolume,
                  ),

                const Divider(height: 24),

                // ── Background Music toggle + slider ──────────────────────
                _buildToggle(
                  context: context,
                  secondary: const HugeIcon(
                    icon: HugeIcons.strokeRoundedMusicNote01,
                    color: Colors.grey,
                    size: 22,
                  ),
                  label: "Background Music",
                  value: provider.musicEnabled,
                  onChanged: (_) => provider.toggleMusic(),
                ),
                if (provider.musicEnabled)
                  _buildVolumeSlider(
                    context: context,
                    label: "Music Volume",
                    icon: Icons.music_note_rounded,
                    value: provider.musicVolume,
                    onChanged: provider.setMusicVolume,
                  ),

                const Divider(height: 24),

                // ── Vibration toggle ──────────────────────────────────────
                _buildToggle(
                  context: context,
                  secondary: const HugeIcon(
                    icon: HugeIcons.strokeRoundedSmartPhone01,
                    color: Colors.grey,
                    size: 22,
                  ),
                  label: "Vibration",
                  value: provider.vibrationEnabled,
                  onChanged: (_) => provider.toggleVibration(),
                ),

                const SizedBox(height: 24),

                // ── Done button ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggle({
    required BuildContext context,
    required Widget secondary,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      secondary: secondary,
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildVolumeSlider({
    required BuildContext context,
    required String label,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 1,
                divisions: 10,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.primary.withAlpha(50),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
