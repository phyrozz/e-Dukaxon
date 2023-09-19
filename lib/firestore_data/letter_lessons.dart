import 'package:cloud_firestore/cloud_firestore.dart';

class LetterLessonFirestore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId;

  LetterLessonFirestore({
    required this.userId,
  });

  // Retrieve all of the data within the lesson
  Future<Map<String, dynamic>?> getLessonData(String lessonName) async {
    try {
      final DocumentSnapshot doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('letters')
          .doc('en')
          .collection('lessons')
          .doc(lessonName)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        // Handle the case where the document doesn't exist
        return null;
      }
    } catch (e) {
      // Handle any errors that may occur during the Firestore operation
      print('Error retrieving lesson data: $e');
      return null;
    }
  }

  // Function to update lesson data
  Future<void> updateLessonData(
      String lessonName, Map<String, dynamic> newData) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('letters')
          .doc('en')
          .collection('lessons')
          .doc(lessonName)
          .update(newData);
    } catch (e) {
      // Handle any errors that may occur during the update
      print('Error updating lesson data: $e');
    }
  }
}
