import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../schedule.dart';

class CalendarController extends GetxController {
  DateTime _displayedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);


  Map<String, List<Schedule>> _myCalendar = {};
  Map<String, List<Schedule>> _socialCalendar = {};

  DateTime get displayedDate => _displayedDate;
  set displayedDate(DateTime dt) {
    _displayedDate = dt;
    update();
  }

  DateTime get selectedDay => _selectedDay;
  set selectedDay(DateTime dt) {
    _selectedDay = dt;
    update();
  }

  Map<String, List<Schedule>> get myCalendar => _myCalendar;
  set myCalendar(Map<String, List<Schedule>> myCalendar) {
    _myCalendar = myCalendar;
    update();
  }

  Map<String, List<Schedule>> get socialCalendar => _socialCalendar;
  set socialCalendar(Map<String, List<Schedule>> myCalendar) {
    _socialCalendar = myCalendar;
    update();
  }

}