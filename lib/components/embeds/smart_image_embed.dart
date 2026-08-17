import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

/// Custom image embed builder that correctly renders both:
/// - Local file paths (e.g. /data/user/0/.../image.jpg) — instant preview
/// - Remote URLs (e.g. https://cdn.example.com/image.jpg) — after upload
class SmartImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final path = embedContext.node.value.data as String;

    // A path is "remote" if it starts with http/https, or is a relative /api path
    // (legacy records before we switched to absolute URLs).
    final isRemote =
        path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('/api');

    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          isRemote
              ? CachedNetworkImage(
                imageUrl: path.startsWith('/api')
                    ? ApiService.getFullImageUrl(path)
                    : path,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => _errorWidget(context),
              )
              : Image.file(
                File(path),
                fit: BoxFit.cover,
              ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child:
          embedContext.readOnly
              ? imageWidget
              : Stack(
                children: [
                  imageWidget,
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed:
                            () => _confirmDelete(
                              context,
                              embedContext,
                              path,
                              isRemote,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    EmbedContext embedContext,
    String path,
    bool isRemote,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Image'),
            content: const Text(
              'Are you sure you want to permanently delete this image?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);

                  if (isRemote) {
                    final token =
                        Provider.of<AuthProvider>(context, listen: false).token;
                    if (token != null) {
                      try {
                        await ApiService.deleteMedia(token, path);
                      } catch (e) {
                        debugPrint('Failed to delete remote image: $e');
                      }
                    }
                  }

                  // Remove from Quill Editor
                  final nodeOffset = embedContext.node.documentOffset;
                  final nodeLength = embedContext.node.length;
                  embedContext.controller.replaceText(
                    nodeOffset,
                    nodeLength,
                    '',
                    TextSelection.collapsed(offset: nodeOffset),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _errorWidget(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
