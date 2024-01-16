import 'package:cloud_firestore/cloud_firestore.dart';

class WordLessonFirestore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId;

  WordLessonFirestore({
    required this.userId,
  });

  // Retrieve all of the data within the lesson
  Future<Map<String, dynamic>?> getLessonData(
      String lessonName, String locale) async {
    try {
      final DocumentSnapshot doc = await firestore
          .collection('words')
          .doc(locale)
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

  // Retrieve all of the data within the lesson
  Future<Map<String, dynamic>?> getUserLessonData(
      String lessonName, String locale) async {
    try {
      final DocumentSnapshot doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('words')
          .doc(locale)
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
      String lessonName, String locale, Map<String, dynamic> newData) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('words')
          .doc(locale)
          .collection('lessons')
          .doc(lessonName)
          .update(newData);
    } catch (e) {
      print('Error updating lesson data: $e');
    }
  }

  // Function to increment lesson score data
  Future<void> addScoreToLessonBy(
      String lessonName, String locale, int value) async {
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
          .collection('words')
          .doc(locale)
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
  Future<void> resetScore(String lessonName, String locale) async {
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
          .collection('words')
          .doc(locale)
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
  Future<void> incrementProgressValue(
      String lessonName, String locale, int value) async {
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
          .collection('words')
          .doc(locale)
          .collection('lessons')
          .doc(lessonName);

      await firestore
          .runTransaction((transaction) async {
            DocumentSnapshot lessonSnapshot = await transaction.get(lessonRef);

            if (lessonSnapshot.exists) {
              int currentProgress = lessonSnapshot.get('progress') ?? 0;
              int newProgress = currentProgress + value;

              // Ensure that the progress does not exceed 100
              if (newProgress <= 100) {
                transaction.update(lessonRef, {'progress': newProgress});
              } else {
                // If the new progress exceeds 100, set it to 100
                transaction.update(lessonRef, {'progress': 100});
              }
            }
          })
          .then((_) => print("Progress updated successfully"))
          .onError((error, stackTrace) =>
              print("Error updating progress: $error, $stackTrace"));
    } catch (e) {
      print('Error updating lesson data: $e');
    }
  }

  Future<void> unlockLesson(String lessonName, String locale) async {
    try {
      final CollectionReference lessonsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('words')
          .doc(locale)
          .collection('lessons');

      // Find the next lesson
      QuerySnapshot querySnapshot = await lessonsCollection
          .where('id', isGreaterThan: lessonIdForName(lessonName, locale))
          .orderBy('id')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Unlock the next lesson
        DocumentReference nextLessonRef = querySnapshot.docs.first.reference;
        await nextLessonRef.update({'isUnlocked': true});
        print(
            'Lesson "$lessonName" and the next lesson unlocked successfully!');
      } else {
        print('Next lesson not found for "$lessonName".');
      }
    } catch (e) {
      print('Error updating lesson data: $e');
    }
  }

  // Call this function when initializing the unlocking of lessons based on the user's dyslexia score
  Future<void> initUnlockLessons() async {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      // Get the current user document from Firestore
      DocumentSnapshot userDocSnapshot = await userDocRef.get();
      int dyslexiaScore = userDocSnapshot['dyslexiaScore'] ?? 0;

      // Unlock lessons based on dyslexiaScore
      List<int> unlockedLessons = [];

      if (dyslexiaScore >= 14 && dyslexiaScore <= 12) {
        unlockedLessons = [0];
      } else if (dyslexiaScore < 12 && dyslexiaScore >= 9) {
        unlockedLessons = [0, 1];
      } else if (dyslexiaScore < 9) {
        unlockedLessons = [0, 1];
      }

      // Unlock lessons in both en and ph locales
      for (String locale in ['en', 'ph']) {
        for (int lessonId in unlockedLessons) {
          CollectionReference lessonsCollectionRef = FirebaseFirestore.instance
              .collection('users/$userId/words/$locale/lessons');

          QuerySnapshot lessonSnapshot =
              await lessonsCollectionRef.where('id', isEqualTo: lessonId).get();

          for (QueryDocumentSnapshot lessonDocSnapshot in lessonSnapshot.docs) {
            // Update the "isUnlocked" field for the lesson
            await lessonDocSnapshot.reference.set(
              {'isUnlocked': true},
              SetOptions(merge: true),
            );
          }
        }
      }

      print('Letter lessons unlocked successfully!');
    } catch (e) {
      print('Error unlocking letter lessons: $e');
    }
  }

  int lessonIdForName(String lessonName, String locale) {
    final Map<String, int> lessonNameToId = {
      locale == 'en' ? 'Animals' : 'Mga Hayop': 0,
      locale == 'en' ? 'Colors' : 'Mga Kulay': 1,
      // Add more entries as needed
    };

    return lessonNameToId[lessonName] ?? -1;
  }
}
