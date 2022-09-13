import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedi_001/screens/home_page.dart';
import 'package:jedi_001/screens/login_page.dart';
import 'package:jedi_001/structure/band.dart';
import 'package:jedi_001/structure/getx_controller/my_jedi_user_controller.dart';
import 'package:jedi_001/structure/getx_controller/schedule_controller.dart';
import 'package:jedi_001/structure/schedule.dart';
import 'package:logger/logger.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const Jedi());
}

var logger = Logger();

class Jedi extends StatelessWidget {
  const Jedi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: CheckAccount(),
      debugShowCheckedModeBanner: false,
    );
  }
}

final _myJediUserCtrl = Get.put(MyJediUserController());
final _scheduleCtrl = Get.put(ScheduleController());

class CheckAccount extends StatelessWidget {
  const CheckAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> stream) {
        if (stream.data == null) {
          return const LoginPage();
        } else if (stream.connectionState == ConnectionState.active) {
          // return const LoginPage();
          assert(stream.data!.email != null);
          fetchUserFromFirebase(stream.data!.email!);
          fetchScheduleFromFirebase(stream.data!.email!);
          loadContactIfFirstLogin(stream.data!.email!);
          loadFriendSuggestion(stream.data!.email!);
          return const HomePage();
        }
        return const Text('이러면 안되는데..');
      },
    ));
  }
}

//firestore 에서 유저의 아이디, 이름, 전화번호, 친구 목록, 밴드 목록을 불러와 컨트롤러에 저장한다.
void fetchUserFromFirebase(String userEmail) async {
  Map<String, dynamic> myJediUserInMap;
  final user = FirebaseFirestore.instance.collection('users').doc(userEmail);
  var v = await user.get();
  assert(v.data() != null);
  myJediUserInMap = v.data()!;
  myJediUserInMap['userID'] = userEmail; // 유저의 아이디, 이름, 전화번호 등 일반 정보 불러옴

  QuerySnapshot querySnapshot = await user.collection('band').get();
  final List l = querySnapshot.docs.map((e) => e.data()).toList();
  List<Band> bandList = List<Band>.generate(
      l.length, (i) => Band(name: l[i]['name'], member: l[i]['member'].map<String>((d) => d.toString()).toList()));
  myJediUserInMap['band'] = bandList; // 유저의 밴드 정보 불러와 인스턴스 목록 생성

  logger.i('fetchUserFromFirebase();\n'
      'Firestore 에서 유저 정보를 Map 형식으로 불러와 변수에 저장합니다 - 변수 myJediUserInMap : $myJediUserInMap');

  await _myJediUserCtrl.setMyJediUser(myJediUserInMap);
}

void fetchScheduleFromFirebase(String userEmail) {
  final schedule = FirebaseFirestore.instance.collection('schedules').doc(userEmail);
  schedule.get().then((v) async {
    if (v.data() != null) {
      final Map<String, dynamic> rawScheduleMap = v.data()!;
      List rawScheduleList = rawScheduleMap['schedules']; // Schedule 객체의 정보만 담은 Map
      List<Schedule> loadedSchedules = []; //우리가 원하는 형태!!

      for (int i = 0; i < rawScheduleList.length; i++) {
        loadedSchedules.add(Schedule.fromMap(rawScheduleList[i]));
      }
      logger.i('loadAndSave_Schedule_DataFromFirebase;\nloadedSchedules: $loadedSchedules');
      await _scheduleCtrl.setSchedule(loadedSchedules);
    }
  });
}

void loadContactIfFirstLogin(String userEmail) {
  final user = FirebaseFirestore.instance.collection('users').doc(userEmail);
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
        logger.d(l);
        user.update({'contact': l, 'isContactSync': true});
      }
    } else if (status.isDenied) {
      Permission.contacts.request();
    }
  });
}

void loadFriendSuggestion(String userEmail) {
  final user = FirebaseFirestore.instance.collection('users');
  List<String> contact = [];
  List<String> friendSuggestion = [];

  user.doc(userEmail).get().then((v) async {
    assert(v.data() != null);
    contact = v.data()!['contact'].map<String>((d) => d.toString()).toList();

    for (final e in contact) {
      final stream = user.where('phoneNumber', isEqualTo: e).snapshots();
      user.where('phoneNumber', isEqualTo: e).snapshots().listen((data) {
        try {
          friendSuggestion.add(data.docs[0].reference.path.split('/')[1].toString());
          _myJediUserCtrl.friendSuggestion = friendSuggestion;
        } catch (e) {}
      });
    }
  });
}
