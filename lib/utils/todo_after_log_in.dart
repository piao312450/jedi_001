//firestore 에서 유저의 아이디, 이름, 전화번호, 친구 목록, 밴드 목록을 불러와 컨트롤러에 저장한다.
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jedi_001/widget/datetime_extension.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../structure/band.dart';
import '../structure/getx_controller/calendar_controller.dart';
import '../structure/getx_controller/my_jedi_user_controller.dart';
import '../structure/getx_controller/schedule_controller.dart';
import '../structure/jedi_user.dart';
import '../structure/my_jedi_user.dart';
import '../structure/schedule.dart';

final _myJediUserCtrl = Get.put(MyJediUserController());
final _calendarCtrl = Get.put(CalendarController());

Future<int> fetchUserFromFirebase(String userID) async {
  logger.d('fetchUserFromFirebase');
  // logger.d('_myJediUserCtrl.myJediUser : ${_myJediUserCtrl.myJediUser}');

  Map<String, dynamic> myJediUserInMap;
  final user = FirebaseFirestore.instance.collection('users').doc(userID);

  var v = await user.get();
  assert(v.data() != null);

  myJediUserInMap = jsonDecode(jsonEncode(v.data()!)); //시작! 유저 일반 정보

  QuerySnapshot querySnapshot = await user.collection('band').get();
  final List l = querySnapshot.docs.map((e) => e.data()).toList();
  List<Band> bandList = List<Band>.generate(
      l.length,
      (i) => Band(
          bandID: l[i]['bandID'],
          name: l[i]['name'],
          color: Color(l[i]['color'] ?? Colors.lightBlueAccent.value),
          member: l[i]['member'].map<String>((d) => d.toString()).toList()));
  myJediUserInMap['band'] = bandList; // 유저 밴드

  if (v.data()!['profilePicUrl'] != null) {
    http.Response response = await http.get(Uri.parse(v.data()!['profilePicUrl']));
    myJediUserInMap['profilePicInUInt8List'] = response.bodyBytes; //유저 프사(있으면)
  }

  List<JediUser> pfl = [];
  Map<String, dynamic> pfm = {};
  myJediUserInMap['potentialFriend'].forEach((k, v) {
    pfm[k] = v;
  });
  for (final k in pfm.keys.toList()) {
    try {
      pfl.add(await JediUser.fromUserID(userID: k, socialStatus: pfm[k]));
    } catch (e) {}
  }
  myJediUserInMap['potentialFriend'] = pfl; //유저 잠재친구

  logger.d('pfl load complete');

  List<JediUser> f = [];
  for (final e in myJediUserInMap['friend']) {
    try {
      f.add(await JediUser.fromUserID(userID: e, socialStatus: 3));
    } catch (e) {
      print(e);
    }
  }
  myJediUserInMap['friend'] = f; //유저 친구

  _myJediUserCtrl.myJediUser = MyJediUser.fromMap(myJediUserInMap);
  Get.find<MyJediUserController>().myJediUser = MyJediUser.fromMap(myJediUserInMap); //저장
  // // logger.d('fetchUserFromFirebase 완료');
  // // logger.d('myJediUserInMap : $myJediUserInMap');
  // // logger.d('_myJediUserCtrl.myJediUser : ${_myJediUserCtrl.myJediUser}');
  loadNewPotentialFriend(userID);

  return 0;
}

void fetchScheduleFromFirebase(String userID) {
  logger.d('fetchScheduleFromFirebase');
  FirebaseFirestore.instance.collection('schedules').doc(userID).collection('mySchedule').get().then((v) {
    Map<String, List<Schedule>> m = {};
    for (var e in v.docs) {
      String d = DateTime.parse(e.data()['start'].toDate().toString()).dateInString;
      m[d] ??= [];
      m[d]!.add(Schedule(
          userID: userID,
          scheduleID: e.data()['scheduleID'],
          title: e.data()['title'],
          allDay: e.data()['allDay'],
          start: DateTime.parse(e.data()['start'].toDate().toString()),
          end: DateTime.parse(e.data()['end'].toDate().toString()),
          shareWith: e.data()['shareWith']?.map((e) => Band.fromBandID(userID, e))));
    }
    _calendarCtrl.mySchedule = m;
  });

  FirebaseFirestore.instance.collection('schedules').doc(userID).collection('mySocialSchedule').get().then((v) {
    Map<String, List<Schedule>> m = {};
    for (var e in v.docs) {
      String d = DateTime.parse(e.data()['start'].toDate().toString()).dateInString;
      m[d] ??= [];
      m[d]!.add(Schedule(
          userID: userID,
          scheduleID: e.data()['scheduleID'],
          title: e.data()['title'],
          allDay: e.data()['allDay'],
          start: DateTime.parse(e.data()['start'].toDate().toString()),
          end: DateTime.parse(e.data()['end'].toDate().toString()),
          shareWith: e.data()['shareWith']?.map((e) => Band.fromBandID(userID, e))));
    }
    logger.e(m);
    _calendarCtrl.mySocialSchedule = m;
  });

  logger.d('fetchScheduleFromFirebase 완료');
}

void loadContactIfFirstLogin(String userID) {
  logger.d('loadContactIfFirstLogin');
  final user = FirebaseFirestore.instance.collection('users').doc(userID);
  user.get().then((v) async {
    assert(v.data() != null);
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      if (!v.data()!['isContactSync']) {
        var _contacts = await ContactsService.getContacts();
        List<String> l = [];
        for (var contact in _contacts) {
          assert(contact.phones != null);
          contact.phones!.toSet().forEach((phone) {
            assert(phone.value != null);
            l.add(phone.value!.replaceAll('-', ''));
          });
        }
        user.update({'contact': l, 'isContactSync': true});
      }
    } else if (status.isDenied) {
      Permission.contacts.request();
    }
  });
}

Future<void> loadNewPotentialFriend(String userID) async {
  logger.d('loadNewPotentialFriend');
  final users = FirebaseFirestore.instance.collection('users');
  List<String> contact = _myJediUserCtrl.myJediUser.contact;

  if (contact.isEmpty) return;
  for (int i = 0; i <= (contact.length - 1) ~/ 10; i++) {
    await users
        .where('phoneNumber', whereIn: contact.sublist(10 * i, min(10 * i + 9, contact.length - 1)))
        .get()
        .then((data) async {
      try {
        List<String> pfl = _myJediUserCtrl.myJediUser.potentialFriend.map<String>((e) => e.userID).toList();
        List<String> fl = _myJediUserCtrl.myJediUser.friend.map<String>((e) => e.userID).toList();
        List<JediUser> j = [];

        for (final e in data.docs) {
          //전화번호가 연락처에 포함되어 있는 모든 계정
          if (e.data()['userID'] == _myJediUserCtrl.myJediUser.userID) continue; //본인
          if (fl.contains(e.data()['userID']) && e.data()['socialStatus'] != 3) continue; //이미 친구 + isFriend 도 아님
          if (pfl.contains(e.data()['userID'])) continue; //이미 저장

          j.add(await JediUser.fromUserID(userID: e.data()['userID']));
          _myJediUserCtrl.myJediUser.potentialFriend = j;
        }

        Map<String, dynamic> m = {};
        for (final e in _myJediUserCtrl.myJediUser.potentialFriend) {
          m[e.userID] = e.socialStatus.index;
        }
        FirebaseFirestore.instance.collection('users').doc(userID).update({'potentialFriend': m});
      } catch (error) {
        logger.i(error);
      }
    });
  }
  logger.d('loadNewPotentialFriend done');
}
