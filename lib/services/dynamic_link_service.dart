import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class DynamicLinkService {
  StreamSubscription? _sub;

  Future<String> createClassroomLink(String classroomId) async {
    // Generate a simple deep link URL
    return 'conferenceapp://classroom?classroomId=$classroomId';
  }

  Future<void> handleDynamicLinks(BuildContext context) async {
    // Handle initial deep link when app is opened from a terminated state
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleLink(initialUri, context);
      }
    } catch (e) {
      print('Error handling initial link: $e');
    }

    // Handle deep links when app is in foreground
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleLink(uri, context);
      }
    }, onError: (err) {
      print('Error handling deep link: $err');
    });
  }

  void _handleLink(Uri link, BuildContext context) {
    if (link.scheme == 'conferenceapp' && link.path == '/classroom') {
      final classroomId = link.queryParameters['classroomId'];
      if (classroomId != null) {
        Navigator.pushNamed(context, '/classroom', arguments: classroomId);
      }
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}