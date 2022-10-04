import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main.dart';
import '../structure/band.dart';
import '../structure/getx_controller/my_jedi_user_controller.dart';
import '../structure/jedi_user.dart';

final _myJediUserCtrl = Get.put(MyJediUserController());

class SocialPage extends StatelessWidget {
  SocialPage({Key? key}) : super(key: key);

  List<JediUser> potentialFriend = _myJediUserCtrl.myJediUser.potentialFriend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          '알림',
          style: TextStyle(fontSize: 23),
        ),
        elevation: 0,
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').doc(_myJediUserCtrl.myJediUser.userID).snapshots(),
            builder: (_, s) {
              logger.i(s.data?.data() ?? 'null');
              if (s.data == null || s.data!.data() == null) return Container(color: Colors.redAccent,);
              return FutureBuilder<List>(
                future: streamToList(s),
                builder: (_, f) {
                  if(f.hasData) {
                    if(f.data!.isEmpty) return Container(color: Colors.grey[200],);
                    return Column(
                    children: [newFriend(f), suggestedFriend(f)],
                  );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }
              );
            }),
      ),
    );
  }

  Future<List<JediUser>> streamToList(AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> s) async {
    List<JediUser> l = [];
    for(var e in s.data!.data()!['potentialFriend'].keys.toList()) {
      l.add(await JediUser.fromUserID(userID: e, socialStatus: s.data!.data()!['potentialFriend'][e]));
    }
    return l;
  }

  Widget newFriend(AsyncSnapshot f) {
    List<JediUser> newFriend = [];
    for (var e in f.data) {
      if (e.socialStatus == SocialStatus.wantMe || e.socialStatus == SocialStatus.isFriend) newFriend.add(e);
    }
    return Column(
      children: [
        newFriend.isEmpty
            ? Container()
            : Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Text(
                      '새로운 친구',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
        Column(
          children: List.generate(
              newFriend.length,
              (i) => SizedBox(
                    width: Get.width,
                    height: 70,
                    child: newFriend[i].socialStatus == SocialStatus.wantMe
                        ? wantMe(newFriend[i])
                        : isFriend(newFriend[i]),
                  )),
          // scrollDirection: Axis.vertical,
        ),
      ],
    );
  }

  Widget suggestedFriend(AsyncSnapshot f) {
    // return Container();

    // wantYou 가 포함된 리스트!!
    List<JediUser> suggestedFriend = [];
    for (var e in f.data) {
      if (e.socialStatus == SocialStatus.notFriend || e.socialStatus == SocialStatus.wantYou) suggestedFriend.add(e);
    }
    return Column(
      children: [
        suggestedFriend.isEmpty
            ? Container()
            : Row(
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '추천 친구',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Column(
          children: List.generate(
              suggestedFriend.length,
                  (i) =>
                  SizedBox(
                    width: Get.width,
                    height: 70,
                    child: suggestedFriend[i].socialStatus == SocialStatus.notFriend
                        ? notFriend(suggestedFriend[i])
                        : wantYou(suggestedFriend[i]),
                  )),
          // scrollDirection: Axis.vertical,
        ),
      ],
    );
  }

  Widget wantMe(JediUser j) {
    return basicTile(
        j,
        '${j.name} 님이 친구 요청을 보냈어요',
        SizedBox(
          width: 150,
          height: 33,
          child: Row(
            children: [
              SizedBox(
                height: 33,
                child: ElevatedButton(
                  onPressed: () => acceptFriendRequest(j),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                  child: const Text(
                    '수락',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              Container(
                height: 33,
                padding: const EdgeInsets.only(left: 20),
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                  child: const Text(
                    '거절',
                    style: TextStyle(fontSize: 13),
                  ),
                  // paddingOnly(20),
                ),
              )
            ],
          ),
        ));
  }

  Widget isFriend(JediUser j) {
    return basicTile(
        j,
        '${j.name} 님과 새로 친구가 되었어요',
        SizedBox(
          height: 33,
          child: ElevatedButton(
            onPressed: () => newFriendOK(j),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: const Text(
              '확인',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ));
  }

  Widget notFriend(JediUser j) {
    return basicTile(
        j,
        j.name,
        SizedBox(
          height: 33,
          child: ElevatedButton(
            onPressed: () => sendFriendRequest(j),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: const Text(
              '친구 추가',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ));
  }

  Widget wantYou(JediUser j) {
    return basicTile(
        j,
        j.name,
        SizedBox(
          height: 40,
          width: 180,
          child: Row(
            children: [
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                child: const Text(
                  '친구 추가',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    _myJediUserCtrl.updateMyJediUser(Update.potentialFriendUpdate, [j, SocialStatus.isFriend]);
                  },
                  child: Text('상대가 수락'))
            ],
          ),
        ));
  }

  Widget basicTile(JediUser j, String title, Widget t) {
    return ListTile(
      leading: Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 7, top: 6),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: j.profilePicInUInt8List != null
                      ? Image.memory(j.profilePicInUInt8List!).image
                      : Image.asset('assets/images/default_profile.jpeg').image,
                  fit: BoxFit.cover),
              shape: BoxShape.circle,
              color: Colors.green)),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: t,
      visualDensity: const VisualDensity(vertical: 3),
      contentPadding: const EdgeInsets.only(right: 15),
    );
  }

  Future<void> sendFriendRequest(JediUser j) async {
    //내가 친구 요청을 보내는 대상 = j
    //나한테 얘는 wantYou, 얘한테 나는 wantMe
    //이렇게 바꾸어준다
    await _myJediUserCtrl.updateMyJediUser(Update.potentialFriendUpdate, [j, SocialStatus.wantYou]);

    FirebaseFirestore.instance
        .collection('users')
        .doc(j.userID)
        .update({'potentialFriend.${_myJediUserCtrl.myJediUser.userID}': 2});
  }

  Future<void> acceptFriendRequest(JediUser j) async {
    //나에게 친구 요청을 보낸 대상 = j
    //j 의 friend 역시 함께 수정해야한다!

    String s = _myJediUserCtrl.myJediUser.userID;
    await FirebaseFirestore.instance.collection('users').doc(j.userID).update({'potentialFriend.$s': 3});
    await FirebaseFirestore.instance.collection('users').doc(j.userID).update({
      'friend': FieldValue.arrayUnion([s])
    });

    _myJediUserCtrl.updateMyJediUser(Update.potentialFriendRemove, j); //potentialFriend 에서 없애고
    _myJediUserCtrl.updateMyJediUser(Update.friendAdd, j); //friend 에 넣는다

    decideBand(j);
  }

  void newFriendOK(JediUser j) {
    // 내가 친구 요청을 보냈고, 상대방이 수락했을 때. (= isFriend 상태)
    // potentialFriend 에서 삭제한다
    _myJediUserCtrl.updateMyJediUser(Update.potentialFriendRemove, j);
    decideBand(j);
  }

  void decideBand(JediUser j) {
    List<Band> selectedBand = [];

    Get.bottomSheet(StatefulBuilder(builder: (context, setState) {
      return Container(
        width: Get.width,
        height: 300,
        color: Colors.yellow[200],
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    )),
                const Text(
                  '밴드 선택',
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Get.back();
                      for (final e in selectedBand) {
                        _myJediUserCtrl.updateBand(Update.addMemberTo, e, j.userID);
                      }
                    },
                    icon: const Icon(
                      Icons.check,
                      size: 30,
                    ))
              ],
            ),
            Row(
              children: List.generate(
                  _myJediUserCtrl.myJediUser.band.length,
                  (i) => GestureDetector(
                        child: Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          child: Text(_myJediUserCtrl.myJediUser.band[i].name),
                          decoration: BoxDecoration(
                            color: _myJediUserCtrl.myJediUser.band[i].color,
                            shape: BoxShape.circle,
                            border: selectedBand.contains(_myJediUserCtrl.myJediUser.band[i])
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (selectedBand.contains(_myJediUserCtrl.myJediUser.band[i])) {
                              selectedBand.remove(_myJediUserCtrl.myJediUser.band[i]);
                            } else {
                              selectedBand.add(_myJediUserCtrl.myJediUser.band[i]);
                            }
                          });
                        },
                      )),
            )
          ],
        ),
      );
    }));
  }
}

//

//
// Widget trailingOfJediUserTile(JediUser j, SocialStatus s) {
//   if (s == SocialStatus.notFriend || s == SocialStatus.wantYou) {
//     //추천 친구일 떄 (친구 추가 버튼)
//     return SizedBox(
//       height: 33,
//       child: ElevatedButton(
//         onPressed: s == SocialStatus.notFriend ? () => sendFriendRequest(j) : null,
//         // onPressed: null,
//         style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
//         child: const Text(
//           '친구 추가',
//           style: TextStyle(fontSize: 13),
//         ),
//       ),
//     );
//   } else {
//     return SizedBox(
//       width: 150,
//       height: 33,
//       child: Row(
//         children: [
//           SizedBox(
//             height: 33,
//             child: ElevatedButton(
//               onPressed: () => acceptFriendRequest(j),
//               style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
//               child: const Text(
//                 '수락',
//                 style: TextStyle(fontSize: 13),
//               ),
//             ),
//           ),
//           s == SocialStatus.wantMe
//               ? Container(
//             height: 33,
//             padding: const EdgeInsets.only(left: 20),
//             child: ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
//               child: const Text(
//                 '거절',
//                 style: TextStyle(fontSize: 13),
//               ),
//               // paddingOnly(20),
//             ),
//           )
//               : Container()
//         ],
//       ),
//     );
//   }
// }
