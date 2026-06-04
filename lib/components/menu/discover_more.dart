import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/tile/image_row_tile.dart';
import 'package:quest/components/titles/title_two.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/feature_guard.dart';

class DiscoverMore extends StatelessWidget {
  const DiscoverMore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleTwo(
            leadingIcon: HugeIcons.strokeRoundedCancel01,
            title: "Discover More",
          ),
          SizedBox(height: 25),
          FeatureGuard(
            featureKey: 'devotion',
            child: ImageRowTile(
              icon: HugeIcons.strokeRoundedMessage02,
              iconBackgroundColor: Colors.transparent,
              title: 'Love',
              subtitle: 'Discover devotions, messages, videos on love',
              iconColor: AppTheme.textColor2,
            ),
          ),
          ImageRowTile(
            icon: HugeIcons.strokeRoundedMessage02,
            iconBackgroundColor: Colors.transparent,
            title: 'Love',
            subtitle: 'Discover devotions, messages, videos on love',
            iconColor: AppTheme.textColor2,
          ),
          ImageRowTile(
            icon: HugeIcons.strokeRoundedMessage02,
            iconBackgroundColor: Colors.transparent,
            title: 'Love',
            subtitle: 'Discover devotions, messages, videos on love',
            iconColor: AppTheme.textColor2,
          ),
          ImageRowTile(
            icon: HugeIcons.strokeRoundedMessage02,
            iconBackgroundColor: Colors.transparent,
            title: 'Love',
            subtitle: 'Discover devotions, messages, videos on love',
            iconColor: AppTheme.textColor2,
          ),
          ImageRowTile(
            icon: HugeIcons.strokeRoundedMessage02,
            iconBackgroundColor: Colors.transparent,
            title: 'Love',
            subtitle: 'Discover devotions, messages, videos on love',
            iconColor: AppTheme.textColor2,
          ),
          ImageRowTile(
            icon: HugeIcons.strokeRoundedMessage02,
            iconBackgroundColor: Colors.transparent,
            title: 'Love',
            subtitle: 'Discover devotions, messages, videos on love',
            iconColor: AppTheme.textColor2,
          ),
        ],
      ),
    );
  }
}
