import 'package:cloud_firestore/cloud_firestore.dart';

class UserFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String userId;

  UserFirestore({required this.userId});

  Future<Map<String, dynamic>> getDocumentData() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(userId).get();
    return snapshot.data() ?? {};
  }

  // Function to save user data to Firestore
  Future<void> saveUserDataToFirestore(
      String userId, Map<String, dynamic> userData) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    final DocumentReference userDocRef = usersCollection.doc(userId);

    // Save user data to the main document
    await userDocRef.set(userData);
  }

  Future<void> createNewAnonymousAccount() async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      DocumentReference userDocRef = users.doc(userId);

      // Initialize the questions array with all values set to 0
      List<int> initialQuestions = List.filled(7, 0);

      await userDocRef.set({
        'isAccountAnon': true,
        'isNewAccount': true,
        'isParent': true,
        'hasDyslexia': true,
        'dyslexiaScore': 0,
        'name': '',
        'accountCreatedAt': Timestamp.now(),
        'questions': initialQuestions,
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> initializeLessons(String lessonCategory, String locale) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Reference to the source collection "letters > en > lessons"
      CollectionReference sourceCollection = firestore
          .collection(lessonCategory)
          .doc(locale)
          .collection('lessons');

      // Reference to the destination collection "users > <userId> > letters > en > lessons"
      CollectionReference destinationCollection = firestore
          .collection('users')
          .doc(userId)
          .collection(lessonCategory)
          .doc(locale)
          .collection('lessons');

      // Query the source collection
      QuerySnapshot sourceQuery = await sourceCollection.get();

      // Loop through the documents in the source collection
      for (QueryDocumentSnapshot sourceDoc in sourceQuery.docs) {
        // Get the data from the source document
        Map<String, dynamic> data = sourceDoc.data() as Map<String, dynamic>;

        // Extract only the necessary keys
        // Also initialize some keys
        Map<String, dynamic> newData = {
          'id': data['id'],
          'isUnlocked': data['isUnlocked'],
          'name': data['name'],
          'progress': data['progress'],
          'score': data['score'],
          'total': data['total'],
          'lessonTaken': 0,
          'accumulatedScore': 0
        };

        // Get the document ID from the source document
        String documentId = sourceDoc.id;

        // Add the data to the destination collection with the same document ID
        await destinationCollection.doc(documentId).set(newData);
      }

      print('Documents copied successfully');
    } catch (e) {
      print('Error copying documents: $e');
    }
  }

  // Future<void> initializeLessons(String lessonCategory, String locale) async {
  //   // Copy all default letter lesson data from lessons collection to users
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   // Reference to the source collection "letters > en > lessons"
  //   CollectionReference sourceCollection =
  //       firestore.collection(lessonCategory).doc(locale).collection('lessons');

  //   // Reference to the destination collection "users > <userId> > letters > en > lessons"
  //   CollectionReference destinationCollection = firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection(lessonCategory)
  //       .doc(locale)
  //       .collection('lessons');

  //   // Query the source collection
  //   QuerySnapshot sourceQuery = await sourceCollection.get();

  //   // Loop through the documents in the source collection
  //   for (QueryDocumentSnapshot sourceDoc in sourceQuery.docs) {
  //     // Get the data from the source document
  //     Map<String, dynamic> data = sourceDoc.data() as Map<String, dynamic>;

  //     // Get the document ID from the source document
  //     String documentId = sourceDoc.id;

  //     // Add the data to the destination collection with the same document ID
  //     await destinationCollection.doc(documentId).set(data);
  //   }

  //   print('Documents copied successfully');
  // }

  Future<void> updateQuestionScore(int index, int score) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userData = await userDoc.get();

      if (!userData.exists) {
        // If the user document doesn't exist, create it
        await userDoc.set({'questions': List<int>.filled(7, 0)});
      }

      // Update the score at the specified index in the 'questions' array
      List<int> questions = List<int>.from(userData['questions']);
      questions[index] = score;

      await userDoc.update({'questions': questions});
    } catch (e) {
      print('Error updating Firestore question score: $e');
    }
  }

  Future<bool> getIsParent() async {
    var data = await getDocumentData();

    return data['isParent'] ?? false;
  }

  Future<bool> getIsNewAccount() async {
    var data = await getDocumentData();

    return data['isNewAccount'] ?? false;
  }

  Future<bool> getIsAccountAnon() async {
    var data = await getDocumentData();

    return data['isAccountAnon'] ?? false;
  }

  Future<String> getAge() async {
    var data = await getDocumentData();

    return data['age'] ?? '3';
  }

  Future<bool> getHasDyslexia() async {
    var data = await getDocumentData();

    return data['hasDyslexia'] ?? false;
  }

  Future<String> getUsername() async {
    var data = await getDocumentData();

    return data['username'] ?? '';
  }

  Future<String> getEmail() async {
    var data = await getDocumentData();

    return data['email'] ?? '';
  }

  // Add more functions here for fetching other field values
}
