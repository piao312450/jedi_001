import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedi_001/screens/login_page.dart';

import '../main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _userPNController =
      TextEditingController(); //전화번호(phone number)
  late String _userName;
  late String _userID;
  late String _userPW;
  late String _userPhoneNumber;
  bool isValidPhoneNumber = false;

  Widget _userNameForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      alignment: Alignment.center,
      child: TextFormField(
        onSaved: (v) {
          _userName = v!;
        },
        validator: (v) {
          assert(v != null);
          if (v!.isEmpty) return "이름 입력하세여";
          return null;
        },
        decoration: const InputDecoration(
          labelText: "이름",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }

  Widget _userIDForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextFormField(
        onSaved: (v) {
          _userID = v!;
        },
        validator: (v) {
          assert(v != null);
          if (v!.isEmpty) return "이메일 입력하세여";
          if (!RegExp(
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
              .hasMatch(v)) {
            return '잘못된 이메일 형식이네요!';
          }
          return null;
        },
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
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      alignment: Alignment.center,
      child: TextFormField(
        onSaved: (v) {
          _userPW = v!;
        },
        validator: (v) {
          assert(v != null);
          if (v!.isEmpty) return "비밀번호 입력하세여";
          if (v.length < 6) {
            return '6자 이상 입력해주세요!';
          }
          return null;
        },
        obscureText: true,
        decoration: const InputDecoration(
          labelText: "비밀번호",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }

  Widget _userPhoneNumberForm() {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          width: 235,
          height: 80,
          alignment: Alignment.center,
          child: TextFormField(
            controller: _userPNController,
            onSaved: (v) {
              _userPhoneNumber = v!;
            },
            validator: (v) {
              assert(v != null);
              if (v!.isEmpty) return "전화번호 입력하세여";
              if (v.length != 11) return "11자리 입력해주세여";
              return null;
            },
            onChanged: (s) {
              print(s);
              setState(() {
                if (s.length == 8)
                  isValidPhoneNumber = true;
                else
                  isValidPhoneNumber = false;
              });
            },
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "전화번호",
              hintText: "하이픈(-) 없이 11자리 (예시: 01012345678)",
              hintStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ),
        ButtonTheme(
          height: 50,
          child: ElevatedButton(
              onPressed: isValidPhoneNumber ? _authenticatePhoneNumber : null,
              child: const Text('인증하기')),
        )
      ],
    );
  }

  Widget _signInButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(onPressed: _signIn, child: const Text("회원가입")),
    );
  }

  Widget _goBackButton() {
    return TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('뒤로 가기'));
  }

  //전화번호 인증 함수
  void _authenticatePhoneNumber() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    logger.d("+8210" + _userPNController.value.text.toString());
    _auth.verifyPhoneNumber(
        phoneNumber: "+8210" + _userPNController.value.toString(),
        verificationCompleted: (v) {
          logger.d("verification complete");
        },
        verificationFailed: (v) {
          logger.d("verification fail");
          logger.d(v.code);
        },
        codeSent: (c, s) {
          logger.d("code sent");
        },
        codeAutoRetrievalTimeout: (s) {});
  }

  void _signIn() async {
    assert(formKey.currentState != null);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save(); //입력한 정보가 다 유효(valid)하면 입력값을 변수에 저장!
      try {
        logger.d('$_userID & $_userPW');
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _userID, password: _userPW)
            .then((v) {
          assert(v.user != null);
          assert(v.user!.email != null);
          Get.off(const LoginPage());
          return v;
        });
        final CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        users
            .doc(_userID)
            .set({'name': _userName, 'phoneNumber': _userPhoneNumber});


      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('the password provided is too weak');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        } else {
          print('11111');
          print(e.code);
        }
      } catch (e) {
        print('끝');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _userNameForm(),
          _userIDForm(),
          _userPWForm(),
          _userPhoneNumberForm(),
          _signInButton(),
          _goBackButton()
        ],
      ),
    ));
  }
}
