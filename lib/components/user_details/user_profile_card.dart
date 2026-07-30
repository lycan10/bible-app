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

class UserProfileCard extends StatefulWidget {
  final Map<String, dynamic>? user;
  const UserProfileCard({super.key, this.user});

  @override
  State<UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final auth = context.read<AuthProvider>();
    if (auth.token != null && widget.user != null) {
      try {
        final userId = widget.user!['id'];
        final res = await ApiService.fetchProfileStats(auth.token!, userId);
        if (mounted) {
          setState(() {
            _stats = res;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _shareProfile(BuildContext context) {
    if (widget.user != null) {
      final username = widget.user!['username'] ?? widget.user!['id'];
      final link = 'https://quest.vidarave.com/profile/$username';
      showInAppShareSheet(
        context,
        shareMessage: 'Check out this profile on Quest! $link',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user ?? {};
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final username = user['username'] ?? '';
    final avatarUrl = user['avatarUrl'];

    final friendsCount = _stats?['friends'] ?? 0;
    final badgesCount = _stats?['badges'] ?? 0;
    final communitiesCount = _stats?['communities'] ?? 0;
    final mutualCommunities =
        _stats?['mutualCommunities'] as List<dynamic>? ?? [];
    final connectionStatus = _stats?['connectionStatus'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child:
                      avatarUrl != null && avatarUrl.toString().isNotEmpty
                          ? Image.network(
                            ApiService.getFullImageUrl(avatarUrl),
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            "assets/images/user_test.jpg",
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 2.5,
                          ),
                          children: [
                            TextSpan(text: '$firstName $lastName '),
                            if (user['verificationBadge'] == 'BLUE')
                              WidgetSpan(
                                child: Icon(Icons.verified, color: Colors.blue, size: 16),
                                alignment: PlaceholderAlignment.middle,
                              )
                            else if (user['verificationBadge'] == 'GOLD')
                              WidgetSpan(
                                child: Icon(Icons.verified, color: Colors.amber, size: 16),
                                alignment: PlaceholderAlignment.middle,
                              ),
                            TextSpan(text: '\n'),
                            TextSpan(
                              text: username.isNotEmpty ? '@$username' : '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor2,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatText(value: "$friendsCount", label: "Friends"),
                          _StatText(value: "$badgesCount", label: "Badges"),
                          _StatText(
                            value: "$communitiesCount",
                            label: "Communities",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                if (connectionStatus == 'ACCEPTED' ||
                    connectionStatus == null) ...[
                  ActionPillButton(
                    icon: HugeIcons.strokeRoundedMessage01,
                    label: "Chat",
                    onTap: () {
                      if (widget.user != null) {
                        Navigator.pop(context); // close bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MessageChatScreen(
                                  chatId:
                                      'temp', // This should be handled properly to get or create chat
                                  friend: widget.user!,
                                ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  ActionPillButton(
                    icon: HugeIcons.strokeRoundedShare08,
                    label: "Share",
                    onTap: () => _shareProfile(context),
                  ),
                  const SizedBox(width: 10),
                  ActionPillButton(
                    icon: HugeIcons.strokeRoundedAlertDiamond,
                    label: "Report",
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ReportBottomSheet(
                          itemType: 'USER',
                          itemId: widget.user?['id'] ?? '',
                          reportedUserId: widget.user?['id'] ?? '',
                        ),
                      );
                    },
                  ),
                ] else ...[
                  ActionPillButton(
                    icon:
                        connectionStatus == 'PENDING'
                            ? HugeIcons.strokeRoundedTime02
                            : HugeIcons.strokeRoundedUserAdd01,
                    label:
                        connectionStatus == 'PENDING' ? "Pending" : "Connect",
                    backgroundColor:
                        connectionStatus == 'PENDING'
                            ? Colors.grey.shade200
                            : AppTheme.purpleColor,
                    textColor:
                        connectionStatus == 'PENDING'
                            ? Colors.black
                            : Colors.white,
                    iconColor:
                        connectionStatus == 'PENDING'
                            ? Colors.black
                            : Colors.white,
                    onTap: () async {
                      if (connectionStatus == 'NONE' && widget.user != null) {
                        final auth = context.read<AuthProvider>();
                        try {
                          await ApiService.sendFriendRequest(
                            auth.token!,
                            widget.user!['id'],
                          );
                          setState(() {
                            if (_stats != null) {
                              _stats!['connectionStatus'] = 'PENDING';
                            }
                          });
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to send request: $e'),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
                const SizedBox(width: 10),
                ActionPillButton(
                  backgroundColor: AppTheme.redColor,
                  icon: HugeIcons.strokeRoundedSecurity,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  label: "Block",
                  onTap: () {
                    if (widget.user != null) {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Block",
                        barrierColor: Colors.black.withValues(alpha: 0.4),
                        transitionDuration: const Duration(milliseconds: 250),
                        pageBuilder:
                            (_, __, ___) => Center(
                              child: _BlockUserDialog(user: widget.user!),
                            ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 25),
            if (mutualCommunities.isNotEmpty) ...[
              Text(
                "You and $firstName are in ${mutualCommunities.length} communities together",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: AppTheme.textColor2,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 150, // Constrain height if needed or use ListView
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mutualCommunities.length,
                  itemBuilder: (context, index) {
                    final comm = mutualCommunities[index];
                    return CommunityCardSnippet(
                      communityName: comm['name'] ?? 'Unknown',
                      description: comm['description'] ?? '',
                      communityImage:
                          comm['avatarUrl'] ??
                          "assets/images/test.jpg", // can handle network image later
                    );
                  },
                ),
              ),
            ] else if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else ...[
              Text(
                "No mutual communities",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: AppTheme.textColor2,
                ),
              ),
            ],
          ],
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
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textColor2,
              fontSize: 11,
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
                        Navigator.pop(context); // close bottom sheet
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
