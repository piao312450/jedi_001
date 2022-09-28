import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedi_001/screens/login_page.dart';
import 'package:jedi_001/structure/getx_controller/my_jedi_user_controller.dart';
import 'package:jedi_001/structure/getx_controller/profile_controller.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(child: const Text('로그 아웃'), onPressed: () async {
          Get.offAll(() => const LoginPage());

          // await Get.delete<MyJediUserController>();
          // await Get.delete<ProfileController>();
          FirebaseAuth.instance.signOut();
        }),
      ),
    );
  }
}
