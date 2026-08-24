import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';
import 'package:quest/components/report_bottom_sheet.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/community/community_card_snippet.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/screens/messages/message_chat_screen.dart';
import 'package:quest/components/titles/title_one.dart';

class PublicProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const PublicProfileScreen({super.key, required this.user});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  bool _isLoadingStats = true;
  Map<String, dynamic>? _stats;
  Map<String, dynamic> _fullUser = {};

  @override
  void initState() {
    super.initState();
    _fullUser = Map.from(widget.user);
    _fetchData();
  }

  Future<void> _fetchData() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;
    
    final targetId = _fullUser['id'] ?? _fullUser['_id'];
    if (targetId == null) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
      return;
    }

    try {
      // Fetch full user data to get bio, location, etc.
      final userData = await ApiService.fetchUserById(auth.token!, targetId.toString());
      if (mounted && userData != null && userData['user'] != null) {
        setState(() {
          _fullUser = userData['user'];
        });
      }
    } catch (e) {
      // Ignore
    }

    try {
      // Fetch stats
      final statsRes = await ApiService.fetchProfileStats(auth.token!, targetId.toString());
      if (mounted) {
        setState(() {
          _stats = statsRes;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _shareProfile(BuildContext context) {
    final userId = _fullUser['id'] ?? '';
    final username = _fullUser['username'] ?? userId;
    final link = 'https://quest.vidarave.com/user/$userId';
    showInAppShareSheet(
      context,
      shareMessage: 'Check out @$username\'s profile on Sozo App! $link',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _fullUser;
    
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final username = user['username'] ?? '';
    final avatarUrl = user['avatarUrl'];
    final bio = user['bio'] ?? '';
    final location = user['location'] ?? '';

    final friendsCount = _stats != null
        ? ((_stats!['friendsCount'] as num?)?.toInt() ?? 0)
        : (user['friends'] as List<dynamic>?)?.length ?? 0;
    final badgesCount = _stats != null ? ((_stats!['badgesCount'] as num?)?.toInt() ?? 0) : 0;
    final communitiesCount = _stats != null
        ? ((_stats!['communitiesCount'] as num?)?.toInt() ?? 0)
        : (user['communities'] as List<dynamic>?)?.length ?? 0;
    final mutualCommunities = _stats?['mutualCommunities'] as List<dynamic>? ?? [];
    final connectionStatus = _stats?['connectionStatus'];

    final formattedAvatarUrl = avatarUrl != null ? ApiService.getFullImageUrl(avatarUrl) : '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Profile',
                trailingIcon: HugeIcons.strokeRoundedMoreVerticalCircle01,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
                trailingIconTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ReportBottomSheet(
                      itemType: 'USER',
                      itemId: user['id'] ?? '',
                      reportedUserId: user['id'] ?? '',
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xff00d4ff), Color(0xff4a3aff)],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: formattedAvatarUrl.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: formattedAvatarUrl,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "assets/images/boy.png",
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(text: '$firstName $lastName '),
                                      if (user['verificationBadge'] == 'BLUE')
                                        const WidgetSpan(
                                          child: Icon(
                                            Icons.verified,
                                            color: Colors.blue,
                                            size: 18,
                                          ),
                                          alignment: PlaceholderAlignment.middle,
                                        )
                                      else if (user['verificationBadge'] == 'GOLD')
                                        const WidgetSpan(
                                          child: Icon(
                                            Icons.verified,
                                            color: Colors.amber,
                                            size: 18,
                                          ),
                                          alignment: PlaceholderAlignment.middle,
                                        ),
                                      const TextSpan(text: '\n'),
                                      TextSpan(
                                        text: username.isNotEmpty ? '@$username' : '',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textColor2,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _StatText(value: "$friendsCount", label: "Friends"),
                                      _StatText(value: "$communitiesCount", label: "Communities"),
                                      _StatText(value: "$badgesCount", label: "Badges"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      if (bio.isNotEmpty || location.isNotEmpty) ...[
                        if (bio.isNotEmpty)
                          Text(
                            bio,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              HugeIcon(icon: HugeIcons.strokeRoundedLocation01, size: 16, color: AppTheme.textColor2),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textColor2,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 25),
                      ],
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (connectionStatus == 'ACCEPTED')
                            ActionPillButton(
                              icon: HugeIcons.strokeRoundedMessage01,
                              label: "Chat",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageChatScreen(
                                      chatId: 'temp', 
                                      friend: user,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ActionPillButton(
                            icon: HugeIcons.strokeRoundedShare08,
                            label: "Share",
                            onTap: () => _shareProfile(context),
                          ),
                          if (connectionStatus != 'ACCEPTED' && connectionStatus != null)
                            ActionPillButton(
                              icon: connectionStatus == 'PENDING'
                                  ? HugeIcons.strokeRoundedTime02
                                  : HugeIcons.strokeRoundedUserAdd01,
                              label: connectionStatus == 'PENDING' ? "Pending" : "Connect",
                              backgroundColor: connectionStatus == 'PENDING'
                                  ? Colors.grey.shade200
                                  : AppTheme.purpleColor,
                              textColor: connectionStatus == 'PENDING' ? Colors.black : Colors.white,
                              iconColor: connectionStatus == 'PENDING' ? Colors.black : Colors.white,
                              onTap: () async {
                                if (connectionStatus == 'NONE') {
                                  final auth = context.read<AuthProvider>();
                                  try {
                                    await ApiService.sendFriendRequest(
                                      auth.token!,
                                      user['id'],
                                    );
                                    setState(() {
                                      if (_stats != null) {
                                        _stats!['connectionStatus'] = 'PENDING';
                                      }
                                    });
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to send request: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ActionPillButton(
                            backgroundColor: AppTheme.redColor,
                            icon: HugeIcons.strokeRoundedSecurity,
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            label: "Block",
                            onTap: () {
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: "Block",
                                barrierColor: Colors.black.withValues(alpha: 0.4),
                                transitionDuration: const Duration(milliseconds: 250),
                                pageBuilder: (_, __, ___) => Center(
                                  child: _BlockUserDialog(user: user),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (_isLoadingStats)
                        const Center(child: CircularProgressIndicator())
                      else if (mutualCommunities.isNotEmpty) ...[
                        Text(
                          "You and $firstName are in ${mutualCommunities.length} ${mutualCommunities.length == 1 ? 'community' : 'communities'} together",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: mutualCommunities.length,
                          itemBuilder: (context, index) {
                            final comm = mutualCommunities[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: CommunityCardSnippet(
                                communityName: comm['name'] ?? 'Unknown',
                                description: comm['description'] ?? '',
                                communityImage: comm['avatarUrl'] ?? "assets/images/boy.png",
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        Text(
                          "No mutual communities",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
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

class _StatText extends StatelessWidget {
  final String value;
  final String label;

  const _StatText({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textColor2,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockUserDialog extends StatelessWidget {
  final Map<String, dynamic> user;
  const _BlockUserDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Text(
              "Block User",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Are you sure you want to block this user? They will not be able to contact you.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textColor2,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final ok = await authProvider.blockUser(user['id']);
                      if (ok && context.mounted) {
                        Navigator.pop(context); // close dialog
                        Navigator.pop(context); // close profile screen
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.buttonColor2,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "Yes, block account",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.redColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
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
}
