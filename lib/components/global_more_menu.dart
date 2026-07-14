import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class GlobalMoreMenu extends StatefulWidget {
  final List<Widget>? customActions;

  const GlobalMoreMenu({super.key, this.customActions});

  @override
  State<GlobalMoreMenu> createState() => _GlobalMoreMenuState();
}

class _GlobalMoreMenuState extends State<GlobalMoreMenu> {
  Future<void> _updateSetting(String key, bool value) async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;

    if (key == 'hapticFeedback' && value) {
      HapticFeedback.lightImpact();
    } else {
      final user = auth.user;
      final haptic = user?['hapticFeedback'] ?? false;
      if (haptic) {
        HapticFeedback.lightImpact();
      }
    }

    try {
      auth.updateUserLocally({key: value});
      await ApiService.updateSettings(auth.token!, {key: value});
    } catch (e) {
      if (mounted) {
        auth.updateUserLocally({key: !value}); // Revert
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update setting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;

    final bool autoScroll = user?['autoScroll'] ?? false;
    final bool allowNotifications = user?['allNotifications'] ?? false;
    final bool hapticFeedback = user?['hapticFeedback'] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.customActions != null) ...[
            ...widget.customActions!,
            const Divider(),
          ],
          _SettingsSwitchRow(
            icon: HugeIcons.strokeRoundedMouseScroll01,
            title: 'Auto Scroll',
            subtitle: 'Scrolls to text when video ends',
            switchValue: autoScroll,
            onChanged: (val) => _updateSetting('autoScroll', val),
          ),
          _SettingsSwitchRow(
            icon: HugeIcons.strokeRoundedNotification01,
            title: 'Allow notifications',
            subtitle: 'Turn on or off all notifications',
            switchValue: allowNotifications,
            onChanged: (val) => _updateSetting('allNotifications', val),
          ),
          _SettingsSwitchRow(
            icon: HugeIcons.strokeRoundedSmartPhone03,
            title: 'Haptic Feedback',
            subtitle: 'Turn on haptic feedback',
            switchValue: hapticFeedback,
            onChanged: (val) => _updateSetting('hapticFeedback', val),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final bool switchValue;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, size: 20.0, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: switchValue,
            onChanged: onChanged,
            activeColor: theme.colorScheme.surface,
            activeTrackColor: const Color(0xff673aff),
          ),
        ],
      ),
    );
  }
}
