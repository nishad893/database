import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAFWjgpmtrBVYAWCK-NIeTtNTN41bFPmJs",
          appId: "1:657814211473:android:98e85014c183a968aae830",
          messagingSenderId: "",
          projectId: "fir-sample-2846d",
          storageBucket: "fir-sample-2846d.appspot.com")
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TodoFbase(),
  ));
}

class TodoFbase extends StatefulWidget {
  const TodoFbase({super.key});

  @override
  State<TodoFbase> createState() => _TodoFbaseState();
}

class _TodoFbaseState extends State<TodoFbase> {
  late CollectionReference _userCollection;

  @override
  @override
  void initState() {
    // TODO: implement initState
    _userCollection = FirebaseFirestore.instance.collection("user");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User data"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: readUser(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final userId = user.id;
                  final userName = user["name"];
                  final userEmail = user["email"];
                  return ListTile(
                    title: Text("$userName"),
                    subtitle: Text("$userEmail"),
                    trailing: Wrap(
                      children: [
                        IconButton(
                            onPressed: () {
                              uname.text = userName;
                              uemail.text = userEmail;
                              editUserData(userId);
                            },
                            icon: Icon(Icons.edit)),
                        IconButton(
                            onPressed: () {
                              deleteUser(userId);
                            },
                            icon: Icon(CupertinoIcons.delete))
                      ],
                    ),
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 37,
        ),
        onPressed: () => createUser(),
        backgroundColor: Colors.purple,
      ),
    );
  }

  var cname = TextEditingController();
  var cemail = TextEditingController();

  void createUser() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add user"),
            content: Column(
              children: [
                TextField(
                  controller: cname,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Name"),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: cemail,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Email"),
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel")),
              OutlinedButton(
                  onPressed: () => addUsertoDB(cname.text, cemail.text),
                  child: Text("Create")),
            ],
          );
        });
  }

  var uname = TextEditingController();
  var uemail = TextEditingController();

  void editUserData(String userId) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: uname,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "Name"),
              ),
              TextField(
                controller: uemail,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "Email"),
              ),
              ElevatedButton(
                  onPressed: () {
                    updateUser(userId, uname.text, uemail.text);
                    uname.clear();
                    uemail.clear();
                  },
                  child: Text("Edit"))
            ],
          );
        });
  }

  Future<void> addUsertoDB(String name, String email) async {
    return _userCollection.add({"name": name, "email": email}).then((value) {
      print("user add succefully");
      cname.clear();
      cemail.clear();
      Navigator.of(context).pop();
    }).catchError((error) {
      print("Faled to add data");
    });
  }

  Stream<QuerySnapshot> readUser() {
    return _userCollection.snapshots();
  }

  void updateUser(String userId, String uname, String uemail) async {
    var updateValues = {"name": uname, "email": uemail};
    return _userCollection.doc(userId).update(updateValues).then((value) {
      Navigator.of(context).pop();
      print("User data updated successfully");
    }).catchError((error) {
      print("User data updation field");
    });
  }

  Future<void> deleteUser(var id) async {
    return _userCollection.doc(id).delete().then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Usr delete successfullu")));
    }).catchError((error) {
      print("User deletion failed");
    });
  }
}