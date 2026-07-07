import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:quest/main.dart'; // To access navigatorKey
import 'package:quest/screens/community/community_individual_screen.dart';

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

  static void _handleDeepLink(Uri uri) {
    debugPrint("App Links: Received deep link: $uri");

    if (uri.host == 'quest.vidarave.com') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return;

      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;

      final resource = pathSegments[0];

      switch (resource) {
        case 'community':
          if (pathSegments.length > 1) {
            final communityId = pathSegments[1];
            Navigator.of(ctx).push(
              MaterialPageRoute(
                builder:
                    (_) => CommunityIndividualScreen(communityId: communityId),
              ),
            );
          }
          break;
        case 'post':
          // TODO: handle post deep linking if needed
          break;
        case 'devotion':
          // TODO: handle devotion deep linking
          break;
        case 'game':
          // TODO: handle game deep linking
          break;
      }
    }
  }
}
