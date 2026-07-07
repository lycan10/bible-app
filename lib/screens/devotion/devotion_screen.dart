import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/stats/stats.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/devotion_provider.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class DevotionScreen extends StatefulWidget {
  final String? planId;
  final int? dayNum;

  const DevotionScreen({super.key, this.planId, this.dayNum});

  @override
  State<DevotionScreen> createState() => _DevotionScreenState();
}

class _DevotionScreenState extends State<DevotionScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dayData;
  Map<String, dynamic>? _planData;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final ScrollController _scrollController = ScrollController();
  bool _autoScrollEnabled = false;
  bool _hasLiked = false;

  late int _viewedDayNum;
  late int _maxAllowedDay;

  @override
  void initState() {
    super.initState();
    _maxAllowedDay = widget.dayNum ?? 1;
    _viewedDayNum = _maxAllowedDay;
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (widget.planId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final devProvider = Provider.of<DevotionProvider>(context, listen: false);
    if (authProvider.token == null) return;

    try {
      final dayResponse = await devProvider.fetchDayContent(
        authProvider.token!,
        widget.planId!,
        _viewedDayNum,
      );
      if (mounted) {
        setState(() {
          _dayData = dayResponse['day'];
          _planData = dayResponse['plan'];
          _hasLiked = dayResponse['day']?['hasLiked'] == true;
          _isLoading = false;
        });

        if (_dayData != null && _dayData!['videoUrl'] != null) {
          _initializeVideo(_dayData!['videoUrl']);
        }
      }
    } catch (e) {
      print("Error fetching day data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initializeVideo(String url) {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoPlayerController!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            showControls: true,
          );
        });

        _videoPlayerController!.addListener(_videoListener);
      }
    });
  }

  void _videoListener() {
    if (_autoScrollEnabled &&
        _videoPlayerController!.value.position >=
            _videoPlayerController!.value.duration) {
      // Auto-scroll to text when video ends
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
      );
    }
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  void _markComplete() async {
    _triggerHaptic();
    if (widget.planId != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final devProvider = Provider.of<DevotionProvider>(context, listen: false);
      if (authProvider.token != null) {
        try {
          final result = await devProvider.completeDevotionDay(
            authProvider.token!,
            widget.planId!,
            _viewedDayNum,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'Devotion marked as complete!',
                ),
              ),
            );
            Navigator.pop(context); // Go back after marking complete
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to complete devotion')),
            );
          }
        }
      }
    }
  }

  void _reactToDay() async {
    if (_hasLiked) return; // already liked
    _triggerHaptic();
    final dayId = _dayData?['id'];
    if (dayId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot react — content not loaded yet')),
        );
      }
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final devProvider = Provider.of<DevotionProvider>(context, listen: false);
    if (authProvider.token != null) {
      try {
        await devProvider.likeDevotionDay(authProvider.token!, dayId);
        if (mounted) {
          setState(() {
            _hasLiked = true;
            _dayData!['likesCount'] = (_dayData!['likesCount'] ?? 0) + 1;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to react: $e')),
          );
        }
      }
    }
  }

  void _sharePlan() async {
    _triggerHaptic();
    if (widget.planId == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final devProvider = Provider.of<DevotionProvider>(context, listen: false);
    if (authProvider.token != null) {
      try {
        final url = await devProvider.shareDevotionPlan(
          authProvider.token!,
          widget.planId!,
        );
        if (mounted) {
          showInAppShareSheet(
            context,
            shareMessage:
                'Check out "${_planData?['title'] ?? 'this devotion plan'}" on Quest!\n$url',
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to share: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openMenu() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: _PostMenuDialogBox(
            planId: widget.planId,
            autoScrollEnabled: _autoScrollEnabled,
            onToggleAutoScroll: (val) {
              setState(() => _autoScrollEnabled = val);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final title = _dayData?['title'] ?? 'Devotion';
    final durationDays = _planData?['durationDays'] ?? 365;
    final planImage = _planData?['image'] ?? 'assets/images/user_test.jpg';
    final pointsEarned = _dayData?['pointsEarned'] ?? 20;
    final bodyText = _dayData?['bodyText'] ?? 'No content available.';
    final authorName = _planData?['authorName'] ?? 'Author';
    final authorHandle = _planData?['authorHandle'] ?? '@author';
    final likesCount = _dayData?['likesCount'] ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: '',
                trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
                trailingIconTap: _openMenu,
              ),
              const SizedBox(height: 25),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                  title,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "$durationDays Days Plan",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.textColor2,
                                ),
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:
                                planImage.startsWith('http')
                                    ? Image.network(
                                      planImage,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      planImage,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: durationDays,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final d = index + 1;
                            final isFuture = d > _maxAllowedDay;
                            return GestureDetector(
                              onTap: isFuture
                                  ? null
                                  : () {
                                      if (d != _viewedDayNum) {
                                        setState(() {
                                          _isLoading = true;
                                          _viewedDayNum = d;
                                        });
                                        _fetchData();
                                      }
                                    },
                              child: DayPill(
                                day: d,
                                isSkipped: d < _viewedDayNum,
                                isFuture: isFuture,
                                isSelected: d == _viewedDayNum,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Points earned ",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "+$pointsEarned",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.greenColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              'assets/images/bronze.png',
                              height: 38,
                              width: 38,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_chewieController != null)
                        SizedBox(
                          height: 230,
                          child: Chewie(controller: _chewieController!),
                        )
                      else if (_dayData?['image'] != null)
                        SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                _dayData!['image'].toString().startsWith('http')
                                    ? Image.network(
                                      _dayData!['image'],
                                      height: 230,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      _dayData!['image'],
                                      height: 230,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Text Body
                      Text(
                        bodyText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          height: 1.6,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child:
                                planImage.startsWith('http')
                                    ? Image.network(
                                      planImage,
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      planImage,
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                authorHandle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.textColor2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Stat(
                                icon: HugeIcons.strokeRoundedThumbsUp,
                                text: "$likesCount",
                                iconSize: 18,
                                textColor: _hasLiked
                                    ? AppTheme.purpleColor
                                    : AppTheme.textColor2,
                                textSize: 12,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ActionPillButton(
                                icon: HugeIcons.strokeRoundedShare08,
                                label: "Share",
                                onTap: _sharePlan,
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _hasLiked ? null : _reactToDay,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _hasLiked
                                        ? AppTheme.purpleColor
                                        : const Color(
                                            0xff673aff,
                                          ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _hasLiked ? "Reacted" : "React",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _hasLiked
                                                  ? Colors.white
                                                  : const Color(0xff673aff),
                                              fontSize: 12,
                                            ),
                                      ),
                                      const SizedBox(width: 5),
                                      VerticalDivider(
                                        width: 4,
                                        thickness: 1.5,
                                        color: _hasLiked
                                            ? Colors.white
                                            : const Color(0xff673aff),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _hasLiked ? "✅" : "🤩",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _hasLiked
                                                  ? Colors.white
                                                  : const Color(0xff673aff),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: _markComplete,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.purpleColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Done",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedTick02,
                                size: 22,
                                color: AppTheme.greenColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostMenuDialogBox extends StatelessWidget {
  final String? planId;
  final bool autoScrollEnabled;
  final ValueChanged<bool> onToggleAutoScroll;

  const _PostMenuDialogBox({
    this.planId,
    required this.autoScrollEnabled,
    required this.onToggleAutoScroll,
  });

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),

            // Replaced SettingsRowItem with custom Rows for actions
            GestureDetector(
              onTap: () {
                _triggerHaptic();
                Navigator.pop(context);
                // Action logic for reminder
                if (planId != null) {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final devProvider = Provider.of<DevotionProvider>(
                    context,
                    listen: false,
                  );
                  if (authProvider.token != null) {
                    devProvider.setReminder(
                      authProvider.token!,
                      planId!,
                      "08:00 AM",
                      true,
                    );
                  }
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Reminder set!')));
              },
              child: const SettingsRowItem(
                icon: HugeIcons.strokeRoundedAlarmClock,
                iconBackgroundColor: Colors.transparent,
                title: 'Set a reminder',
                iconColor: AppTheme.textColor2,
                secondIconColor: Colors.transparent,
              ),
            ),
            GestureDetector(
              onTap: () {
                _triggerHaptic();
                Navigator.pop(context);
                if (planId != null) {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final devProvider = Provider.of<DevotionProvider>(
                    context,
                    listen: false,
                  );
                  if (authProvider.token != null) {
                    devProvider.unsubscribeFromPlan(
                      authProvider.token!,
                      planId!,
                    );
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan cancelled!')),
                );
              },
              child: const SettingsRowItem(
                icon: HugeIcons.strokeRoundedCancel01,
                iconBackgroundColor: Colors.transparent,
                title: 'Cancel Plan',
                iconColor: AppTheme.textColor2,
                secondIconColor: Colors.transparent,
              ),
            ),
            GestureDetector(
              onTap: () {
                _triggerHaptic();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback received!')),
                );
              },
              child: const SettingsRowItem(
                icon: HugeIcons.strokeRoundedFavourite,
                iconBackgroundColor: Colors.transparent,
                title: 'I\'ll like to see more of this',
                iconColor: AppTheme.textColor2,
                secondIconColor: Colors.transparent,
              ),
            ),
            GestureDetector(
              onTap: () {
                _triggerHaptic();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted!')),
                );
              },
              child: const SettingsRowItem(
                icon: HugeIcons.strokeRoundedInformationDiamond,
                iconBackgroundColor: Colors.transparent,
                title: 'Report this devotion',
                iconColor: AppTheme.textColor2,
                secondIconColor: Colors.transparent,
              ),
            ),

            const Divider(),
            SwitchListTile(
              title: const Text('Auto Scroll'),
              subtitle: const Text('Scrolls to text when video ends'),
              value: autoScrollEnabled,
              onChanged: (val) {
                _triggerHaptic();
                onToggleAutoScroll(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DayPill extends StatelessWidget {
  final String label;
  final int day;
  final bool isSkipped;
  final bool isFuture;
  final bool isSelected;

  const DayPill({
    super.key,
    this.label = "Day",
    required this.day,
    this.isSkipped = false,
    this.isFuture = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;
    Color numberColor;

    if (isFuture) {
      bgColor = Colors.grey.withValues(alpha: 0.1);
      textColor = Colors.grey;
      numberColor = Colors.grey;
    } else if (isSkipped) {
      bgColor = Colors.amber.withValues(alpha: 0.15);
      textColor = Colors.grey;
      numberColor = Colors.amber;
    } else {
      bgColor = AppTheme.greenColor.withValues(alpha: 0.1);
      textColor = theme.colorScheme.onSurface;
      numberColor = AppTheme.greenColor;
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(color: AppTheme.purpleColor, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            "$day",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: numberColor,
              fontSize: 12,
            ),
          ),
          if (isSkipped) ...[
            const SizedBox(width: 8),
            Text(
              "Skipped",
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
