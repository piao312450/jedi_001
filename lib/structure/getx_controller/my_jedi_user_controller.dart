import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../band.dart';
import '../my_jedi_user.dart';
import '../schedule.dart';

enum Update {
  name,
  friendAdd,
  potentialFriendUpdate,
  potentialFriendRemove,
  createBand,
  deleteBand,
  profilePic,
  addMemberTo,
  removeMemberFrom,
  add
}

class MyJediUserController extends GetxController {
  late MyJediUser _myJediUser;

  MyJediUser get myJediUser {
    try {
      return _myJediUser;
    } catch (e) {
      logger.d('late');
      throw e;
    }
  }

  set myJediUser(MyJediUser myJediUser) {
    _myJediUser = myJediUser;
    update();
  }

  Future<void> updateMyJediUser(Update u, dynamic d) async {
    String userID = _myJediUser.userID;

    switch (u) {
      case Update.name:
      case Update.friendAdd: //새로운 친구 JediUser d
        _myJediUser.friend.add(d);
        update();

        FirebaseFirestore.instance.collection('users').doc(userID).update({
          'friend': FieldValue.arrayUnion([d.userID])
        });
        break;

      case Update.potentialFriendUpdate: //d는 [JediUser j, SocialStatus s] 꼴
        // int i = _myJediUser.potentialFriend.indexOf(d[0]);
        // _myJediUser.potentialFriend[i].socialStatus = d[1];
        //
        // update();

        FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({'potentialFriend.${d[0].userID}': d[1].index});

        break;

      case Update.potentialFriendRemove:
        // _myJediUser.potentialFriend.remove(d);
        // update();

        FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({'potentialFriend.${d.userID}': FieldValue.delete()});
        break;

      case Update.createBand: // List<dynamic>[String name, Color c
        DocumentReference band = FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('band')
            .doc();
        await band.set({
          'bandID': band.id,
          'name': d[0],
          'color': d[1].value,
          'member': []
        });

        _myJediUser.band
            .add(Band(bandID: band.id, name: d[0], color: d[1], member: []));
        update();
        break;

      case Update.deleteBand: //Band 타입 d
        assert(d != null);
        _myJediUser.band.remove(d);
        FirebaseFirestore.instance
            .collection('users')
            .doc(myJediUser.userID)
            .collection('band')
            .doc(d.bandID)
            .delete();
        update();
        break;

      case Update.profilePic:
        _myJediUser.profilePicInUInt8List = d;
        update();

        final ref =
            FirebaseStorage.instance.ref().child('profile_picture/$userID');
        await ref.putData(d);
        String s = await ref.getDownloadURL();
        FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({'profilePicUrl': s});
        logger.d(s);
        break;
      default:
        break;
    }
  }

  Future<void> updateBand(Update u, Band b, String? member) async {
    // ignore: missing_enum_constant_in_switch
    switch (u) {
      case Update.addMemberTo:
        assert(member != null);
        _myJediUser.band.singleWhere((e) => e == b).member.add(member!);
        FirebaseFirestore.instance
            .collection('users')
            .doc(_myJediUser.userID)
            .collection('band')
            .doc(b.bandID)
            .update({
          'member': FieldValue.arrayUnion([member])
        });
        update();
        break;
      case Update.removeMemberFrom:
        assert(member != null);
        _myJediUser.band.singleWhere((e) => e == b).member.remove(member!);
        FirebaseFirestore.instance
            .collection('users')
            .doc(_myJediUser.userID)
            .collection('band')
            .doc(b.bandID)
            .update({
          'member': FieldValue.arrayRemove([member])
        });
        update();
        break;
    }
  }
}
