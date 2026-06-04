import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/tile/image_row_tile.dart';
import 'package:quest/theme/theme.dart';

class NewPostScreen extends StatelessWidget {
  const NewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 22,
                    color: Colors.black,
                    strokeWidth: 1,
                  ),
                ),
              ),
              Text(
                'New Post',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.purpleColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Post',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
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
