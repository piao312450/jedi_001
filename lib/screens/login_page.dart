import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedi_001/screens/signup_page.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIDController = TextEditingController();
  final TextEditingController _userPWController = TextEditingController();

  Widget _userIDForm() {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: TextField(
        controller: _userIDController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: "이메일",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }

  Widget _userPWForm() {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: TextField(
        controller: _userPWController,
        decoration: const InputDecoration(
          labelText: "비밀번호",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(onPressed: _login, child: const Text("로그인")),
    );
  }

  Widget _signUpButton() {
    return TextButton(onPressed: () {
      Get.to(() => const SignUpPage());
    }, child: const Text('회원가입'));
  }

  _login() async {
    //키보드 숨기기
    FocusScope.of(context).requestFocus(FocusNode());

    // Firebase 사용자 인증, 사용자 등록
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _userIDController.text,
        password: _userPWController.text,
      );
      logger.d("로그인 성공");
      // Get.offAll(() => const SignUpPage());
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      String message = '';

      if (e.code == 'user-not-found') {
        message = '사용자가 존재하지 않습니다.';
      } else if (e.code == 'wrong-password') {
        message = '비밀번호를 확인하세요';
      } else if (e.code == 'invalid-email') {
        message = '이메일을 확인하세요.';
      }
      logger.d(message);
      /*final snackBar = SnackBar(
          content: Text(message),
          backgroundColor: Colors.deepOrange,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      */

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.deepOrange,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _userIDForm(),
            _userPWForm(),
            _submitButton(),
            _signUpButton()
          ],
        ),
      ),
    );
  }
}
