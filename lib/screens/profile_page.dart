import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:jedi_001/screens/setting_page.dart';
import 'package:jedi_001/screens/social_page.dart';
import 'package:jedi_001/structure/getx_controller/my_jedi_user_controller.dart';
import 'package:jedi_001/structure/getx_controller/profile_controller.dart';
import 'package:jedi_001/utils/load_image.dart';
import '../main.dart';
import '../structure/band.dart';
import '../widget/my_check_box.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final _profileCtrl = Get.put(ProfileController());
  final _myJediUserCtrl = Get.put(MyJediUserController());

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
            IconButton(
                onPressed: () {
                  Get.to(SocialPage(), transition: Transition.rightToLeft);
                },
                icon: const Icon(Icons.favorite)),
            IconButton(
                onPressed: () {
                  Get.to(const SettingPage(), transition: Transition.rightToLeft);
                },
                icon: const Icon(Icons.settings))
          ],
          elevation: 0,
        ),
      ),
      body: Center(child: GetBuilder<ProfileController>(builder: (_p) {
        return Column(
          children: [
            myProfileTile(),
            myDivider(),
            bandTile(_p),
            myDivider(),
            searchBar(),
            Expanded(child: friendList(_p)),
          ],
        );
      })),
    );
  }

  Widget myProfileTile() {
    return GetBuilder<MyJediUserController>(builder: (_) {
      return ListTile(
          leading: GestureDetector(
            onTap: () async {
              String? path = await loadSingleImage();
              if (path == null) return;
              _.updateMyJediUser(Update.profilePic, File(path).readAsBytesSync());
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  image: _.myJediUser.profilePicInUInt8List != null
                      ? DecorationImage(image: MemoryImage(_.myJediUser.profilePicInUInt8List!), fit: BoxFit.cover)
                      : null,
                  shape: BoxShape.circle,
                  color: Colors.primaries[Random().nextInt(Colors.primaries.length)]),
            ),
          ),
          title: Text(
            _.myJediUser.name,
            style: const TextStyle(fontSize: 17),
          ),
          trailing: const IconButton(
            onPressed: null,
            icon: Icon(Icons.edit),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
          visualDensity: const VisualDensity(vertical: 2)
          // minVerticalPadding: 20,
          );
    });
  }

  Widget bandTile(ProfileController _p) {
    double r = 60;
    return GetBuilder<MyJediUserController>(builder: (_) {
      return SizedBox(
        width: Get.width,
        height: 65,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: List<Widget>.generate(
                _.myJediUser.band.length,
                (i) => GestureDetector(
                  onTap: () {
                    _p.selectedBand = _p.selectedBand == _.myJediUser.band[i] ? null : _.myJediUser.band[i];
                  },
                  child: Container(
                      width: r,
                      height: r,
                      alignment: Alignment.center,
                      child: Text(_.myJediUser.band[i].name),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                      decoration: BoxDecoration(
                          border: _p.selectedBand == _.myJediUser.band[i]
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                          shape: BoxShape.circle,
                          color: _.myJediUser.band[i].color)),
                ),
              ) +
              [
                GestureDetector(
                  onTap: addBandBottomSheet,
                  child: Container(
                    width: r,
                    height: r,
                    alignment: Alignment.center,
                    child: const Icon(Icons.add),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                  ),
                )
              ],
        ),
      );
    });
  }

  Widget friendList(ProfileController _p) {
    return GetBuilder<MyJediUserController>(builder: (_) {
      return Container(
        color: Colors.grey[200],
        width: Get.width,
        child: _.myJediUser.friend.isEmpty
            ? _p.selectedBand == null || _p.selectedBand!.name == '친구'
                ? Container()
                : TextButton(
                    onPressed: () {
                      _myJediUserCtrl.updateMyJediUser(Update.deleteBand, _p.selectedBand);
                      _p.selectedBand = null;
                    },
                    child: const Text('밴드 삭제'))
            : Column(
                children: List<Widget>.generate(
                        _.myJediUser.friend.length,
                        (i) => ListTile(
                              leading: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(left: 10, right: 10, bottom: 7, top: 6),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: _.myJediUser.friend[i].profilePicInUInt8List != null
                                              ? Image.memory(_.myJediUser.friend[i].profilePicInUInt8List!).image
                                              : Image.asset('assets/images/default_profile.jpeg').image,
                                          fit: BoxFit.cover),
                                      shape: BoxShape.circle,
                                      color: Colors.green)),
                              title: Text(_.myJediUser.friend[i].name, style: const TextStyle(fontSize: 14)),
                              trailing: _p.selectedBand == null
                                  ? null
                                  : GestureDetector(
                                      child: myCheckBox(_.myJediUser.band
                                          .singleWhere((e) => e == _p.selectedBand!)
                                          .member
                                          .contains(_.myJediUser.friend[i].userID)),
                                      onTap: () {
                                        if (_p.selectedBand!.member.contains(_.myJediUser.friend[i].userID)) {
                                          _.updateBand(
                                              Update.removeMemberFrom, _p.selectedBand!, _.myJediUser.friend[i].userID);
                                        } else {
                                          _.updateBand(
                                              Update.addMemberTo, _p.selectedBand!, _.myJediUser.friend[i].userID);
                                        }
                                      },
                                    ),
                              visualDensity: const VisualDensity(vertical: 3),
                              contentPadding: const EdgeInsets.only(right: 15),
                            )) +
                    [
                      _p.selectedBand == null || _p.selectedBand!.name == '친구'
                          ? Container()
                          : TextButton(
                              onPressed: () {
                                _myJediUserCtrl.updateMyJediUser(Update.deleteBand, _p.selectedBand);
                                _p.selectedBand = null;
                              },
                              child: const Text('밴드 삭제'))
                    ]),
      );
    });
  }

  Widget searchBar() {
    return Container(
      width: Get.width * 0.96,
      height: 45,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10, top: 5),
      child: const TextField(
        cursorColor: Colors.black,
        decoration: InputDecoration(
            border: InputBorder.none,
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.search,
                size: 26,
              ),
            )),
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Colors.grey[300],
      ),
    );
  }

  Widget myDivider() {
    return Container(
      width: Get.width * 0.95,
      height: 1,
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 6),
    );
  }

  void addBandBottomSheet() {
    TextEditingController _textEditingController = TextEditingController();
    String bandName = '';
    Color bandColor = Colors.tealAccent;
    int colorIdx = 0;
    List<Color> colorList = [
      Colors.red,
      Colors.redAccent,
      Colors.pink,
      Colors.orange,
      Colors.orangeAccent,
      Colors.yellow,
      Colors.yellowAccent,
      Colors.green,
      Colors.lightGreen,
      Colors.blue,
      Colors.lightBlue,
      Colors.purple,
      Colors.deepPurple,
      Colors.brown,
      Colors.grey
    ];

    Get.bottomSheet(StatefulBuilder(builder: (_, setState) {
      return Container(
        width: Get.width,
        height: Get.height * 0.25,
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
                  '밴드 만들기',
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    constraints: const BoxConstraints(),
                    onPressed: bandName.isEmpty
                        ? null
                        : () {
                            addBand(bandName, colorList[colorIdx]);
                            Get.back();
                          },
                    icon: const Icon(
                      Icons.check,
                      size: 30,
                    ))
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      style: const TextStyle(fontSize: 20),
                      onChanged: (s) => setState(() {
                        bandName = s;
                      }),
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: '밴드 이름', hintStyle: TextStyle(fontSize: 20)),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: Container(
              width: Get.width,
              margin: const EdgeInsets.only(bottom: 30),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                  colorList.length,
                  (i) => GestureDetector(
                    onTap: () {
                      setState(() {
                        colorIdx = i;
                      });
                    },
                    child: Container(
                        width: 45,
                        height: 45,
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 7, right: i == 19 ? 0 : 7),
                        child: colorIdx == i
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : Container(),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorList[i],
                        )),
                  ),
                ),
              ),
            ))
          ],
        ),
      );
    }), isDismissible: false, enterBottomSheetDuration: const Duration(milliseconds: 150));
  }

  void addBand(String s, Color c) {
    _myJediUserCtrl.updateMyJediUser(Update.createBand, [s, c]);
  }
}
