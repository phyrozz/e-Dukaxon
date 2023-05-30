import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<String?>? getUsername() {
  final user = _auth.currentUser;
  if (user != null) {
    final userId = user.uid;
    final userRef = _firestore.collection('users').doc(userId);
    return userRef.get().then((doc) => doc['username'] as String?);
  }
  return null;
}
