import 'package:get/get.dart';
import '../../main.dart';
import '../my_jedi_user.dart';

class MyJediUserController extends GetxController {
  MyJediUser? myJediUser;
  List<String> _friendSuggestion = [];

  Future<void> setMyJediUser(Map<String, dynamic> m) async {
    myJediUser = await MyJediUser.fromMap(m);
    logger.i('myJediUserSet: $myJediUser');
    update();
  }

  List<String> get friendSuggestion => _friendSuggestion;
  set friendSuggestion(List<String> l) {
    _friendSuggestion = l;
    update();
  }
}
