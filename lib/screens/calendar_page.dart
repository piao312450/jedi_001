import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);
  final int startOfWeek = 7;

  // currentMonth 가 몇개의 주로 이루어져있는지 계산. 4~6의 값을 가짐.
  int numberOfWeek(DateTime dt) {
    int push =
        (DateTime(dt.year, dt.month, 1).weekday - startOfWeek) % 7;
    int z = DateTime(dt.year, dt.month + 1, 0).day;
    if (push + z % 7 == 0) return 4;
    if (push + z % 7 < 8) return 5;
    return 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Container(
                color: Colors.red,
              ),
              flex: 65,
            ),
            Expanded(
              child: Container(
                color: Colors.blue,
              ),
              flex: 35,
            )
          ],
        ),
      ),
    );
  }
}
