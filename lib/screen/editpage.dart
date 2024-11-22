import 'package:dimo/data/db.dart';
import 'package:dimo/data/memo.dart';
import 'package:flutter/material.dart';

class Editpage extends StatefulWidget {
  String name = "";

  var pin;

  Editpage({super.key, required this.name, required this.pin});

  @override
  State<Editpage> createState() => _EditpageState(name);
}

class _EditpageState extends State<Editpage> {
  int? id;
  String name = "";
  String content = "";
  DbHelper dbh = DbHelper();
  Future? editFuture;
  var pinContacts;
  bool? isAlready;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    editFuture = readamemo();
    isAlready = widget.pin.contains(name);
  }

  _EditpageState(String name) {
    this.name = name;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "      $name 메모",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isAlready = !isAlready!;
                });
              },
              icon: Icon(
                isAlready! ? Icons.star : Icons.star_border,
                color: isAlready! ? Colors.yellow : Colors.black,
                size: 35,
              ),
            ),
            IconButton(
                onPressed: () {
                  if (isAlready!)
                    widget.pin.contains(name) ? {} : widget.pin.add(name);
                  else
                    widget.pin.contains(name) ? widget.pin.remove(name) : {};
                  Navigator.pop(context, widget.pin);
                },
                icon: const Icon(
                  Icons.dangerous_outlined,
                  size: 35,
                  color: Colors.black,
                )),
            IconButton(
              onPressed: () {
                updateamemo();
                if (isAlready!)
                  widget.pin.contains(name) ? {} : widget.pin.add(name);
                else
                  widget.pin.contains(name) ? widget.pin.remove(name) : {};
                Navigator.pop(context, widget.pin);
              },
              icon: const Icon(
                Icons.save,
                size: 35,
                color: Colors.black,
              ),
            )
          ],
        ),
        body: FutureBuilder(
            future: editFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  print("snapshot null");
                  return TextFormField(
                    decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.edit_note, size: 30, color: Colors.blue),
                        border: InputBorder.none),
                    initialValue: "",
                    maxLines: null,
                    onChanged: (c) {
                      content = c;
                    },
                  );
                } else {
                  id = snapshot.data![0].id;
                  return TextFormField(
                    style: TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.edit,
                        size: 27,
                        color: Colors.blue,
                      ),
                      border: InputBorder.none,
                      hintText: "기억은 디모가 할게요\n 당신은 중요한 일에 더욱 집중해보세요!",
                    ),
                    initialValue: "${snapshot.data![0].content}",
                    maxLines: null,
                    onChanged: (c) {
                      content = c;
                    },
                  );
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                print("snapshot error");
                return Icon(Icons.error);
              }
            }),
      ),
    );
  }

  Future<List<Memo>> readamemo() async {
    var li = await dbh.readMemo(name);
    print(li);
    return li;
  }

  Future updateamemo() async {
    await dbh.updateMemo(Memo(id: id, name: name, content: content));
  }

  Future insertamemo() async {
    await dbh.insertMemo(Memo(id: id, name: name, content: content));
  }
}
