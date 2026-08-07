import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/components/user_details/user_profile_card.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';
import 'package:quest/components/report_bottom_sheet.dart';
import 'package:quest/providers/feed_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/community/community_verse_override_dialog.dart';
import 'package:quest/screens/community/community_join_requests_screen.dart';

class CommunityMenuDialogBox extends StatelessWidget {
  final Map<String, dynamic> community;

  const CommunityMenuDialogBox({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedUserGroup,
              iconBackgroundColor: Colors.transparent,
              title: 'See Members',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => MembersBottomSheet(community: community),
                );
              },
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedUserWarning01,
              iconBackgroundColor: Colors.transparent,
              title: 'Community Guidelines',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const GuidelinesBottomSheet(),
                );
              },
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedShare01,
              iconBackgroundColor: Colors.transparent,
              title: 'Share this community',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);
                final link =
                    'https://quest.vidarave.com/community/${community['id']}';
                showInAppShareSheet(
                  context,
                  shareMessage: 'Join ${community['name']} on Quest! $link',
                );
              },
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedAlert02,
              iconBackgroundColor: Colors.transparent,
              title: 'Report this community',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ReportBottomSheet(
                    itemType: 'COMMUNITY',
                    itemId: community['id'],
                  ),
                );
              },
            ),
            Builder(builder: (context) {
              final authId = context.read<AuthProvider>().user?['id'];
              final members = (community['members'] as List<dynamic>?) ?? [];
              final isOwner = community['ownerId'] == authId;
              final isAdmin = isOwner || members.any((m) => m['id'] == authId && m['role'] == 'ADMIN');
              final isPrivate = community['isPrivate'] == true;
              final isForumDisabledGlobally = community['isForumDisabledGlobally'] == true;

              if (isAdmin) {
                return Column(
                  children: [
                    if (isPrivate)
                      SettingsRowItem(
                        icon: HugeIcons.strokeRoundedUserAdd01,
                        iconBackgroundColor: Colors.transparent,
                        title: 'Join Requests',
                        iconColor: AppTheme.textColor2,
                        secondIconColor: Colors.transparent,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommunityJoinRequestsScreen(
                                communityId: community['id'],
                              ),
                            ),
                          );
                        },
                      ),
                    SettingsRowItem(
                      icon: isForumDisabledGlobally ? HugeIcons.strokeRoundedCheckmarkBadge01 : HugeIcons.strokeRoundedCancel01,
                      iconBackgroundColor: Colors.transparent,
                      title: isForumDisabledGlobally ? 'Enable Global Posting' : 'Disable Global Posting',
                      iconColor: AppTheme.textColor2,
                      secondIconColor: Colors.transparent,
                      onTap: () async {
                        Navigator.pop(context);
                        final auth = context.read<AuthProvider>();
                        if (auth.token != null) {
                          await context.read<CommunityProvider>().updateCommunitySettings(
                            auth.token!,
                            community['id'],
                            isForumDisabledGlobally: !isForumDisabledGlobally,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isForumDisabledGlobally ? 'Global posting enabled' : 'Global posting disabled')),
                          );
                        }
                      },
                    ),
                    SettingsRowItem(
                      icon: HugeIcons.strokeRoundedEdit01,
                      iconBackgroundColor: Colors.transparent,
                      title: 'Override Verse of the Day',
                      iconColor: AppTheme.textColor2,
                      secondIconColor: Colors.transparent,
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => CommunityVerseOverrideDialog(communityId: community['id']),
                        );
                      },
                    ),
                  ],
                );
              }
              return const SizedBox();
            }),
          ],
        ),
      ),
    );
  }
}

class MembersBottomSheet extends StatelessWidget {
  final Map<String, dynamic> community;

  const MembersBottomSheet({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    final members = (community['members'] as List<dynamic>?) ?? [];
    final currentUser = context.read<AuthProvider>().user;
    final friends = context.read<FeedProvider>().friends;
    final isAdmin = members.any((m) => m['id'] == currentUser?['id'] && m['role'] == 'ADMIN');

    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 24), // Balance spacing
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final user = members[index] ?? {};
                final name =
                    "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}"
                        .trim();
                final displayName =
                    name.isEmpty ? (user['username'] ?? '') : name;
                final avatar = user['avatarUrl'];

                final isMe =
                    currentUser != null && currentUser['id'] == user['id'];
                final isFriend = friends.any((f) => f['id'] == user['id']);
                final isSuspended = user['isSuspended'] == true;
                final canPostForum = user['canPostForum'] != false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => UserProfileCard(user: user),
                      );
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child:
                              avatar != null
                                  ? Image.network(
                                    ApiService.getFullImageUrl(avatar),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'assets/images/boy.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user['username'] != null && user['username'].toString().isNotEmpty ? '@${user['username']}' : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isMe && !isFriend)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Connect',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        if (isAdmin && !isMe)
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
                            onSelected: (value) async {
                              final auth = context.read<AuthProvider>();
                              final cp = context.read<CommunityProvider>();
                              if (auth.token == null) return;
                              if (value == 'suspend') {
                                await cp.moderateCommunityMember(auth.token!, community['id'], user['id'], isSuspended: !isSuspended);
                              } else if (value == 'posting') {
                                await cp.moderateCommunityMember(auth.token!, community['id'], user['id'], canPostForum: !canPostForum);
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'suspend',
                                child: Text(isSuspended ? 'Unsuspend Member' : 'Suspend Member'),
                              ),
                              PopupMenuItem<String>(
                                value: 'posting',
                                child: Text(canPostForum ? 'Disable Posting' : 'Enable Posting'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GuidelinesBottomSheet extends StatelessWidget {
  const GuidelinesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Community Guidelines',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                List.generate(
                  5,
                  (_) =>
                      "Connect with fellow young Christians in Lekki! Share your faith, grow spiritually, and build lasting friendships in a supportive community. Join us for events, discussions, and opportunities to make a difference together.",
                ).join('\n\n'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileBottomSheet extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> currentCommunity;

  const ProfileBottomSheet({
    super.key,
    required this.user,
    required this.currentCommunity,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;
    final friends = context.read<FeedProvider>().friends;

    final name = "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
    final displayName = name.isEmpty ? (user['username'] ?? '') : name;
    final avatar = user['avatarUrl'];

    final isMe = currentUser != null && currentUser['id'] == user['id'];
    final isFriend = friends.any((f) => f['id'] == user['id']);

    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child:
                    avatar != null
                        ? Image.network(
                          ApiService.getFullImageUrl(avatar),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          'assets/images/boy.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user['username'] != null && user['username'].toString().isNotEmpty ? '@${user['username']}' : '',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildStat("23", "Friend"),
                      const SizedBox(width: 15),
                      _buildStat("23", "Badges"),
                      const SizedBox(width: 15),
                      _buildStat("5", "Communities"),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Text("😃", style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "A passionate note-taker, always seeking to weave wisdom into daily life. Loves to explore the depths...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: Text(
              "You and ${user['firstName'] ?? ''} are in a community together",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child:
                      currentCommunity['image'] != null
                          ? Image.network(
                            ApiService.getFullImageUrl(
                              currentCommunity['image'],
                            ),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            'assets/images/boy.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${currentCommunity['name'] ?? 'Community'} (${currentCommunity['_count']?['members'] ?? 0})",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentCommunity['description'] ??
                            'Meet young vibrant youth...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
          if (!isMe && !isFriend) ...[
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            const Spacer(),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Row(
      children: [
        Text(
          val,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
