import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedi_001/screens/login_page.dart';
import 'package:jedi_001/structure/getx_controller/my_jedi_user_controller.dart';
import 'package:jedi_001/structure/my_jedi_user.dart';

import '../main.dart';

final _myJediUserCtrl = Get.put(MyJediUserController());

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(47),
        child: AppBar(
          backgroundColor: Colors.orange,
          title: const Text(
            '친구',
            style: TextStyle(fontSize: 23),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
          elevation: 0,
        ),
      ),
      body: Center(
        child: GetBuilder<MyJediUserController>(builder: (_) {
          assert(_myJediUserCtrl.myJediUser != null);
          return Column(
            children: [
              myProfileListTile(),
              const Divider(),
              bandTile(),
              const Divider(),
              searchBar(),
              Expanded(child: friendList()),
              // ElevatedButton(child: const Text('로그 아웃'), onPressed: FirebaseAuth.instance.signOut),
            ],
          );
        }),
      ),
    );
  }

  Widget myProfileListTile() {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlueAccent),
      ),
      title: Text(
        _myJediUserCtrl.myJediUser!.name ?? "이름이 null",
        style: const TextStyle(fontSize: 17),
      ),
      trailing: const IconButton(
        onPressed: null,
        icon: Icon(Icons.edit),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    );
  }

  Widget friendSuggestTile() {
    return Column(
      children: [
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '추천 친구',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
              ),
            )
          ],
        ),
        SizedBox(
          child: ListView(
            children: List.generate(
                _myJediUserCtrl.friendSuggestion.length,
                    (i) =>
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 7, top: 6),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                        ),
                        FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(_myJediUserCtrl.friendSuggestion[i])
                                .get()
                                .then((v) => v.data()!['name']),
                            builder: (_, s) {
                              return Text(
                                s.data.toString(),
                                style: const TextStyle(fontSize: 12),
                              );
                            })
                      ],
                    )),
            scrollDirection: Axis.horizontal,
          ),
          width: Get.width,
          height: 76,
        ),
      ],
    );
  }

  Widget bandTile() {
    return Column(
      children: [
        // Row(
        //   children: const [
        //     Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 23.0),
        //       child: Text(
        //         '밴드',
        //         style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300),
        //       ),
        //     )
        //   ],
        // ),
        SizedBox(
          width: Get.width,
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(
                _myJediUserCtrl.myJediUser?.band.length ?? 0,
                    (i) =>
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(_myJediUserCtrl.myJediUser!.band[i].name),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.lime),
                    )) + [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: const Icon(Icons.add),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.lime),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget friendList() {
    return Container(
      color: Colors.pink,
    );
  }

  Widget searchBar() {
    return Container(
      width: Get.width*0.96,
      height: 50,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10, top: 5),
      child: const TextField(
        cursorColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.search, size: 26,),
          )
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Colors.grey[300],

      ),
    );
  }
}
