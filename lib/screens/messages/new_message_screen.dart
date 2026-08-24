import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/utils/media_helper.dart';
import 'package:file_picker/file_picker.dart';

class NewMessageScreen extends StatefulWidget {
  final String communityId;
  final Map<String, dynamic>? initialMessage;

  const NewMessageScreen({
    super.key,
    required this.communityId,
    this.initialMessage,
  });

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;
  File? _selectedMedia;
  File? _selectedThumbnail;
  String _mediaType = 'Photo'; // Photo, Video, Audio
  
  String? _existingMediaUrl;
  String? _existingThumbnailUrl;

  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      _controller.text = widget.initialMessage!['text'] ?? '';
      _charCount = _controller.text.length;
      if (widget.initialMessage!['imageUrl'] != null) {
        _mediaType = 'Photo';
        _existingMediaUrl = widget.initialMessage!['imageUrl'];
      } else if (widget.initialMessage!['videoUrl'] != null) {
        _mediaType = 'Video';
        _existingMediaUrl = widget.initialMessage!['videoUrl'];
        _existingThumbnailUrl = widget.initialMessage!['videoThumbnail'];
      } else if (widget.initialMessage!['audioUrl'] != null) {
        _mediaType = 'Audio';
        _existingMediaUrl = widget.initialMessage!['audioUrl'];
        _existingThumbnailUrl = widget.initialMessage!['audioThumbnail'];
      }
    }
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  void _removeExistingMedia() {
    setState(() {
      _existingMediaUrl = null;
      _existingThumbnailUrl = null;
      _selectedMedia = null;
      _selectedThumbnail = null;
    });
  }

  Future<void> _pickMedia() async {
    if (_mediaType == 'Photo' || _mediaType == 'Video') {
      final media = _mediaType == 'Photo' 
        ? await MediaHelper.pickAndCompressImage(source: ImageSource.gallery)
        : await MediaHelper.pickAndCompressImage(source: ImageSource.gallery, isVideo: true);
      
      if (media != null) {
        setState(() {
          _selectedMedia = media;
        });
      }
    } else if (_mediaType == 'Audio') {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedMedia = File(result.files.single.path!);
        });
      }
    }
  }

  Future<void> _pickThumbnail() async {
    final image = await MediaHelper.pickAndCompressImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedThumbnail = image;
      });
    }
  }

  Future<void> _submitMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedMedia == null) return;

    setState(() => _isPosting = true);

    final auth = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();

    String? mediaUrl;
    String? thumbnailUrl;

    if (_selectedMedia != null) {
      try {
        final res = await ApiService.uploadMedia(
          auth.token!,
          _selectedMedia!.path,
          isEdit: widget.initialMessage != null,
        );
        mediaUrl = res['url'] ?? res['fileUrl'];
      } catch (e) {
        if (mounted) {
          final errorMessage = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage.isNotEmpty ? errorMessage : 'Failed to upload media. Please try again.'),
            ),
          );
          setState(() => _isPosting = false);
        }
        return;
      }
    }

    if (_selectedThumbnail != null) {
      try {
        final res = await ApiService.uploadMedia(
          auth.token!,
          _selectedThumbnail!.path,
          isEdit: widget.initialMessage != null,
        );
        thumbnailUrl = res['url'] ?? res['fileUrl'];
      } catch (e) {
        if (mounted) {
          final errorMessage = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage.isNotEmpty ? errorMessage : 'Failed to upload thumbnail. Please try again.'),
            ),
          );
          setState(() => _isPosting = false);
        }
        return;
      }
    }

    String? imageUrl = _mediaType == 'Photo' ? mediaUrl : null;
    String? videoUrl = _mediaType == 'Video' ? mediaUrl : null;
    String? audioUrl = _mediaType == 'Audio' ? mediaUrl : null;
    String? videoThumbnail = (_mediaType == 'Video' || _mediaType == 'Audio') ? thumbnailUrl : null;
    String? audioThumbnail = _mediaType == 'Audio' ? thumbnailUrl : null;

    if (widget.initialMessage != null) {
      // If we didn't upload new media, fallback to existing media
      if (mediaUrl == null && _existingMediaUrl != null) {
        if (_mediaType == 'Photo') imageUrl = _existingMediaUrl;
        if (_mediaType == 'Video') videoUrl = _existingMediaUrl;
        if (_mediaType == 'Audio') audioUrl = _existingMediaUrl;
      }
      if (thumbnailUrl == null && _existingThumbnailUrl != null) {
        if (_mediaType == 'Video') videoThumbnail = _existingThumbnailUrl;
        if (_mediaType == 'Audio') audioThumbnail = _existingThumbnailUrl;
      }

      final success = await communityProvider.updateAdminMessage(
        auth.token!,
        widget.initialMessage!['id'],
        text,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        audioUrl: audioUrl,
        videoThumbnail: videoThumbnail,
        audioThumbnail: audioThumbnail,
      );

      if (mounted) {
        setState(() => _isPosting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message updated successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update message. Please try again.'),
            ),
          );
        }
      }
      return;
    }

    final success = await communityProvider.sendAdminMessage(
      auth.token!,
      widget.communityId,
      text,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      audioUrl: audioUrl,
      videoThumbnail: videoThumbnail,
      audioThumbnail: audioThumbnail,
    );

    if (mounted) {
      setState(() => _isPosting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final userName =
        "${auth.user?['firstName'] ?? ''} ${auth.user?['lastName'] ?? ''}"
            .trim();
    final avatarUrl = auth.user?['avatarUrl'];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
                Text(
                  widget.initialMessage != null ? 'Edit Message' : 'New Message',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: _isPosting ? null : _submitMessage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isPosting ? Colors.grey : const Color(0xff4a3aff),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child:
                        _isPosting
                            ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Send',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.1,
                  ),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child:
                      avatarUrl == null
                          ? HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            size: 20,
                            color: theme.colorScheme.onSurface,
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Text(
                  userName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Caption Input
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: TextField(
                controller: _controller,
                maxLines: null,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: "What do you want to say to the community?",
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Type Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Photo', 'Video', 'Audio'].map((type) {
                final isSelected = _mediaType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _mediaType = type;
                      _selectedMedia = null;
                      _selectedThumbnail = null;
                      _existingMediaUrl = null;
                      _existingThumbnailUrl = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xff4a3aff) : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Attachments
            Row(
              children: [
                GestureDetector(
                  onTap: _pickMedia,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: HugeIcon(
                      icon: _mediaType == 'Photo' ? HugeIcons.strokeRoundedImage01 : (_mediaType == 'Video' ? HugeIcons.strokeRoundedVideo01 : HugeIcons.strokeRoundedMusicNote01),
                      size: 24,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_selectedMedia != null) ...[
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      _selectedMedia!.path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ] else if (_existingMediaUrl != null) ...[
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Existing $_mediaType',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
                if (_selectedMedia != null || _existingMediaUrl != null)
                  GestureDetector(
                    onTap: _removeExistingMedia,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedDelete01,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Thumbnail Option (for Video/Audio)
            if (_mediaType == 'Video' || _mediaType == 'Audio') ...[
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickThumbnail,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedImageAdd01,
                        size: 24,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      _selectedThumbnail != null ? _selectedThumbnail!.path.split('/').last : (_existingThumbnailUrl != null ? 'Existing Thumbnail' : 'Add Thumbnail (Optional)'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: (_selectedThumbnail != null || _existingThumbnailUrl != null) ? 1.0 : 0.5),
                        fontWeight: _existingThumbnailUrl != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (_selectedThumbnail != null || _existingThumbnailUrl != null)
                    GestureDetector(
                      onTap: () => setState(() { _selectedThumbnail = null; _existingThumbnailUrl = null; }),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete01,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
