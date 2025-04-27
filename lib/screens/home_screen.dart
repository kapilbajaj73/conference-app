import 'package:flutter/material.dart';
import 'package:conference_app/services/dynamic_link_service.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatelessWidget {
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();

  Future<void> _shareClassroom(BuildContext context, String classroomId) async {
    String link = await _dynamicLinkService.createClassroomLink(classroomId);
    await Share.share('Join my classroom: $link');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/classroom', arguments: 'classroom1'),
              child: Text('Join Classroom 1'),
            ),
            ElevatedButton(
              onPressed: () => _shareClassroom(context, 'classroom1'),
              child: Text('Share Classroom 1'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              child: Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}