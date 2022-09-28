import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jedi_001/screens/home_page.dart';
import 'package:jedi_001/screens/login_page.dart';
import 'package:jedi_001/structure/getx_controller/my_jedi_user_controller.dart';
import 'package:jedi_001/utils/todo_after_log_in.dart';
import 'package:logger/logger.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logger.d('firebase initializeApp');
  runApp(const Jedi());
}

var logger = Logger();

class Jedi extends StatelessWidget {
  const Jedi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return const GetMaterialApp(
      home: CheckAccount(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CheckAccount extends StatelessWidget {
  const CheckAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> stream) {
        FirebaseAuth.instance
            .userChanges()
            .listen((User? user) {
          if (user == null) {
            print('User is currently signed out!');
          } else {
            print('User is signed in!');
          }
        });

        if (stream.data == null) {
          logger.d('stream.data == null');
          return const LoginPage();
        } else if(stream.connectionState == ConnectionState.active){
          // return const LoginPage();
          String userID = stream.data!.uid;
          // fetchUserFromFirebase(userID);
          fetchScheduleFromFirebase(userID);
          loadContactIfFirstLogin(userID);
          // loadFriendSuggestion(userID);     // myJediUser 가 먼저 initialization 되기 위해 fetchUserFromFirebase 에서 실행
          return FutureBuilder(
              future: fetchUserFromFirebase(userID),
              builder: (c, s) {
                if (s.hasData == false) {
                  // return LoginPage();
                  return const Center(child: CircularProgressIndicator());
                } else {
                  // Get.put(MyJediUserController());
                  // logger.d(Get.find<MyJediUserController>().myJediUser);
                  return const HomePage();
                }
              });
        }
        return const Text('이러면 안되는데..');
      },
    ));
  }
}
