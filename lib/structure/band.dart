import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jedi_001/structure/jedi_user.dart';

import '../main.dart';

class Band {
  String bandID;
  String name;
  Color color;
  List<String> member = [];

  Band({required this.bandID, required this.name, required this.color, required this.member});

  factory Band.fromBandID(String userID, String bandID) {
    Map<String, dynamic> m;
    FirebaseFirestore.instance.collection('users').doc(userID).collection('band').doc(bandID).get().then((v) {
      logger.i(v.data());
      assert(v.data() != null);
      m = v.data()!;
      return Band(
        bandID: bandID,
        name: v.data()!['name'],
        color: Color(v.data()!['color'] ?? Colors.lightBlueAccent.value),
        member: v.data()!['member'].map<String>((d) => d.toString()).toList()
      );
      return Band(bandID: '', name: 'e', color: Colors.black, member: []);
    });
    throw Exception('bandID로 밴드를 찾을 수 없습니다');
  }
}
