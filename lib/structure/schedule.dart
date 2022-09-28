import 'package:jedi_001/structure/band.dart';

class Schedule {
  String userID;
  String scheduleID;
  String title;
  DateTime start;
  DateTime end;
  bool allDay = true;
  Band? shareWith;

  Schedule(
      {required this.userID,
      required this.scheduleID,
      required this.title,
      required this.allDay,
      required this.start,
      required this.end,
      required this.shareWith});

  factory Schedule.fromMap(Map<String, dynamic> m) {
    return Schedule(
        title: m['title'],
        allDay: m['allDay'],
        start: DateTime.fromMillisecondsSinceEpoch(m['start'].seconds),
        scheduleID: '',
        userID: '',
        end: DateTime.fromMillisecondsSinceEpoch(m['start'].seconds),
        shareWith: m['shareWith']);
  }
}
