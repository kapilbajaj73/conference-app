import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:conference_app/services/agora_service.dart';
import 'package:conference_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ClassroomScreen extends StatefulWidget {
  final String classroomId;
  ClassroomScreen({required this.classroomId});

  @override
  _ClassroomScreenState createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  final AgoraService _agoraService = AgoraService();
  final FirestoreService _firestoreService = FirestoreService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _joinClassroom();
  }

  Future<void> _joinClassroom() async {
    try {
      await _firestoreService.joinClassroom(widget.classroomId, userId);
      await _agoraService.initAgora(widget.classroomId, (uid, elapsed) {
        setState(() {
          _agoraService.uids.add(uid);
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      Navigator.pop(context);
    }
  }

  Future<void> _toggleRecording() async {
    setState(() {
      isRecording = !isRecording;
    });

    if (isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recording started')));
    } else {
      String filePath = '/path/to/recording.mp4'; // Placeholder path
      try {
        File file = File(filePath);
        String fileName = 'recordings/${widget.classroomId}/${DateTime.now().toIso8601String()}.mp4';
        UploadTask task = FirebaseStorage.instance.ref(fileName).putFile(file);
        TaskSnapshot snapshot = await task;
        String url = await snapshot.ref.getDownloadURL();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recording saved: $url')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save recording: $e')));
      }
    }
  }

  @override
  void dispose() {
    _agoraService.leaveChannel();
    _firestoreService.leaveClassroom(widget.classroomId, userId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Classroom: ${widget.classroomId}')),
      body: Stack(
        children: [
          if (_agoraService.isJoined)
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _agoraService.engine!,
                canvas: VideoCanvas(uid: 0),
              ),
            ),
          ..._agoraService.uids.map((uid) => Positioned(
                width: 120,
                height: 160,
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _agoraService.engine!,
                    canvas: VideoCanvas(uid: uid),
                    connection: RtcConnection(channelId: widget.classroomId),
                  ),
                ),
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _toggleRecording,
                  child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Leave Classroom'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}