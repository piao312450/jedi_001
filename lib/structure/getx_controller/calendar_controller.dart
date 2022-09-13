import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalendarController extends GetxController {
  DateTime _displayedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime get displayedDate => _displayedDate;
  set displayedDate(DateTime dt) {
    _displayedDate = dt;
    update();
  }

  DateTime get selectedDay => _selectedDay;
  set selectedDay(DateTime dt) {
    _selectedDay = dt;
    print(selectedDay);
    update();
  }
}