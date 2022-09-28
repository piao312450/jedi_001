import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

enum SocialStatus { notFriend, wantYou, wantMe, isFriend }

class JediUser {
  String userID;
  String userEmail;
  String name;
  SocialStatus socialStatus;
  Uint8List? profilePicInUInt8List;

  JediUser(
      {required this.userID,
      required this.userEmail,
      required this.name,
      required this.socialStatus,
      required this.profilePicInUInt8List});

  static Future<JediUser> fromUserID({required String userID, int? socialStatus}) async {
    var v = await FirebaseFirestore.instance.collection('users').doc(userID).get();

    if(!v.exists) throw const FormatException('throw');
    assert(v.data() != null);

    Uint8List? u;
    if (v.data()!['profilePicUrl'] != null) {
      http.Response response = await http.get(Uri.parse(v.data()!['profilePicUrl']));
      u = response.bodyBytes; //프로필 사진 있으면 불러오기
    }

    return JediUser(
        userID: userID,
        userEmail: v.data()!['userEmail'],
        name: v.data()!['name'],
        socialStatus: SocialStatus.values[socialStatus ?? 0],
        profilePicInUInt8List: u);
  }
}
