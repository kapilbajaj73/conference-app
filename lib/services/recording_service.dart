import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class RecordingService {
  Future<String> uploadRecording(String filePath, String classroomId) async {
    File file = File(filePath);
    String fileName = 'recordings/$classroomId/${DateTime.now().toIso8601String()}.mp4';
    UploadTask task = FirebaseStorage.instance.ref(fileName).putFile(file);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }
}