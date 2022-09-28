import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:jedi_001/structure/getx_controller/my_jedi_user_controller.dart';
import '../band.dart';

final _myJediUserCtrl = Get.put(MyJediUserController());

class ProfileController extends GetxController {
  Band? _selectedBand;

  Band? get selectedBand => _selectedBand;

  set selectedBand(Band? s) {
    _selectedBand = s;
    update();
  }

}
