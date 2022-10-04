import 'dart:typed_data';
import 'package:jedi_001/structure/band.dart';
import 'package:jedi_001/structure/jedi_user.dart';

import '../main.dart';

class MyJediUser {
  String userID;
  String name;
  String phoneNumber;
  Uint8List? profilePicInUInt8List;
  List<JediUser> friend = []; //userID = email 로 저장, 접근
  List<JediUser> potentialFriend =[];
  List<Band> band = [];
  List<String> contact = [];
  bool isContactSync;

  MyJediUser({
    required this.userID,
    required this.name,
    required this.phoneNumber,
    required this.profilePicInUInt8List,
    required this.friend,
    required this.potentialFriend,
    required this.band,
    required this.contact,
    required this.isContactSync,
  });

  factory MyJediUser.fromMap(Map<String, dynamic> myJediUserInMap) {
    return MyJediUser(
        userID: myJediUserInMap['userID'],
        name: myJediUserInMap['name'],
        phoneNumber: myJediUserInMap['phoneNumber'],
        profilePicInUInt8List: myJediUserInMap['profilePicInUInt8List'],
        friend: myJediUserInMap['friend'],
        potentialFriend: myJediUserInMap['potentialFriend'],
        band: myJediUserInMap['band'],
        contact: myJediUserInMap['contact'].map<String>((d) => d.toString()).toList() ?? [],
        isContactSync: myJediUserInMap['isContactSync']);
  }
}
