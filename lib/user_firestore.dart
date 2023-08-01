import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/game_data.dart';

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
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    DocumentReference userDocRef = users.doc(userId);
    // CollectionReference progress =
    //     FirebaseFirestore.instance.collection('progress');

    // final List<String> gameIds = gameData.keys.toList();
    // final Map<String, List<String>> levelIdsMap = gameData
    //     .map((gameId, levels) => MapEntry(gameId, levels.keys.toList()));

    // for (final gameId in gameIds) {
    //   final List<String> levelIds = levelIdsMap[gameId] ?? [];

    //   Map<String, dynamic> initialProgress = {};

    //   for (final levelId in levelIds) {
    //     initialProgress[levelId] = {
    //       'progress': 0,
    //       'timestamp': null,
    //       'history': [],
    //       'duration': null,
    //     };
    //   }

    //   await progress.doc(gameId).set(initialProgress);
    // }

    await userDocRef.set({
      'isAccountAnon': true,
      'isNewAccount': true,
      'isParent': true,
      'hasDyslexia': true,
    });
  }

  Future<bool> getIsParent() async {
    var data = await getDocumentData();

    return data['isParent'];
  }

  Future<bool> getIsNewAccount() async {
    var data = await getDocumentData();

    return data['isNewAccount'];
  }

  Future<bool> getIsAccountAnon() async {
    var data = await getDocumentData();

    return data['isAccountAnon'];
  }

  Future<String> getAge() async {
    var data = await getDocumentData();

    return data['age'];
  }

  Future<bool> getHasDyslexia() async {
    var data = await getDocumentData();

    return data['hasDyslexia'];
  }

  Future<String> getUsername() async {
    var data = await getDocumentData();

    return data['username'];
  }

  Future<String> getEmail() async {
    var data = await getDocumentData();

    return data['email'];
  }

  // Add more functions here for fetching other field values
}
