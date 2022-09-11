import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedi_001/screens/login_page.dart';
import 'package:jedi_001/screens/unauthorized_page.dart';
import 'package:jedi_001/structure/getx_controller/jedi_user_controller.dart';
import 'package:jedi_001/structure/jedi_user.dart';

import '../main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JediUserController());

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            GetBuilder<JediUserController>(builder: (_) {
              assert(controller.jediUser != null);
              return Container(
                  width: Get.width*0.9,
                  height: 70,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 40,
                        height:40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange
                        ),
                      ),
                      Text(controller.jediUser!.name ?? "이름이 null"),
                      ElevatedButton(
                        child: const Text('로그 아웃'),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();

                        },
                      ),
                    ],
                  ));
            }),
          ],
        ),
      ),
    );
  }
}
