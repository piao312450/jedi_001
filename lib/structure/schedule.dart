class Schedule {
  String title;
  bool allDay = true;
  DateTime start;
  DateTime? end;

  Schedule({required this.title, required this.allDay, required this.start, this.end});

  static Schedule fromMap(Map<String, dynamic> m) {
    return Schedule(title: m['title'], allDay: m['allDay'], start: DateTime.fromMillisecondsSinceEpoch(m['start'].seconds));
  }
}
