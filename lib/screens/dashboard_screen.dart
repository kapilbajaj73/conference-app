import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conference_app/services/auth_service.dart';
import 'package:conference_app/services/agora_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final AgoraService _agoraService = AgoraService();
  bool isBroadcasting = false;

  Future<void> _toggleBroadcast() async {
    if (!isBroadcasting) {
      await _agoraService.initAgora('admin_channel', (uid, elapsed) {});
      setState(() => isBroadcasting = true);

      List<String> classrooms = ['classroom1', 'classroom2'];
      for (String classroom in classrooms) {
        print('Relaying to $classroom');
      }
    } else {
      await _agoraService.leaveChannel();
      setState(() => isBroadcasting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _toggleBroadcast,
              child: Text(isBroadcasting ? 'Stop Broadcasting' : 'Broadcast Voice to All'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('classrooms').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final classrooms = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: classrooms.length,
                  itemBuilder: (context, index) {
                    var classroom = classrooms[index].data() as Map<String, dynamic>;
                    String classroomId = classroom['id'] ?? 'Unknown';
                    List<String> users = List<String>.from(classroom['users'] ?? []);
                    return ListTile(
                      title: Text(classroomId),
                      subtitle: Text('Users: ${users.length}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}