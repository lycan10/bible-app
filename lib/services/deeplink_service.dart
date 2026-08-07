import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/main.dart'; // To access navigatorKey
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/screens/community/community_individual_screen.dart';
import 'package:quest/screens/post/post_screen.dart';
import 'package:quest/screens/devotion/devotion_screen.dart';
import 'package:quest/screens/media/video_reel_screen.dart';
import 'package:quest/screens/media/audio_reel_screen.dart';
import 'package:quest/screens/books/book_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();

  static void init() {
    // Check initial link if app was in cold state (terminated)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Handle link when app is in warm state (foreground or background)
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  static Future<void> handleUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (uri.host == 'quest.vidarave.com') {
        _handleDeepLink(uri);
      } else {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint("Error handling URL: $e");
    }
  }

  static void _handleDeepLink(Uri uri) {
    debugPrint("App Links: Received deep link: $uri");

    if (uri.host != 'quest.vidarave.com') return;

    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return;

    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    final resource = pathSegments[0];
    final id = pathSegments.length > 1 ? pathSegments[1] : null;

    switch (resource) {
      case 'community':
        if (id != null) {
          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (_) => CommunityIndividualScreen(communityId: id),
            ),
          );
        }
        break;

      case 'post':
        if (id != null) {
          _navigateToPost(ctx, id);
        }
        break;

      case 'devotion':
        if (id != null) {
          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (_) => DevotionScreen(planId: id, dayNum: 1),
            ),
          );
        }
        break;

      case 'video':
        if (id != null) {
          _navigateToVideo(ctx, id);
        }
        break;

      case 'audio':
        if (id != null) {
          _navigateToAudio(ctx, id);
        }
        break;

      case 'book':
        if (id != null) {
          _navigateToBook(ctx, id);
        }
        break;

      case 'profile':
      case 'user':
        // User profiles are identified by username or id
        // For now navigate to their profile card — no separate profile screen for others
        debugPrint("Deep link: profile/$id — no external profile screen yet");
        break;
    }
  }

  // ─── Post ────────────────────────────────────────────────────────────────

  static Future<void> _navigateToPost(BuildContext ctx, String postId) async {
    final auth = ctx.read<AuthProvider>();
    if (auth.token == null) return;

    try {
      final post = await ApiService.fetchPostById(auth.token!, postId);
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(builder: (_) => PostScreen(post: post)),
        );
      }
    } catch (e) {
      debugPrint("DeepLink: failed to fetch post $postId: $e");
    }
  }

  // ─── Video ───────────────────────────────────────────────────────────────

  static Future<void> _navigateToVideo(BuildContext ctx, String videoId) async {
    final auth = ctx.read<AuthProvider>();
    if (auth.token == null) return;

    try {
      final video = await ApiService.fetchVideoById(auth.token!, videoId);
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (_) => VideoReelScreen(videos: [video]),
          ),
        );
      }
    } catch (e) {
      debugPrint("DeepLink: failed to fetch video $videoId: $e");
    }
  }

  // ─── Audio ───────────────────────────────────────────────────────────────

  static Future<void> _navigateToAudio(BuildContext ctx, String audioId) async {
    final auth = ctx.read<AuthProvider>();
    if (auth.token == null) return;

    try {
      final audio = await ApiService.fetchAudioById(auth.token!, audioId);
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (_) => AudioReelScreen(audios: [audio]),
          ),
        );
      }
    } catch (e) {
      debugPrint("DeepLink: failed to fetch audio $audioId: $e");
    }
  }

  // ─── Book ────────────────────────────────────────────────────────────────

  static Future<void> _navigateToBook(BuildContext ctx, String bookId) async {
    final auth = ctx.read<AuthProvider>();
    if (auth.token == null) return;

    try {
      final book = await ApiService.fetchBookById(auth.token!, bookId);
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (_) => BookScreen(book: book),
          ),
        );
      }
    } catch (e) {
      debugPrint("DeepLink: failed to fetch book $bookId: $e");
    }
  }
}
