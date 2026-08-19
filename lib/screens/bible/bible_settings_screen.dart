import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/bible_provider.dart';
import 'package:quest/theme/theme.dart';
// Ensure your AppTheme is imported here, e.g.:
// import 'package:quest/theme/app_theme.dart';

class BibleSettingsScreen extends StatelessWidget {
  const BibleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bibleProvider = Provider.of<BibleProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Bible Settings",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents tinting on scroll in M3
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            _buildSectionHeader(context, "Appearance", Icons.text_fields),
            const SizedBox(height: 12),
            _buildAppearanceCard(context, bibleProvider),

            const SizedBox(height: 32),

            _buildSectionHeader(
              context,
              "Study Tools",
              Icons.menu_book_rounded,
            ),
            const SizedBox(height: 12),
            _buildStudyToolsCard(context, bibleProvider),

            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceCard(
    BuildContext context,
    BibleProvider bibleProvider,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "A",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primaryBlue,
                      thumbColor: AppTheme.primaryBlue,
                      overlayColor: AppTheme.primaryBlue.withOpacity(0.1),
                      inactiveTrackColor:
                          theme.colorScheme.surfaceContainerHighest,
                      trackHeight: 6.0,
                    ),
                    child: Slider(
                      value: bibleProvider.fontSize,
                      min: 12.0,
                      max: 36.0,
                      divisions: 12,
                      label: bibleProvider.fontSize.round().toString(),
                      onChanged: (double value) {
                        bibleProvider.setFontSize(value);
                      },
                    ),
                  ),
                ),
                const Text(
                  "A",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.4,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.5,
                        ),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Genesis 1:1-2",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "In the beginning God created the heaven and the earth.\n\nAnd the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.",
                    style: TextStyle(
                      fontSize: bibleProvider.fontSize,
                      height: 1.6,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyToolsCard(
    BuildContext context,
    BibleProvider bibleProvider,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context: context,
            title: "Inline Cross-References",
            subtitle: "Show link icons next to verses",
            icon: Icons.link_rounded,
            value: bibleProvider.showInlineCrossReferences,
            onChanged:
                (value) => bibleProvider.setShowInlineCrossReferences(value),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
          _buildSettingsTile(
            context: context,
            title: "Action Sheet Cross-References",
            subtitle: "Show option in long-press menu",
            icon: Icons.touch_app_rounded,
            value: bibleProvider.showActionSheetCrossReferences,
            onChanged:
                (value) =>
                    bibleProvider.setShowActionSheetCrossReferences(value),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
          _buildSettingsTile(
            context: context,
            title: "Study Mode (Split Screen)",
            subtitle: "Show cross-references inline while reading",
            icon: Icons.vertical_split_rounded,
            value: bibleProvider.enableStudyMode,
            onChanged: (value) => bibleProvider.setEnableStudyMode(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      activeColor: AppTheme.primaryBlue,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
