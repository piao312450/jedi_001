import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jedi_001/screens/login_page.dart';
import 'package:jedi_001/screens/unauthorized_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.data == null) {
            return const LoginPage();
          } else {
            assert(snapshot.data!.email != null);
            return Profile(userID: snapshot.data!.email!);
          }
        },
      ),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key, required this.userID}) : super(key: key);
  final String userID;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseFirestore.instance.collection('users').doc(userID);

    return Scaffold(
      body: Center(child: Column(
        children: [
          FutureBuilder(
              future: user.get().then((value) => value.data()!['name']),
              builder: (c, s){
            return Text(s.data.toString());
          }),
          ElevatedButton(
            child: Text('sign out'),
            onPressed: () {FirebaseAuth.instance.signOut();},
          ),
        ],
      ),),
    );
  }
}

