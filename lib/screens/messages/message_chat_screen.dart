import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/user_details/user_profile_card.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/chat_provider.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/avatar.dart';

class MessageChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> friend;

  const MessageChatScreen({
    super.key,
    required this.chatId,
    required this.friend,
  });

  @override
  State<MessageChatScreen> createState() => _MessageChatScreenState();
}

class _MessageChatScreenState extends State<MessageChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  XFile? _pendingAttachment;
  bool _isVideo = false;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<ChatProvider>().loadMessages(auth.token!, widget.chatId);
        _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (mounted) {
            context.read<ChatProvider>().loadMessages(
              auth.token!,
              widget.chatId,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _pendingAttachment == null) return;

    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      setState(() => _isSending = true);
      _textController.clear();

      String? imageUrl;
      if (_pendingAttachment != null) {
        try {
          final res = await ApiService.uploadMedia(
            auth.token!,
            _pendingAttachment!.path,
          );
          imageUrl = res['url'];
        } catch (e) {
          debugPrint("Error uploading media: $e");
        }
      }

      setState(() => _pendingAttachment = null);

      final ok = await context.read<ChatProvider>().sendMessage(
        auth.token!,
        widget.chatId,
        text,
        image: imageUrl,
      );
      setState(() => _isSending = false);
      if (ok) {
        _scrollToBottom();
      }
    }
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
                      color: const Color(0xFFFF4E7B),
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
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatProvider = context.watch<ChatProvider>();
    final authProvider = context.watch<AuthProvider>();
    final messages = chatProvider.getMessages(widget.chatId);
    final currentUserId = authProvider.user?['id'];

    final friendName =
        '${widget.friend['firstName'] ?? ''} ${widget.friend['lastName'] ?? ''}'
            .trim();
    final friendAvatar = widget.friend['avatarUrl'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 24,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            friendName.isNotEmpty
                                ? friendName
                                : '@${widget.friend['username'] ?? 'User'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return const UserProfileCard();
                            },
                          );
                        },
                        child: CustomAvatar(
                          radius: 20,
                          imageUrl: friendAvatar != null && friendAvatar.toString().isNotEmpty
                                  ? ApiService.getFullImageUrl(friendAvatar)
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Filter",
                            barrierColor: Colors.black.withValues(alpha: 0.4),
                            transitionDuration: const Duration(
                              milliseconds: 250,
                            ),
                            pageBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                            ) {
                              return Center(
                                child: _ChatMenuDialogBox(
                                  friendName: friendName,
                                  chatId: widget.chatId,
                                  friendId: widget.friend['id'],
                                  friendData: widget.friend,
                                ),
                              );
                            },
                          );
                        },
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMoreVertical,
                          size: 24,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// 🔹 Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['senderId'] == currentUserId;
                  return ChatBubble(
                    message: msg['text'] ?? '',
                    imageUrl: msg['image'],
                    isMe: isMe,
                  );
                },
              ),
            ),

            /// 🔹 Message Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  if (_pendingAttachment != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                _isVideo
                                    ? Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.black12,
                                      child: const Center(
                                        child: Icon(
                                          Icons.videocam,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    )
                                    : Image.file(
                                      File(_pendingAttachment!.path),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _pendingAttachment!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed:
                                () => setState(() => _pendingAttachment = null),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAttachmentOptions(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedAdd01,
                            size: 22,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _textController,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 14.0,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.completedColor,
                            shape: BoxShape.circle,
                          ),
                          child:
                              _isSending
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const HugeIcon(
                                    icon: HugeIcons.strokeRoundedSent,
                                    size: 18,
                                    color: Colors.white,
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
      ),
    );
  }
}

class _ChatMenuDialogBox extends StatelessWidget {
  final String friendName;
  final String chatId;
  final String friendId;
  final Map<String, dynamic> friendData;
  const _ChatMenuDialogBox({
    required this.friendName,
    required this.chatId,
    required this.friendId,
    required this.friendData,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    final isPinned = chatProvider.isChatPinned(chatId);

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            SettingsRowItem(
              onTap: () {
                Navigator.pop(context); // close menu
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return UserProfileCard(user: friendData);
                  },
                );
              },
              icon: HugeIcons.strokeRoundedUser,
              iconBackgroundColor: Colors.transparent,
              title: 'View profile',
              iconColor: AppTheme.textColor2,
            ),
            SettingsRowItem(
              onTap: () async {
                if (authProvider.token != null) {
                  if (isPinned) {
                    await chatProvider.unpinChat(authProvider.token!, chatId);
                  } else {
                    await chatProvider.pinChat(authProvider.token!, chatId);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: HugeIcons.strokeRoundedPin,
              iconBackgroundColor: Colors.transparent,
              title: isPinned ? 'Unpin chat' : 'Pin chat',
              iconColor: AppTheme.textColor2,
            ),
            SettingsRowItem(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (c) => AlertDialog(
                        title: const Text('Clear Chat'),
                        content: const Text(
                          'Are you sure you want to clear this chat? Messages will be deleted for you.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
                if (confirm == true && authProvider.token != null) {
                  await chatProvider.clearChat(authProvider.token!, chatId);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: HugeIcons.strokeRoundedDelete01,
              iconBackgroundColor: Colors.transparent,
              title: 'Clear chat',
              iconColor: AppTheme.textColor2,
            ),
            SettingsRowItem(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (c) => AlertDialog(
                        title: const Text('Block User'),
                        content: Text(
                          'Are you sure you want to block $friendName?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text(
                              'Block',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  final ok = await authProvider.blockUser(friendId);
                  if (ok && context.mounted) {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // close chat screen
                  }
                }
              },
              icon: HugeIcons.strokeRoundedRemoveCircle,
              iconBackgroundColor: Colors.transparent,
              title: 'Block $friendName',
              iconColor: AppTheme.textColor2,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final String? imageUrl;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    this.imageUrl,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color:
              isMe
                  ? AppTheme.purpleColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (message.isNotEmpty)
              Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isMe ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final dynamic icon;
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
