import 'package:get/get.dart';
import '../../main.dart';
import '../jedi_user.dart';

class JediUserController extends GetxController {
  JediUser? jediUser;

  Future<void> setJediUser(Map<String, dynamic> m) async {
    jediUser = JediUser.fromMap(m);
    update();
  }
}
