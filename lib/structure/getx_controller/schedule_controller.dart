import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedi_001/structure/getx_controller/my_jedi_user_controller.dart';
import 'package:jedi_001/structure/schedule.dart';
import 'package:jedi_001/widget/datetime_extension.dart';

import '../../main.dart';

class ScheduleController extends GetxController {
  Map<String, List<Schedule>> everyScheduleMap = {}; // {'20220905': [s1, s2, s3...] 식으로 보관
  final _jediUserCtrl = Get.put(MyJediUserController());

  Future<void> setSchedule(List<Schedule> m) async {
    for(final e in m) {
      everyScheduleMap[e.start.dateInString] = m;
    }
    update();
  }


  void saveSchedule(Schedule s) {
    // everyScheduleMap 에 저장
    if (everyScheduleMap[s.start.dateInString] == null) {
      everyScheduleMap[s.start.dateInString] = [];
    }
    everyScheduleMap[s.start.dateInString]!.add(s);

    // firestore 에 저장
    final CollectionReference schedules = FirebaseFirestore.instance.collection('schedules');
    assert(_jediUserCtrl.myJediUser != null);

    schedules.doc(_jediUserCtrl.myJediUser!.userID).update({
      'schedules': FieldValue.arrayUnion([
        {'title': s.title, 'allDay': s.allDay, 'start': s.start}
      ])
    });

    update();
  }
}
