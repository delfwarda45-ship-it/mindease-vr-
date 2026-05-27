import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final String title;
  final String type;
  final String category;
  final int duration;
  final DateTime date;
  final String userId;
  final String videoAssetPath;

  Session({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.duration,
    required this.date,
    required this.userId,
    required this.videoAssetPath,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'category': category,
      'duration': duration,
      'date': Timestamp.fromDate(date),
      'userId': userId,
      'videoAssetPath': videoAssetPath,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Session.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Session(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      type: data['type'] ?? 'unknown',
      category: data['category'] ?? 'general',
      duration: data['duration'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      videoAssetPath: data['videoAssetPath'] ?? '',
    );
  }
}

Future<void> saveSession({
  required String title,
  required String type,
  required String category,
  required int duration,
  required String userId,
  required String videoAssetPath,
}) async {
  try {
    final sessionId =
        'session_${DateTime.now().millisecondsSinceEpoch}_$userId';
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('sessions').doc(sessionId).set({
      'id': sessionId,
      'title': title,
      'type': type,
      'category': category,
      'duration': duration,
      'date': Timestamp.now(),
      'userId': userId,
      'videoAssetPath': videoAssetPath,
      'createdAt': FieldValue.serverTimestamp(),
    });

    print(' Session saved successfully');
  } catch (e) {
    print(' Error saving session: $e');
  }
}
