import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedi_001/structure/getx_controller/my_jedi_user_controller.dart';
import 'package:jedi_001/widget/datetime_extension.dart';

import '../band.dart';
import '../schedule.dart';

class CalendarController extends GetxController {
  final _myJediUserCtrl = Get.put(MyJediUserController());

  late DateTime _displayedDate;


  @override
  void onInit() {
    super.onInit();
    _displayedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  }

  DateTime get displayedDate => _displayedDate;

  set displayedDate(DateTime dt) {
    _displayedDate = dt;
    update();
  }

  DateTime _selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime get selectedDay => _selectedDay;

  set selectedDay(DateTime dt) {
    _selectedDay = DateTime(dt.year, dt.month, dt.day);
    update();
  }

  bool _isMyCalendar = true;

  bool get isMyCalendar => _isMyCalendar;
  set isMyCalendar(bool b) {
    _isMyCalendar = b;
    update();
  }

  Map<String, List<Schedule>> _mySchedule = {};
  Map<String, List<Schedule>> _mySocialSchedule = {};
  Map<String, List<Schedule>> _socialSchedule = {};

  Map<String, List<Schedule>> get mySchedule => _mySchedule;
  set mySchedule(Map<String, List<Schedule>> mySchedule) {
    _mySchedule = mySchedule;
    update();
  }

  Map<String, List<Schedule>> get mySocialSchedule => _mySocialSchedule;
  set mySocialSchedule(Map<String, List<Schedule>> mySocialSchedule) {
    _mySocialSchedule = mySocialSchedule;
    update();
  }

  Map<String, List<Schedule>> get socialSchedule => _socialSchedule;
  set socialSchedule(Map<String, List<Schedule>> socialSchedule) {
    _socialSchedule = socialSchedule;
    update();
  }

  addSchedule(String name, DateTime start, List<Band>? shareWith) {
    //mySchedule 아니면 mySocialSchedule

    final newScheduleRef = FirebaseFirestore.instance
        .collection('schedules')
        .doc(_myJediUserCtrl.myJediUser.userID)
        .collection(shareWith == null ? 'mySchedule' : 'mySocialSchedule')
        .doc();

    print(newScheduleRef);

    Schedule s = Schedule(
        userID: _myJediUserCtrl.myJediUser.userID,
        scheduleID: newScheduleRef.id,
        title: name,
        start: start,
        end: start,
        allDay: true,
        shareWith: shareWith);

    newScheduleRef.set(s.toMap());

    if (shareWith == null) {
      _mySchedule[s.start.dateInString] ??= [];
      _mySchedule[s.start.dateInString]!.add(s);
    } else {
      _mySocialSchedule[s.start.dateInString] ??= [];
      _mySocialSchedule[s.start.dateInString]!.add(s);
    }

    update();
  }
}
