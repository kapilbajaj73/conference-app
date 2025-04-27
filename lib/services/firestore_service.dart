import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conference_app/models/classroom.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> joinClassroom(String classroomId, String userId) async {
    DocumentReference roomRef = _firestore.collection('classrooms').doc(classroomId);
    DocumentSnapshot doc = await roomRef.get();
    if (doc.exists) {
      List<String> users = List<String>.from(doc['users'] ?? []);
      if (users.length >= 20) throw Exception('Classroom is full');
      await roomRef.update({
        'users': FieldValue.arrayUnion([userId]),
      });
    } else {
      await roomRef.set(Classroom(id: classroomId, name: classroomId).toMap());
      await roomRef.update({
        'users': [userId],
      });
    }
  }

  Future<void> leaveClassroom(String classroomId, String userId) async {
    await _firestore.collection('classrooms').doc(classroomId).update({
      'users': FieldValue.arrayRemove([userId]),
    });
  }

  Stream<Classroom> getClassroom(String classroomId) {
    return _firestore
        .collection('classrooms')
        .doc(classroomId)
        .snapshots()
        .map((doc) => Classroom.fromMap(doc.data()!));
  }
}