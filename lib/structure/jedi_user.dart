import 'package:cloud_firestore/cloud_firestore.dart';

class JediUser {
  String userID;
  String name;

  JediUser({required this.userID, required this.name});

  static Future<JediUser> fromUserID(String userID) async {
    var v = await FirebaseFirestore.instance.collection('users').doc(userID).get();
    assert(v.data() != null);
    String name = v.data()!['name'];
    return JediUser(
      userID: userID,
      name: name
    );
  }
}
