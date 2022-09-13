import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:jedi_001/structure/getx_controller/calendar_controller.dart';
import 'package:jedi_001/structure/getx_controller/preference_controller.dart';
import 'package:jedi_001/structure/getx_controller/schedule_controller.dart';
import 'package:jedi_001/widget/calendar_scrollPhysics.dart';
import 'package:jedi_001/widget/datetime_extension.dart';

import '../structure/schedule.dart';

class CalendarPage extends StatelessWidget {
  CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        bottom: mondayToSunday(),
        title: yearAndMonth(),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: monthView(),
              flex: 65,
            ),
            Expanded(
              child: scheduleView(),
              flex: 35,
            )
          ],
        ),
      ),
    );
  }

  final preferenceCtrl = Get.put(PreferenceController());
  final calendarCtrl = Get.put(CalendarController());
  final scheduleCtrl = Get.put(ScheduleController());
  final PageController _pageController = PageController(initialPage: 100);

  final int firstWeekday = Get.find<PreferenceController>().firstWeekday; //일요일 0 ~ 토요일 6
  final Axis scrollDirection = Get.find<PreferenceController>().monthViewScrollDirection;

  DateTime displayedDate = Get.find<CalendarController>().displayedDate;
  DateTime selectedDay = Get.find<CalendarController>().selectedDay;

  // currentMonth 가 몇개의 주로 이루어져있는지 계산. 4~6의 값을 가짐.
  int numberOfWeek(DateTime dt) {
    int push = (DateTime(dt.year, dt.month, 1).weekday - firstWeekday) % 7;
    int z = DateTime(dt.year, dt.month + 1, 0).day;
    if (push + z % 7 == 0) return 4;
    if (push + z % 7 < 8) return 5;
    return 6;
  }

  //appBar 왼쪽에 연, 월 표시 - 예) 2022년 9월
  Widget yearAndMonth() {
    return GetBuilder<CalendarController>(
      builder: (_) {
        return Text(
          '${_.displayedDate.year}년 ${_.displayedDate.month}월',
          style: const TextStyle(fontSize: 23),
        );
      },
    );
  }

  PreferredSizeWidget mondayToSunday() {
    List<String> l = const ['일', '월', '화', '수', '목', '금', '토'];
    return PreferredSize(
      preferredSize: const Size.fromHeight(16),
      child: Container(
        color: Colors.white,
        height: 25,
        width: Get.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
              7,
              (i) => Text(
                    i + firstWeekday < 7 ? l[i + firstWeekday] : l[i + firstWeekday - 7],
                    style: TextStyle(fontSize: 12),
                  )),
        ),
      ),
    );
  }

  Widget monthView() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: scrollDirection,
      physics: const CustomPageViewScrollPhysics(),
      itemBuilder: (_, i) {
        DateTime dt = DateTime(DateTime.now().year, DateTime.now().month - 100 + i); //build 해야할 연월
        return Column(
            children: List.generate(
                6,
                (i) => Expanded(
                      child: Stack(
                          children: <Widget>[
                                Row(
                                    children: List.generate(7, (j) {
                                  return dayBlock(dt, i, j);
                                })),
                              ] +
                              drawSchedule(dt, i)),
                    )));
      },
      onPageChanged: (i) async {
        calendarCtrl.displayedDate = DateTime(DateTime.now().year, DateTime.now().month - 100 + i);
      },
    );
  }

  Widget dayBlock(DateTime dt, int i, int j) {
    int day = 7 * i + j + 1 + firstWeekday - DateTime(dt.year, dt.month, 1).weekday;
    dt = DateTime(dt.year, dt.month, day);
    return Expanded(
        child: GestureDetector(
      child: GetBuilder<CalendarController>(builder: (_) {
        return Container(
          alignment: Alignment.topCenter,
          color: _.selectedDay.isAtSameMomentAs(DateTime(dt.year, dt.month, day)) ? Colors.grey : Colors.white,
          child: Text(
            '${dt.day}',
            style: TextStyle(
                fontSize: 12,
                color: _.selectedDay.isAtSameMomentAs(dt)
                    ? Colors.white
                    : dt.month != _.displayedDate.month
                        ? Colors.grey
                        : Colors.black),
          ),
        );
      }),
      onTapDown: (_) {
        Get.find<CalendarController>().selectedDay = DateTime(dt.year, dt.month, day);
      },
      onLongPress: () {
        Get.find<CalendarController>().selectedDay = DateTime(dt.year, dt.month, day);
        // Vibrate.feedback(FeedbackType.light);
        Get.bottomSheet(addScheduleBottomSheet(dt),
            enterBottomSheetDuration: const Duration(milliseconds: 150), isScrollControlled: true);
      },
    ));
  }

  Widget addScheduleBottomSheet(DateTime dt) {
    TextEditingController _textEditingController = TextEditingController();
    final _scheduleCtrl = Get.put(ScheduleController());
    bool willShare = false;
    String scheduleName = '';

    return StatefulBuilder(builder: (_, setState) {
      return Container(
        width: Get.width,
        height: Get.height * 0.35,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.yellow[200],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    )),
                Text(
                  '${dt.month}월 ${dt.day}일',
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    constraints: const BoxConstraints(),
                    onPressed: scheduleName.isEmpty
                        ? null
                        : () {
                            Get.back();
                            Schedule s = Schedule(title: scheduleName, allDay: true, start: dt);
                            _scheduleCtrl.saveSchedule(s);
                          },
                    icon: const Icon(
                      Icons.check,
                      size: 30,
                    ))
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _textEditingController,
                            style: const TextStyle(fontSize: 28),
                            onChanged: (s) {
                              setState(() {
                                scheduleName = s;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: '제목을 입력하세요',
                              hintStyle: TextStyle(fontSize: 28),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text(
                      '일정 공유하기',
                      style: TextStyle(fontSize: 22, color: Colors.black54),
                    ),
                    value: willShare,
                    onChanged: (b) {
                      setState(() {
                        willShare = b;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  willShare
                      ? const ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '공유 대상',
                            style: TextStyle(fontSize: 22, color: Colors.black54),
                          ),
                        )
                      : Container(),
                  // Container(
                  //   width: 50,
                  //   height: 50,
                  //   color: Colors.purpleAccent,
                  // )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> drawSchedule(DateTime dt, int i) {
    //dt는 displayedDate, i는 몇번째 주인
    int day = 0;

    List<Schedule> schedulesToDraw = [];
    int numberOfScheduleForOneWeek = 0;
    for (int j = 0; j < 7; j++) {
      day = 7 * i + j + 1 + firstWeekday - DateTime(dt.year, dt.month, 1).weekday;
      dt = DateTime(dt.year, dt.month, day);
      try {
        numberOfScheduleForOneWeek += scheduleCtrl.everyScheduleMap[dt.dateInString]!.length;
      } catch (e) {}
    }

    return List.generate(numberOfScheduleForOneWeek, (j) {
      day = 7 * i + j + 1 + firstWeekday - DateTime(dt.year, dt.month, 1).weekday;
      dt = DateTime(dt.year, dt.month, day);

      return Positioned(
          left: j * Get.width / 7,
          top: 15,
          child: Container(
            // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            height: 15,
            width: Get.width / 7,
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 1)
            ),
            alignment: Alignment.center,
            child: Text('$j', style: TextStyle(fontSize: 13),),
          ));
    });
  }

  Widget scheduleView() {
    return Container(
      color: Colors.greenAccent,
      // child: Text('${dt}'),
      width: Get.width,
    );
  }
}
