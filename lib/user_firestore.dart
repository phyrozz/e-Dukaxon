import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFirestore {
  final String userId;

  UserFirestore(this.userId);

  Future<bool> getIsParent() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      return data['isParent'] ?? false;
    } else {
      return false;
    }
  }

  // Add more functions here for fetching other field values
}
