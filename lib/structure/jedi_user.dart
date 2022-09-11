class JediUser {
  String? userID;
  String? name;
  String? phoneNumber;
  List<String> friend = []; //userID = email 로 저장, 접근
  List<String> contact = [];
  bool isContactSync;

  JediUser({
    required this.userID,
    required this.name,
    required this.phoneNumber,
    required this.friend,
    required this.contact,
    required this.isContactSync,
  });

  static JediUser fromMap(Map userMap) {
    return JediUser(
        userID: userMap['userID'],
        name: userMap['name'],
        phoneNumber: userMap['phoneNumber'],
        friend: userMap['friend'].map<String>((d) => d.toString()).toList() ?? [],
        contact: userMap['contact'].map<String>((d) => d.toString()).toList() ?? [],
        isContactSync: userMap['isContactSync']);
  }
}
