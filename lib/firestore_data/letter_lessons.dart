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
        return null;
      }
    } catch (e) {
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
      print('Error updating lesson data: $e');
    }
  }

  // Function to increment lesson score data
  Future<void> addScoreToLessonBy(String lessonName, int value) async {
    try {
      if (lessonName.isEmpty) {
        print('Invalid lessonName: $lessonName');
        return;
      }

      if (userId.isEmpty) {
        print('Invalid userId: $userId');
        return;
      }

      final DocumentReference lessonRef = firestore
          .collection('users')
          .doc(userId)
          .collection('letters')
          .doc('en')
          .collection('lessons')
          .doc(lessonName);

      await firestore
          .runTransaction((transaction) async {
            DocumentSnapshot lessonSnapshot = await transaction.get(lessonRef);

            if (lessonSnapshot.exists) {
              int currentScore = lessonSnapshot.get('score') ?? 0;
              int newScore = currentScore + value;

              transaction.update(lessonRef, {'score': newScore});
            }
          })
          .then((_) => print("Score updated successfully"))
          .onError((error, stackTrace) =>
              print("Error updating score: $error, $stackTrace"));
    } catch (e) {
      print('Error updating lesson data: $e');
    }
  }

  // Function that resets lesson score data to 0
  Future<void> resetScore(String lessonName) async {
    try {
      if (lessonName.isEmpty) {
        print('Invalid lessonName: $lessonName');
        return;
      }

      if (userId.isEmpty) {
        print('Invalid userId: $userId');
        return;
      }

      final DocumentReference lessonRef = firestore
          .collection('users')
          .doc(userId)
          .collection('letters')
          .doc('en')
          .collection('lessons')
          .doc(lessonName);

      await lessonRef
          .set({'score': 0}, SetOptions(merge: true))
          .then((value) => print("Score has been reset successfully."))
          .onError((error, stackTrace) =>
              print("Score failed to reset: $error, $stackTrace"));
    } catch (e) {
      print('Error setting score to zero: $e');
    }
  }

  // Function to increment lesson progress value
  Future<void> incrementProgressValue(String lessonName, int value) async {
    try {
      if (lessonName.isEmpty) {
        print('Invalid lessonName: $lessonName');
        return;
      }

      if (userId.isEmpty) {
        print('Invalid userId: $userId');
        return;
      }

      final DocumentReference lessonRef = firestore
          .collection('users')
          .doc(userId)
          .collection('letters')
          .doc('en')
          .collection('lessons')
          .doc(lessonName);

      await firestore
          .runTransaction((transaction) async {
            DocumentSnapshot lessonSnapshot = await transaction.get(lessonRef);

            if (lessonSnapshot.exists) {
              int currentProgress = lessonSnapshot.get('progress') ?? 0;
              int newProgress = currentProgress + value;

              transaction.update(lessonRef, {'progress': newProgress});
            }
          })
          .then((_) => print("Progress updated successfully"))
          .onError((error, stackTrace) =>
              print("Error updating progress: $error, $stackTrace"));
    } catch (e) {
      print('Error updating lesson data: $e');
    }
  }

  Future<void> unlockLesson(String lessonName) async {
    try {
      final CollectionReference lessonsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('letters')
          .doc('en')
          .collection('lessons');

      // Fetch the current lesson document
      DocumentSnapshot currentLessonSnapshot =
          await lessonsCollection.doc(lessonName).get();

      if (currentLessonSnapshot.exists) {
        bool isUnlocked = currentLessonSnapshot.get('isUnlocked') ?? false;

        if (!isUnlocked) {
          // If the current lesson is not unlocked, unlock it
          await lessonsCollection.doc(lessonName).update({'isUnlocked': true});

          // Find the next lesson
          QuerySnapshot querySnapshot = await lessonsCollection
              .where('name',
                  isGreaterThan:
                      lessonName) // Find lessons with names greater than the current lesson
              .orderBy('name')
              .limit(1)
              .get();

          print(querySnapshot);

          if (querySnapshot.docs.isNotEmpty) {
            // Unlock the next lesson
            DocumentReference nextLessonRef =
                querySnapshot.docs.first.reference;
            await nextLessonRef.update({'isUnlocked': true});
          }
        } else {
          // The current lesson is already unlocked
          print('Lesson "$lessonName" is already unlocked.');
        }
      } else {
        print('Lesson "$lessonName" not found in Firestore.');
      }

      print('Lesson "$lessonName" and the next lesson unlocked successfully!');
    } catch (e) {
      print('Error updating lesson data: $e');
    }
  }
}
