import 'package:jedi_001/structure/band.dart';
import 'package:jedi_001/structure/jedi_user.dart';

import '../main.dart';

class MyJediUser {
  String? userID;
  String? name;
  String? phoneNumber;
  List<JediUser> friend = []; //userID = email 로 저장, 접근
  List<Band> band = [];
  List<String> contact = [];
  bool isContactSync;

  MyJediUser({
    required this.userID,
    required this.name,
    required this.phoneNumber,
    required this.friend,
    required this.band,
    required this.contact,
    required this.isContactSync,
  });

  static Future<MyJediUser> fromMap(Map userMap) async {
    List<JediUser> l = [];
    await userMap['friend'].map((d) async {
      l.add(await JediUser.fromUserID(d));
    });

    return MyJediUser(
        userID: userMap['userID'],
        name: userMap['name'],
        phoneNumber: userMap['phoneNumber'],
        friend: l,
        band: userMap['band'],
        contact: userMap['contact'].map<String>((d) => d.toString()).toList() ?? [],
        isContactSync: userMap['isContactSync']);
  }
}
