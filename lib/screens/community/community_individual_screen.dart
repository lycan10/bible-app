import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/action_pill/action_pill_button_2.dart';
import 'package:quest/components/event/event_details_card.dart';
import 'package:quest/components/event/event_dotted_card.dart';
import 'package:quest/components/posts/post_card_long.dart';
import 'package:quest/main.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/components/today_verse_glass.dart';
import 'package:quest/screens/post/new_post_screen.dart';
import 'package:quest/screens/messages/new_message_screen.dart';
import 'package:quest/components/messages/admin_message_card.dart';
import 'package:quest/components/messages/community_message_card.dart';
import 'package:quest/screens/post/post_screen.dart';
import 'package:provider/provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/community/community_bottom_sheets.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:quest/components/user_details/user_profile_card.dart';
import 'package:quest/components/avatar.dart';
import 'package:quest/screens/community/create_event_screen.dart';
import 'package:quest/screens/community/edit_event_screen.dart';
import 'package:quest/components/formatted_text.dart';

class CommunityIndividualScreen extends StatefulWidget {
  final String communityId;
  final Map<String, dynamic>? initialData;
  const CommunityIndividualScreen({
    super.key,
    required this.communityId,
    this.initialData,
  });

  @override
  State<CommunityIndividualScreen> createState() =>
      _CommunityIndividualScreenState();
}

class _CommunityIndividualScreenState extends State<CommunityIndividualScreen>
    with RouteAware {
  String selectedTab = "Space";
  final TextEditingController _forumController = TextEditingController();
  final ScrollController _forumScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pendingAttachment;
  bool _isVideo = false;
  String _selectedEventFilter = "All";
  Timer? _pollingTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    _loadData();
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      context.read<CommunityProvider>().loadCommunityDetails(
        authProvider.token!,
        widget.communityId,
      );
      context.read<CommunityProvider>().loadCommunityVerse(
        authProvider.token!,
        widget.communityId,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(() {
      if (_mainScrollController.position.pixels >=
          _mainScrollController.position.maxScrollExtent - 200) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.token != null) {
          if (selectedTab == "Space") {
            context.read<CommunityProvider>().loadMoreCommunityPosts(
              authProvider.token!,
              widget.communityId,
            );
          } else if (selectedTab == "Event") {
            context.read<CommunityProvider>().loadMoreCommunityEvents(
              authProvider.token!,
              widget.communityId,
            );
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();

      final authProvider = context.read<AuthProvider>();
      if (authProvider.token != null) {
        _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          if (mounted && selectedTab == "Forum") {
            context.read<CommunityProvider>().refreshCommunityMessages(
              authProvider.token!,
              widget.communityId,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    routeObserver.unsubscribe(this);
    _forumController.dispose();
    _forumScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_forumScrollController.hasClients) {
        _forumScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendForumMessage(
    BuildContext context,
    CommunityProvider communityProvider,
  ) {
    final text = _forumController.text.trim();
    if (text.isEmpty && _pendingAttachment == null) return;
    final auth = context.read<AuthProvider>();
    communityProvider.sendForumMessage(
      auth.token!,
      widget.communityId,
      text,
      mediaPath: _pendingAttachment?.path,
      isVideo: _isVideo,
    );
    _forumController.clear();
    setState(() => _pendingAttachment = null);
    _scrollToBottom();
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Share',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AttachmentOption(
                      icon: HugeIcons.strokeRoundedImage01,
                      label: 'Gallery',
                      color: const Color(0xFF7C5CFF),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final file = await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (file != null) {
                          setState(() {
                            _pendingAttachment = file;
                            _isVideo = false;
                          });
                        }
                      },
                    ),
                    _AttachmentOption(
                      icon: HugeIcons.strokeRoundedCamera01,
                      label: 'Camera',
                      color: const Color(0xFF00C2A8),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final file = await _imagePicker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 85,
                        );
                        if (file != null) {
                          setState(() {
                            _pendingAttachment = file;
                            _isVideo = false;
                          });
                        }
                      },
                    ),
                    _AttachmentOption(
                      icon: HugeIcons.strokeRoundedVideo01,
                      label: 'Video',
                      color: const Color(0xFFFF6B6B),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final file = await _imagePicker.pickVideo(
                          source: ImageSource.gallery,
                        );
                        if (file != null) {
                          setState(() {
                            _pendingAttachment = file;
                            _isVideo = true;
                          });
                        }
                      },
                    ),
                    _AttachmentOption(
                      icon: HugeIcons.strokeRoundedVideo02,
                      label: 'Record',
                      color: const Color(0xFFFF9500),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final file = await _imagePicker.pickVideo(
                          source: ImageSource.camera,
                        );
                        if (file != null) {
                          setState(() {
                            _pendingAttachment = file;
                            _isVideo = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _navigateToPostScreen(BuildContext context, Map<String, dynamic> post) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => PostScreen(post: post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        final community =
            context.read<CommunityProvider>().currentCommunity ??
            widget.initialData ??
            {};
        return Center(child: CommunityMenuDialogBox(community: community));
      },
    );
  }

  Widget _buildForumInputBar(
    BuildContext context,
    CommunityProvider communityProvider,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom:
            MediaQuery.of(context).viewInsets.bottom > 0
                ? 10
                : MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pending attachment preview
          if (_pendingAttachment != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 80,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        _isVideo
                            ? Container(
                              height: 80,
                              color: Colors.black,
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            )
                            : Image.file(
                              File(_pendingAttachment!.path),
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _pendingAttachment = null),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              GestureDetector(
                onTap: () => _showAttachmentOptions(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedAttachment01,
                    size: 22,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Text input
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 120),
                          child: TextField(
                            controller: _forumController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              hintStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 4),
                        child: IconButton(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedSmile,
                            size: 22,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              GestureDetector(
                onTap: () => _sendForumMessage(context, communityProvider),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        (_forumController.text.trim().isNotEmpty ||
                                _pendingAttachment != null)
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSent,
                    size: 20,
                    color:
                        (_forumController.text.trim().isNotEmpty ||
                                _pendingAttachment != null)
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final communityProvider = context.watch<CommunityProvider>();
    final community =
        communityProvider.currentCommunity ?? widget.initialData ?? {};
    final posts = communityProvider.currentPosts;
    final allEvents = communityProvider.currentEvents;
    final messages = communityProvider.currentMessages;
    final authId = context.read<AuthProvider>().user?['id'];

    final memberInfo = community['member'] as Map<String, dynamic>?;
    final isOwner = community['ownerId'] == authId;
    final isAdmin = isOwner || memberInfo?['role'] == 'ADMIN';
    final isSuspended = memberInfo?['isSuspended'] == true;
    final canPostForum =
        memberInfo?['canPostForum'] != false &&
        community['isForumDisabledGlobally'] != true;
    final canCreatePost = isAdmin || canPostForum;

    bool shouldShowAddButton = false;
    if (selectedTab == "Space" && canCreatePost) shouldShowAddButton = true;
    if (selectedTab == "Admin message" && isAdmin) shouldShowAddButton = true;
    if (selectedTab == "Event" && isAdmin) shouldShowAddButton = true;

    if (isSuspended) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                const Text(
                  'You have been suspended from this community.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Apply event filter
    List<dynamic> events = allEvents;
    if (_selectedEventFilter == 'Attending') {
      events =
          allEvents.where((e) {
            return (e['attendees'] as List<dynamic>?)?.any(
                  (a) => a['userId'] == authId,
                ) ==
                true;
          }).toList();
    } else if (_selectedEventFilter == 'Not attending') {
      events =
          allEvents.where((e) {
            return (e['attendees'] as List<dynamic>?)?.any(
                  (a) => a['userId'] == authId,
                ) !=
                true;
          }).toList();
    } else if (_selectedEventFilter == 'Upcoming') {
      events =
          allEvents.where((e) {
            try {
              final evtDate = DateTime.parse(e['date']);
              final now = DateTime.now();
              return evtDate.isAfter(
                DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).subtract(const Duration(days: 1)),
              );
            } catch (_) {
              return true;
            }
          }).toList();
    }

    final isMember =
        community['hasJoined'] == true ||
        communityProvider.communities.any((c) => c['id'] == community['id']);

    String formatCount(int count) {
      if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(0)}k';
      }
      return '$count';
    }

    if (!isMember) {
      final bool isPrivate = community['isPrivate'] ?? false;
      final bool hasPendingRequest = community['hasPendingRequest'] == true;
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleOne(
                  leadingIcon: HugeIcons.strokeRoundedCancel01,
                  title: "Communities Details",
                  leadingIconTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child:
                          community['image'] != null
                              ? CachedNetworkImage(
                                imageUrl: community['image'],
                                width: 75,
                                height: 75,
                                fit: BoxFit.cover,
                              )
                              : Image.asset(
                                "assets/images/boy.png",
                                width: 75,
                                height: 75,
                                fit: BoxFit.cover,
                              ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            community['name'] ?? 'Community',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            community['creator']?['username'] != null
                                ? '@${community['creator']['username']}'
                                : '@community',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor2,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Text(
                                formatCount(
                                  community['_count']?['members'] ?? 0,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Members",
                                style: TextStyle(
                                  color: AppTheme.textColor2,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isPrivate
                                          ? Colors.red.withValues(alpha: 0.1)
                                          : Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isPrivate ? "Private" : "Public",
                                  style: TextStyle(
                                    color:
                                        isPrivate ? Colors.red : Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ActionPillButton(
                        backgroundColor:
                            hasPendingRequest
                                ? AppTheme.surfaceColor
                                : Colors.black,
                        textColor:
                            hasPendingRequest
                                ? AppTheme.textColor2
                                : Colors.white,
                        label:
                            hasPendingRequest ? "Requested" : "Join Community",
                        onTap:
                            hasPendingRequest
                                ? null
                                : () async {
                                  final auth = context.read<AuthProvider>();
                                  await communityProvider.joinCommunity(
                                    auth.token!,
                                    community['id'],
                                  );
                                },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ActionPillButton(
                        icon: HugeIcons.strokeRoundedShare08,
                        label: "Share",
                        onTap: () {
                          final name = community['name'] ?? 'this community';
                          final communityId = community['id'];
                          final link =
                              communityId != null
                                  ? 'https://quest.vidarave.com/community/$communityId'
                                  : null;
                          showInAppShareSheet(
                            context,
                            shareMessage:
                                link != null
                                    ? 'Join $name on Quest! $link'
                                    : 'Join $name on Quest!',
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  community['description'] ?? 'No description available.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: AppTheme.textColor2,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const GuidelinesBottomSheet(),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.textColor2.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedSecurity,
                          size: 20,
                          color: AppTheme.textColor2,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Community Guidelines",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Forum tab gets its own full-screen layout with fixed bottom input
    if (selectedTab == 'Forum') {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: TitleOne(
                  leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                  title: community['name'] ?? 'Community',
                  trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                  leadingIconTap: () => setState(() => selectedTab = 'Space'),
                  trailingIconTap: () => _openMenu(context),
                ),
              ),
              // Tab pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionPillButton2(
                        icon: HugeIcons.strokeRoundedGlobe02,
                        iconColor:
                            selectedTab == "Space"
                                ? theme.colorScheme.surface
                                : theme.colorScheme.onSurface,
                        label: "Space",
                        backgroundColor:
                            selectedTab == "Space"
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                        textColor:
                            selectedTab == "Space"
                                ? theme.colorScheme.surface
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                        onTap: () => setState(() => selectedTab = "Space"),
                      ),
                      const SizedBox(width: 10),
                      ActionPillButton2(
                        icon: HugeIcons.strokeRoundedUserGroup,
                        iconColor:
                            selectedTab == "Forum"
                                ? theme.colorScheme.surface
                                : theme.colorScheme.onSurface,
                        label: "Forum",
                        backgroundColor:
                            selectedTab == "Forum"
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                        textColor:
                            selectedTab == "Forum"
                                ? theme.colorScheme.surface
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                        onTap: () => setState(() => selectedTab = "Forum"),
                      ),
                      const SizedBox(width: 10),
                      ActionPillButton2(
                        icon: HugeIcons.strokeRoundedMessage02,
                        iconColor:
                            selectedTab == "Admin message"
                                ? theme.colorScheme.surface
                                : theme.colorScheme.onSurface,
                        label: "Message",
                        backgroundColor:
                            selectedTab == "Admin message"
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                        textColor:
                            selectedTab == "Admin message"
                                ? theme.colorScheme.surface
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                        onTap:
                            () => setState(() => selectedTab = "Admin message"),
                      ),
                      const SizedBox(width: 10),
                      ActionPillButton2(
                        icon: HugeIcons.strokeRoundedCalendar02,
                        iconColor:
                            selectedTab == "Event"
                                ? theme.colorScheme.surface
                                : theme.colorScheme.onSurface,
                        label: "Event",
                        backgroundColor:
                            selectedTab == "Event"
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                        textColor:
                            selectedTab == "Event"
                                ? theme.colorScheme.surface
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                        onTap: () => setState(() => selectedTab = "Event"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Messages list (scrollable, grows)
              Expanded(
                child:
                    messages.isNotEmpty
                        ? RefreshIndicator(
                          onRefresh: () async {
                            final auth = context.read<AuthProvider>();
                            if (auth.token != null) {
                              await communityProvider.loadCommunityDetails(
                                auth.token!,
                                community['id'],
                              );
                            }
                          },
                          child: ListView.builder(
                            reverse: true,
                            controller: _forumScrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount:
                                messages.length +
                                (communityProvider.hasMoreMessages ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == messages.length) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  final auth = context.read<AuthProvider>();
                                  communityProvider.loadMoreCommunityMessages(
                                    auth.token!,
                                    community['id'],
                                  );
                                });
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }
                              final msg = messages[index];
                              final user = msg['sender'] ?? msg['user'] ?? {};
                              final isMe =
                                  user['id'] ==
                                  context.read<AuthProvider>().user?['id'];

                              final firstName =
                                  (user['firstName'] ?? '').toString().trim();
                              final lastName =
                                  (user['lastName'] ?? '').toString().trim();
                              final fullName = '$firstName $lastName'.trim();
                              final displayName =
                                  fullName.isNotEmpty
                                      ? fullName
                                      : (user['username'] ?? '').toString();
                              final avatarUrl = user['avatarUrl']?.toString();

                              String formattedTime = '';
                              if (msg['createdAt'] != null) {
                                final dt =
                                    DateTime.parse(msg['createdAt']).toLocal();
                                final now = DateTime.now();
                                final hm = DateFormat('h:mm a').format(dt);
                                if (dt.year == now.year &&
                                    dt.month == now.month &&
                                    dt.day == now.day) {
                                  formattedTime = hm;
                                } else {
                                  formattedTime =
                                      '${DateFormat('MMM d').format(dt)} $hm';
                                }
                              }

                              final hasImageAttachment =
                                  msg['imageUrl'] != null;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      isMe
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Avatar for other users
                                    if (!isMe) ...[
                                      GestureDetector(
                                        onTap: () {
                                          context
                                                  .read<CommunityProvider>()
                                                  .currentCommunity ??
                                              {};
                                          UserProfileCard.show(context, user);
                                        },
                                        child: CustomAvatar(
                                          imageUrl: avatarUrl,
                                          radius: 18,
                                          hasBorder: false,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    // Bubble
                                    Flexible(
                                      child: GestureDetector(
                                        onLongPress: () {
                                          if (isAdmin || isMe) {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return SafeArea(
                                                  child: Wrap(
                                                    children: [
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        title: const Text(
                                                          'Delete Message',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          if (authId != null) {
                                                            await context
                                                                .read<
                                                                  CommunityProvider
                                                                >()
                                                                .deleteForumMessage(
                                                                  context
                                                                      .read<
                                                                        AuthProvider
                                                                      >()
                                                                      .token!,
                                                                  msg['id'],
                                                                );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              isMe
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                          children: [
                                            // Sender name (others only)
                                            if (!isMe)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4,
                                                  left: 4,
                                                ),
                                                child: Text(
                                                  displayName,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            // Image attachment preview
                                            if (hasImageAttachment)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        ApiService.getFullImageUrl(
                                                          msg['imageUrl'],
                                                        ),
                                                    width: 200,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const SizedBox(),
                                                  ),
                                                ),
                                              ),
                                            // Text bubble (only if text present)
                                            if ((msg['text'] ?? '')
                                                .toString()
                                                .trim()
                                                .isNotEmpty)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      isMe
                                                          ? Colors.black
                                                          : Colors
                                                              .grey
                                                              .shade200,
                                                  borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        const Radius.circular(
                                                          20,
                                                        ),
                                                    topRight:
                                                        const Radius.circular(
                                                          20,
                                                        ),
                                                    bottomLeft: Radius.circular(
                                                      isMe ? 20 : 4,
                                                    ),
                                                    bottomRight:
                                                        Radius.circular(
                                                          isMe ? 4 : 20,
                                                        ),
                                                  ),
                                                ),
                                                child: FormattedText(
                                                  msg['text'] ?? '',
                                                  style: TextStyle(
                                                    color:
                                                        isMe
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            // Timestamp
                                            if (formattedTime.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                  left: 4,
                                                  right: 4,
                                                ),
                                                child: Text(
                                                  formattedTime,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade400,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Spacer so my bubble doesn't touch the edge
                                    if (isMe) const SizedBox(width: 8),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet.\nBe the first to say something!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
              // Fixed bottom input bar
              if (canPostForum) _buildForumInputBar(context, communityProvider),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: RefreshIndicator(
            onRefresh: () async {
              final auth = context.read<AuthProvider>();
              if (auth.token != null) {
                await context.read<CommunityProvider>().loadCommunityDetails(
                  auth.token!,
                  community['id'],
                );
              }
            },
            child: SingleChildScrollView(
              controller: _mainScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE BAR
                  TitleOne(
                    leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                    title:
                        isMember
                            ? (community['name'] ?? 'Community')
                            : 'Communities Details',
                    trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                    leadingIconTap: () => Navigator.pop(context),
                    trailingIconTap: () => _openMenu(context),
                  ),
                  const SizedBox(height: 25),

                  if (isMember) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Search Bar
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedSearch01,
                                  size: 18,
                                  color: AppTheme.textColor2,
                                ),
                                const SizedBox(width: 8),

                                /// Search Input
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Search communities",
                                      border: InputBorder.none,
                                      isDense: true,
                                      hintStyle: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (shouldShowAddButton) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              if (selectedTab == "Event") {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder:
                                      (ctx) => CreateEventScreen(
                                        communityId: widget.communityId,
                                      ),
                                );
                              } else if (selectedTab == "Admin message") {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return NewMessageScreen(
                                      communityId: widget.communityId,
                                    );
                                  },
                                );
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return NewPostScreen(
                                      communityId: widget.communityId,
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedAdd01,
                                size: 22,
                                color: theme.colorScheme.onSurface,
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 25),
                  ],

                  /// Community Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child:
                            community['image'] != null
                                ? CachedNetworkImage(
                                  imageUrl: community['image']!,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  "assets/images/boy.png",
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              community['name'] ?? 'Community',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@admin',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder:
                                          (context) => MembersBottomSheet(
                                            community: community,
                                          ),
                                    );
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${formatCount(community['_count']?['members'] ?? 0)} ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Members',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isMember) ...[
                                  const SizedBox(width: 15),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedTab = "Event";
                                      });
                                    },
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${allEvents.length} ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Events',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      final name = community['name'] ?? 'this community';
                      final communityId = community['id'];
                      final link =
                          communityId != null
                              ? 'https://quest.vidarave.com/community/$communityId'
                              : null;
                      showInAppShareSheet(
                        context,
                        shareMessage:
                            link != null
                                ? 'Join $name on Quest! $link'
                                : 'Join $name on Quest!',
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedShare01,
                            size: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Share Community',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    community['description'] ?? 'Welcome to our community!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textColor2,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),

                  if (isMember) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionPillButton2(
                            icon: HugeIcons.strokeRoundedGlobe02,
                            iconColor:
                                selectedTab == "Space"
                                    ? theme.colorScheme.surface
                                    : theme.colorScheme.onSurface,
                            label: "Space",
                            backgroundColor:
                                selectedTab == "Space"
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                            textColor:
                                selectedTab == "Space"
                                    ? theme.colorScheme.surface
                                    : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                            onTap: () => setState(() => selectedTab = "Space"),
                          ),
                          const SizedBox(width: 10),
                          ActionPillButton2(
                            icon: HugeIcons.strokeRoundedUserGroup,
                            iconColor:
                                selectedTab == "Forum"
                                    ? theme.colorScheme.surface
                                    : theme.colorScheme.onSurface,
                            label: "Forum",
                            backgroundColor:
                                selectedTab == "Forum"
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                            textColor:
                                selectedTab == "Forum"
                                    ? theme.colorScheme.surface
                                    : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                            onTap: () => setState(() => selectedTab = "Forum"),
                          ),
                          const SizedBox(width: 10),
                          ActionPillButton2(
                            icon: HugeIcons.strokeRoundedMessage02,
                            iconColor:
                                selectedTab == "Admin message"
                                    ? theme.colorScheme.surface
                                    : theme.colorScheme.onSurface,
                            label: "Message",
                            backgroundColor:
                                selectedTab == "Admin message"
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                            textColor:
                                selectedTab == "Admin message"
                                    ? theme.colorScheme.surface
                                    : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                            onTap:
                                () => setState(
                                  () => selectedTab = "Admin message",
                                ),
                          ),
                          const SizedBox(width: 10),
                          ActionPillButton2(
                            icon: HugeIcons.strokeRoundedCalendar02,
                            iconColor:
                                selectedTab == "Event"
                                    ? theme.colorScheme.surface
                                    : theme.colorScheme.onSurface,
                            label: "Event",
                            backgroundColor:
                                selectedTab == "Event"
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                            textColor:
                                selectedTab == "Event"
                                    ? theme.colorScheme.surface
                                    : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                            onTap: () => setState(() => selectedTab = "Event"),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (selectedTab == "Space")
                    Column(
                      children: [
                        const SizedBox(height: 25),
                        Consumer<CommunityProvider>(
                          builder:
                              (context, cp, _) => TodayVerseGlass(
                                isCommunityVerse: true,
                                communityId: widget.communityId,
                                verseData: cp.currentVerse,
                              ),
                        ),

                        Builder(
                          builder: (context) {
                            final now = DateTime.now();
                            final todayMessages =
                                communityProvider.adminMessages.where((msg) {
                                  if (msg['createdAt'] == null) return false;
                                  try {
                                    final date =
                                        DateTime.parse(
                                          msg['createdAt'],
                                        ).toLocal();
                                    return date.year == now.year &&
                                        date.month == now.month &&
                                        date.day == now.day;
                                  } catch (e) {
                                    return false;
                                  }
                                }).toList();

                            if (todayMessages.isNotEmpty) {
                              final latestMessage = todayMessages.first;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionHeader(
                                    title: "Today's Sermons",
                                    showSeeAll: false,
                                  ),
                                  AdminMessageCard(message: latestMessage),
                                ],
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        const SectionHeader(title: "Posts", showSeeAll: false),

                        /// POSTS LIST
                        Builder(
                          builder: (context) {
                            final communityPosts = posts;
                            if (communityPosts.isNotEmpty) {
                              return Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: communityPosts.length,
                                    itemBuilder: (context, index) {
                                      final post = communityPosts[index];
                                      final user = post['user'] ?? {};
                                      final userName =
                                          "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}"
                                              .trim();
                                      final isMe = user['id'] == authId;
                                      final canDeletePost = isAdmin || isMe;
                                      return PostCardLong(
                                        userName:
                                            userName.isEmpty
                                                ? (user['username'] ?? '')
                                                : userName,
                                        userImage:
                                            user['avatarUrl'] ??
                                            "assets/images/boy.png",
                                        postText: post["text"] ?? '',
                                        groupName: community['name'] ?? '',
                                        postImage:
                                            post["image"] ??
                                            "assets/images/test.jpg",
                                        likes:
                                            "${post['postLikes']?.length ?? 0}",
                                        comments:
                                            "${post['_count']?['comments'] ?? 0}",
                                        time:
                                            post['createdAt'] != null
                                                ? timeago.format(
                                                  DateTime.parse(
                                                    post['createdAt'],
                                                  ),
                                                )
                                                : "Recently",
                                        onTap:
                                            () => _navigateToPostScreen(
                                              context,
                                              post,
                                            ),
                                        onAvatarTap: () {
                                          UserProfileCard.show(context, user);
                                        },
                                        onMoreTap:
                                            canDeletePost
                                                ? () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder: (context) {
                                                      return SafeArea(
                                                        child: Wrap(
                                                          children: [
                                                            ListTile(
                                                              leading:
                                                                  const Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                              title: const Text(
                                                                'Delete Post',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                if (authId !=
                                                                    null) {
                                                                  await context
                                                                      .read<
                                                                        CommunityProvider
                                                                      >()
                                                                      .deleteCommunityPost(
                                                                        context
                                                                            .read<
                                                                              AuthProvider
                                                                            >()
                                                                            .token!,
                                                                        post['id'],
                                                                      );
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                                : null,
                                      );
                                    },
                                  ),
                                  if (communityProvider.isLoadingMorePosts)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No posts yet."),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                  // Forum tab is rendered in a separate full-screen Scaffold above.
                  // This placeholder is never reached when selectedTab == 'Forum'.
                  if (selectedTab == "Admin message")
                    Column(
                      children: [
                        SizedBox(height: 25),
                        Builder(
                          builder: (context) {
                            final communityMessages =
                                communityProvider.adminMessages;
                            if (communityMessages.isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                    ),
                                    child: Text(
                                      "All Message",
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: communityMessages.length,
                                    itemBuilder: (context, index) {
                                      final message = communityMessages[index];
                                      return CommunityMessageCard(
                                        message: message,
                                      );
                                    },
                                  ),
                                ],
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No messages yet."),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                  if (selectedTab == "Event")
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        SectionHeader(
                          title: "All event",
                          seeAllText: "Filter",
                          onSeeAllTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return _EventFilterOption(
                                  currentFilter: _selectedEventFilter,
                                  onFilterSelected: (val) {
                                    setState(() => _selectedEventFilter = val);
                                  },
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 5),

                        if (events.isNotEmpty)
                          Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  final auth = context.read<AuthProvider>();
                                  final currentUserId = auth.user?['id'];
                                  final attendees = List.from(
                                    event['attendees'] ?? [],
                                  );
                                  bool isAttending = attendees.any(
                                    (a) => a['userId'] == currentUserId,
                                  );

                                  return EventDottedCard(
                                    event: event,
                                    isAttending: isAttending,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) {
                                          return EventDetailsCard(
                                            event: event,
                                            isAttending: isAttending,
                                            isAdmin: isAdmin,
                                            onEdit: () {
                                              Navigator.pop(context);
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder:
                                                    (context) =>
                                                        EditEventScreen(
                                                          communityId:
                                                              widget
                                                                  .communityId,
                                                          event: event,
                                                        ),
                                              );
                                            },
                                            onDelete: () async {
                                              final success =
                                                  await communityProvider
                                                      .deleteEvent(
                                                        auth.token!,
                                                        widget.communityId,
                                                        event['id'],
                                                      );
                                              if (success && context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            onToggleAttend: () async {
                                              if (isAttending) {
                                                await communityProvider
                                                    .unattendEvent(
                                                      auth.token!,
                                                      event['id'],
                                                    );
                                              } else {
                                                await communityProvider
                                                    .attendEvent(
                                                      auth.token!,
                                                      event['id'],
                                                    );
                                              }
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              if (communityProvider.isLoadingMoreEvents)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("No events scheduled yet."),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper widget for the attachment option buttons in the bottom sheet
class _AttachmentOption extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, size: 26, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Replaced with CommunityMenuDialogBox
class _EventFilterOption extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterSelected;

  const _EventFilterOption({
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.textColor2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          SizedBox(height: 25),
          _buildFilterOption(context, 'All'),
          _buildFilterOption(context, 'Attending'),
          _buildFilterOption(context, 'Not attending'),
          _buildFilterOption(context, 'Upcoming'),
        ],
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String filter) {
    return GestureDetector(
      onTap: () {
        onFilterSelected(filter);
        Navigator.pop(context);
      },
      child: SettingsRowItem(
        iconBackgroundColor: Colors.transparent,
        title: filter,
        iconColor: filter == currentFilter ? Colors.blue : AppTheme.textColor2,
        secondIconColor: Colors.transparent,
      ),
    );
  }
}
