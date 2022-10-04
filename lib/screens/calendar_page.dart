import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:jedi_001/structure/getx_controller/calendar_controller.dart';
import 'package:jedi_001/structure/getx_controller/my_jedi_user_controller.dart';
import 'package:jedi_001/structure/getx_controller/preference_controller.dart';
import 'package:jedi_001/structure/getx_controller/schedule_controller.dart';
import 'package:jedi_001/structure/my_jedi_user.dart';
import 'package:jedi_001/widget/calendar_scrollPhysics.dart';
import 'package:jedi_001/widget/datetime_extension.dart';

import '../main.dart';
import '../structure/band.dart';
import '../structure/schedule.dart';
import '../widget/select_band_bottom_sheet.dart';

final preferenceCtrl = Get.put(PreferenceController());
final myJediUserCtrl = Get.put(MyJediUserController());
final calendarCtrl = Get.put(CalendarController());
final scheduleCtrl = Get.put(ScheduleController());

List<String> weekday = const ['일', '월', '화', '수', '목', '금', '토', '일'];

class CalendarPage extends StatelessWidget {
  CalendarPage({Key? key}) : super(key: key);
  late BuildContext c;
  @override
  Widget build(BuildContext context) {
    c = context;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        bottom: mondayToSunday(),
        title: yearAndMonth(),
        centerTitle: false,
        actions: [toggleBetweenMeAndSocial()],
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

  final PageController _pageController = PageController(initialPage: 100);

  final int firstWeekday = preferenceCtrl.firstWeekday; //일요일 0 ~ 토요일 6
  final Axis scrollDirection = preferenceCtrl.monthViewScrollDirection;

  DateTime displayedDate = calendarCtrl.displayedDate;
  DateTime selectedDay = calendarCtrl.selectedDay;

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

  Widget toggleBetweenMeAndSocial() {
    // return Container();
    return GetBuilder<CalendarController>(builder: (_) {
      return ToggleButtons(
        children: const [Icon(Icons.person), Icon(Icons.people)],
        onPressed: (int i) {
          _.isMyCalendar = i == 0 ? true : false;
        },
        isSelected: [_.isMyCalendar, !_.isMyCalendar],
        renderBorder: false,
      );
    });
  }

  PreferredSizeWidget mondayToSunday() {
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
                    i + firstWeekday < 7 ? weekday[i + firstWeekday] : weekday[i + firstWeekday - 7],
                    style: const TextStyle(fontSize: 12),
                  )),
        ),
      ),
    );
  }

  Widget monthView() {
    DateTime initialDate = DateTime.fromMillisecondsSinceEpoch(calendarCtrl.displayedDate.millisecondsSinceEpoch);
    return GetBuilder<CalendarController>(builder: (_) {
      return PageView.builder(
        controller: _pageController,
        scrollDirection: scrollDirection,
        physics: const CustomPageViewScrollPhysics(),
        itemBuilder: (c, i) {
          DateTime dt = DateTime(initialDate.year, initialDate.month - 100 + i); //build 해야할 연월
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
          print(i);
          print(initialDate);
          print(_.displayedDate);
          _.displayedDate = DateTime(initialDate.year, initialDate.month - 100 + i);
        },
      );
    });
  }

  Widget dayBlock(DateTime dt, int i, int j) {
    int day = 7 * i + j + 1 + firstWeekday - DateTime(dt.year, dt.month, 1).weekday;
    DateTime date = DateTime(dt.year, dt.month, day);
    return Expanded(
        child: GestureDetector(
      child: GetBuilder<CalendarController>(builder: (_) {
        return Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              color: _.selectedDay.isAtSameMomentAs(date) ? Colors.grey : Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${date.day}',
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  // LayoutBuilder(
                  //   builder: (context, constraints) {
                  //     return Container(
                  //       width: constraints.,
                  //     );
                  //   }),
                  ...dayBlock2(_.isMyCalendar
                      ? [...?_.mySchedule[date.dateInString], ...?_.mySocialSchedule[date.dateInString]]
                      : [...?_.mySocialSchedule[date.dateInString], ...?_.socialSchedule[date.dateInString]])
                ],
              ),
            ),
            date.month != dt.month
                ? Container(
                    color: Colors.white.withOpacity(0.6),
                  )
                : Container()
          ],
        );
      }),
      onTapDown: (_) {
        calendarCtrl.selectedDay = date;
      },
      onLongPress: () {
        calendarCtrl.selectedDay = date;
        // Vibrate.feedback(FeedbackType.light);
        Get.bottomSheet(addScheduleBottomSheet(date),
            enterBottomSheetDuration: const Duration(milliseconds: 150), isScrollControlled: true);
      },
    ));
  }

  List<Widget> dayBlock2(List<Schedule> l) {
    List<Widget> result = [];
    for (int i = 0; i < 4; i++) {
      if (!l.asMap().containsKey(i)) continue;
      result.add(Container(
        width: Get.width / 7 - 2.5,
        // height: 12,
        color: Theme.of(c).primaryColor,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 0.8),
        child: Text(
          l[i].title,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: const TextStyle(fontSize: 9),
        ),
      ));
    }
    if (l.length > 4) {
      result[3] = Row(
        children: [
          const SizedBox(width: 5),
          Text(
            '+${l.length - 3}',
            style: const TextStyle(fontSize: 8),
          ),
        ],
      );
    }

    return result;
  }

  Widget addScheduleBottomSheet(DateTime dt) {
    TextEditingController _textEditingController = TextEditingController();
    bool willShare = false;
    List<Band> shareWith = [myJediUserCtrl.myJediUser.band.singleWhere((e) => e.name == '친구')];

    String title = '';

    return StatefulBuilder(builder: (_, setState) {
      return Container(
        width: Get.width,
        height: Get.height * 0.4,
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
                    onPressed: title.isEmpty
                        ? null
                        : () {
                            Get.back();
                            calendarCtrl.addSchedule(title, dt, willShare ? shareWith : null);
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
                                title = s;
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
                      ? ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            '다음과 공유:',
                            style: TextStyle(fontSize: 22, color: Colors.black54),
                          ),
                          trailing: GestureDetector(
                            onTap: () async {
                              shareWith = await Get.bottomSheet(selectBandBottomSheet(shareWith));
                              setState(() {
                                if (shareWith.isEmpty) {
                                  shareWith = [myJediUserCtrl.myJediUser.band.singleWhere((e) => e.name == '친구')];
                                }
                                shareWith = shareWith;
                              });
                            },
                            child: Container(
                              width: Get.width * 0.5,
                              alignment: Alignment.centerRight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                      shareWith.length,
                                      (i) => Row(
                                            children: [
                                              Container(
                                                  width: 30,
                                                  height: 30,
                                                  alignment: Alignment.centerRight,
                                                  margin: const EdgeInsets.only(right: 10),
                                                  decoration:
                                                      BoxDecoration(shape: BoxShape.circle, color: shareWith[i].color)),
                                              Text(
                                                shareWith[i].name,
                                                style: const TextStyle(fontSize: 20),
                                              ),
                                              Text(shareWith.asMap().containsKey(i + 1) ? ', ' : '',
                                                  style: const TextStyle(fontSize: 20))
                                            ],
                                          )),
                                ),
                              ),
                            ),
                          ))
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
    return [Container()];
    //dt는 displayedDate, i는 몇번째 주인
    int day = 0;

    List<Schedule> schedulesToDraw = [];
    int numberOfScheduleForOneWeek = 0;
    for (int j = 0; j < 7; j++) {
      day = 7 * i + j + 1 + firstWeekday - DateTime(dt.year, dt.month, 1).weekday;
      dt = DateTime(dt.year, dt.month, day);
      try {
        numberOfScheduleForOneWeek += scheduleCtrl.myCalendar[dt.dateInString]!.length;
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
            decoration: BoxDecoration(color: Colors.blue, border: Border.all(color: Colors.white, width: 1)),
            alignment: Alignment.center,
            child: Text(
              '$j',
              style: const TextStyle(fontSize: 13),
            ),
          ));
    });
  }

  Widget scheduleView() {
    return GetBuilder<CalendarController>(builder: (_) {
      DateTime dt = _.selectedDay;
      List<Schedule> schedule = _.isMyCalendar
          ? [...?_.mySchedule[dt.dateInString], ...?_.mySocialSchedule[dt.dateInString]]
          : [...?_.mySocialSchedule[dt.dateInString], ...?_.socialSchedule[dt.dateInString]];

      return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.only(top: 6, left: 10, right: 10),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '${dt.year}년 ${dt.month}월 ${dt.day}일 (${weekday[dt.weekday]})',
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                      GestureDetector(
                        child: Container(
                          child: const Text(
                            '+ 새로운 이벤트',
                            style: TextStyle(fontSize: 18),
                          ),
                          width: Get.width,
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          margin: const EdgeInsets.symmetric(vertical: 3.5),
                          decoration:
                              const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(const Radius.circular(7))),
                          alignment: Alignment.centerLeft,
                        ),
                        onTap: () => Get.bottomSheet(addScheduleBottomSheet(dt),
                            enterBottomSheetDuration: const Duration(milliseconds: 150), isScrollControlled: true),
                      )
                    ] +
                    List.generate(
                        schedule.length,
                        (i) => GestureDetector(
                              child: Container(
                                child: Text(
                                  '${schedule[i].title}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                width: Get.width,
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                margin: const EdgeInsets.symmetric(vertical: 3.5),
                                decoration: const BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.all(const Radius.circular(7))),
                                alignment: Alignment.centerLeft,
                              ),
                              onTap: () => Get.bottomSheet(addScheduleBottomSheet(dt),
                                  enterBottomSheetDuration: const Duration(milliseconds: 150),
                                  isScrollControlled: true),
                            )),
              ),
            )
          ],
        ),
        width: Get.width,
      );
    });
  }
}
