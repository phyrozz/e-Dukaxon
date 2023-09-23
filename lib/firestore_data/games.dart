import 'package:cloud_firestore/cloud_firestore.dart';

class GameFirestore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId;

  GameFirestore({
    required this.userId,
  });

  Future<void> addScoreToGame(String game, bool isCorrect) async {
    try {
      if (userId.isEmpty) {
        print('Invalid userId: $userId');
        return;
      }

      final DocumentReference gameRef = firestore
          .collection('users')
          .doc(userId)
          .collection('games')
          .doc(game);

      // Check if the document already exists
      final gameDoc = await gameRef.get();

      if (gameDoc.exists) {
        // Document exists, update the appropriate field
        final int currentCorrects = gameDoc.get('noOfCorrects') ?? 0;
        final int currentWrongs = gameDoc.get('noOfWrongs') ?? 0;

        if (isCorrect) {
          await gameRef.update({'noOfCorrects': currentCorrects + 1});
        } else {
          await gameRef.update({'noOfWrongs': currentWrongs + 1});
        }
      } else {
        // Document doesn't exist, create it
        if (isCorrect) {
          await gameRef.set({'noOfCorrects': 1, 'noOfWrongs': 0});
        } else {
          await gameRef.set({'noOfCorrects': 0, 'noOfWrongs': 1});
        }
      }
    } catch (e) {
      print('Error updating game data: $e');
    }
  }

  Future<int> getGameScore(String userId, String game, String key) async {
    try {
      final DocumentReference gameRef = firestore
          .collection('users')
          .doc(userId)
          .collection('games')
          .doc(game);

      final gameDoc = await gameRef.get();

      if (gameDoc.exists) {
        // Check if the document exists
        if (gameDoc.get(key)) {
          return gameDoc.get(key);
        } else {
          return 0;
        }
      } else {
        // Document doesn't exist
        return 0;
      }
    } catch (e) {
      print('Error retrieving game data: $e');
      return 0;
    }
  }
}
