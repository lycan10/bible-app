import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams;
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/chat_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/avatar.dart';

/// Shows the in-app share bottom sheet.
///
/// [shareMessage] is the full text that will be sent as a DM and/or
/// passed to the OS share sheet (e.g. "Check out this post on Quest! <link>").
void showInAppShareSheet(BuildContext context, {required String shareMessage}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => InAppShareSheet(shareMessage: shareMessage),
  );
}

class InAppShareSheet extends StatefulWidget {
  final String shareMessage;

  const InAppShareSheet({super.key, required this.shareMessage});

  @override
  State<InAppShareSheet> createState() => _InAppShareSheetState();
}

class _InAppShareSheetState extends State<InAppShareSheet>
    with SingleTickerProviderStateMixin {
  List<dynamic> _friends = [];
  List<dynamic> _filtered = [];
  final Set<String> _selected = {};
  bool _isLoading = true;
  bool _isSending = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadFriends();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final friends = await ApiService.fetchFriends(auth.token!);
      if (mounted) {
        setState(() {
          _friends = friends;
          _filtered = friends;
          _isLoading = false;
        });
        _animController.forward();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _friends;
      } else {
        _filtered =
            _friends.where((f) {
              final name =
                  '${f['firstName'] ?? ''} ${f['lastName'] ?? ''}'
                      .toLowerCase();
              final username = (f['username'] ?? '').toLowerCase();
              return name.contains(q) || username.contains(q);
            }).toList();
      }
    });
  }

  void _toggleSelect(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _sendToSelected() async {
    if (_selected.isEmpty) return;
    setState(() => _isSending = true);

    final auth = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (auth.token == null) {
      setState(() => _isSending = false);
      return;
    }

    int sentCount = 0;
    for (final friendId in _selected) {
      try {
        final chat = await chatProvider.startChat(auth.token!, friendId);
        if (chat != null) {
          await chatProvider.sendMessage(
            auth.token!,
            chat['id'],
            widget.shareMessage,
          );
          sentCount++;
        }
      } catch (_) {}
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sentCount == 1 ? 'Sent to 1 person!' : 'Sent to $sentCount people!',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.purpleColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Handle bar ──
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share with',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (_selected.isNotEmpty)
                  GestureDetector(
                    onTap: _isSending ? null : _sendToSelected,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _isSending
                                ? AppTheme.purpleColor.withValues(alpha: 0.6)
                                : AppTheme.purpleColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child:
                          _isSending
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                'Send (${_selected.length})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    size: 18,
                    color: AppTheme.textColor2,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search connections...',
                        hintStyle: TextStyle(fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Friends grid ──
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.purpleColor,
                      ),
                    )
                    : _filtered.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _friends.isEmpty
                                ? 'No connections yet'
                                : 'No results found',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : FadeTransition(
                      opacity: _fadeAnim,
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final friend = _filtered[index];
                          final id = friend['id']?.toString() ?? '';
                          final isSelected = _selected.contains(id);
                          final firstName = friend['firstName'] ?? '';
                          final username = friend['username'] ?? '';
                          final displayName =
                              firstName.isNotEmpty ? firstName : '@$username';
                          final avatarUrl = friend['avatarUrl'];

                          return GestureDetector(
                            onTap: () => _toggleSelect(id),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    // Avatar
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppTheme.purpleColor
                                                  : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                      child: CustomAvatar(
                                        radius: 32,
                                        imageUrl: avatarUrl != null && avatarUrl.toString().isNotEmpty
                                            ? ApiService.getFullImageUrl(avatarUrl)
                                            : null,
                                      ),
                                    ),

                                    // Checkmark badge
                                    if (isSelected)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.purpleColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? AppTheme.purpleColor
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
          ),

          // ── Divider + External share ──
          const Divider(height: 1),
          _ExternalShareRow(shareMessage: widget.shareMessage),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ExternalShareRow extends StatelessWidget {
  final String shareMessage;
  const _ExternalShareRow({required this.shareMessage});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        SharePlus.instance.share(ShareParams(text: shareMessage));
      },
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedShare08,
          size: 20,
          color: AppTheme.textColor2,
        ),
      ),
      title: const Text(
        'Share via external apps',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text(
        'WhatsApp, Messages, Instagram\u2026',
        style: TextStyle(fontSize: 12),
      ),
      trailing: const HugeIcon(
        icon: HugeIcons.strokeRoundedArrowRight01,
        size: 18,
        color: AppTheme.textColor2,
      ),
    );
  }
}
