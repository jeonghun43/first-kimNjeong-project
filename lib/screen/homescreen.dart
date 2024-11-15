import 'package:dimo/screen/contactadd.dart';
import 'package:dimo/screen/editpage.dart';
import 'package:dimo/data/db.dart';
import 'package:dimo/data/memo.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DbHelper dbh = DbHelper();
  var _contacts;
  int count = 3;
  int size = 0;
  Future? myFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFuture = readContactsFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Icon(Icons.sticky_note_2_outlined, color: Colors.blue),
          title: const Text(
            "Dimo",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                  horizontal: screenWidth * 0.03),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.lightBlueAccent,
                ),
                height: screenHeight * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.emoji_emotions_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "디모\n",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              "기억은 디모가 할게요",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "여러분은 다른 일에 집중하세요",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  // onPressed: () async {
                  //   final prefs = await SharedPreferences.getInstance();
                  //   prefs.setBool("onboarding", false);
                  // },
                  onPressed: () {
                    Fluttertoast.showToast(msg: "기능이 추가될 예정입니다");
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            Column(
              children: [
                FutureBuilder(
                    future: myFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == null) {
                          return Text(
                              "Error Code[5000] : data null \n 에러 발생 개발자에게 문의 부탁드립니다");
                        } else {
                          return SizedBox(
                            height: screenHeight * 0.55,
                            child: GridView.builder(
                                itemCount: snapshot.data!.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 50,
                                          ),
                                          Text(snapshot.data![index].name),
                                        ],
                                      ),
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Editpage(
                                          name: snapshot.data![index].name,
                                        ),
                                      ),
                                    ),
                                    onLongPress: () => showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              content: Text("삭제하시겠습니까?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text("취소")),
                                                TextButton(
                                                    onPressed: () {
                                                      deleteOne(
                                                          snapshot.data![index]
                                                              .name,
                                                          index);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("확인"))
                                              ],
                                            )),
                                  );
                                }),
                          );
                        }
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting)
                        return CircularProgressIndicator();
                      else {
                        return Text("Error Code[5001] : 에러발생 개발자에게 문의부탁드립니다");
                      }
                    }),

                //개발용 버튼
                ///*
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     IconButton(
                //         onPressed: () => deletealldata(),
                //         icon: Icon(Icons.restore_from_trash)),
                //     IconButton(
                //         onPressed: () => checkDatabase(),
                //         icon: Icon(Icons.check)),
                //   ],
                // ),
                //*/
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            fixedSize:
                                Size(screenWidth * 0.35, screenHeight * 0.07),
                            backgroundColor: Colors.yellow),
                        onPressed: () async {
                          final data = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContactAdd(),
                            ),
                          );
                          if (data != null) {
                            bool b = false;
                            List<Memo> memosFromDatabase =
                                await dbh.readMemos();
                            memosFromDatabase
                                    .map((value) => value.name)
                                    .contains(data.displayName)
                                ? print("이미존재")
                                : b = true;

                            if (b) {
                              await dbh.insertMemo(
                                  Memo(name: data.displayName, content: ""));
                              print("${data.displayName}추가함");
                            }
                            setState(() {
                              myFuture = readContactsFromDatabase();
                            });
                          }
                        },
                        child: Text(
                          "연락처 가져오기",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.w900),
                        )),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkDatabase() async {
    print(await dbh.readMemos());
  }

  Future<List<Memo>> readContactsFromDatabase() async {
    List<Memo> memosFromDatabase = await dbh.readMemos();
    return memosFromDatabase;
  }

  Future getPermission() async {
    var status = await Permission.contacts.status; //연락처 접근 가능 여부 status에 담아주기

    if (status.isGranted) {
      // 접근 가능하다면 "허락됨" 출력
      print("허락됨");
    } else if (status.isDenied) {
      //그렇지 않다면 "거부됨"출력하고 권한 요청
      print("거부됨");
      await Permission.contacts.request();
    }

    if (status.isPermanentlyDenied) {
      //앱 설정에서 꺼놓은경우 요청
      openAppSettings();
    }

    List<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      _contacts = contacts;
      count = _contacts.length;
    });
  }

  Future deletealldata() async {
    await dbh.deleteAllMemo();
    setState(() {
      myFuture = readContactsFromDatabase();
    });
  }

  Future deleteOne(String name, int index) async {
    await dbh.deleteOneMemo(name);
    setState(() {
      myFuture = readContactsFromDatabase();
    });
  }
}