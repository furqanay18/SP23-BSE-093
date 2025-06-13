import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getInventoryUsernameForCurrentUser() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final query = await FirebaseFirestore.instance
      .collection('inventories')
      .where('members', arrayContains: uid)
      .limit(1)
      .get();

  if (query.docs.isNotEmpty) {
    return query.docs.first['inventoryUsername'] as String?;
  }

  return null;
}
