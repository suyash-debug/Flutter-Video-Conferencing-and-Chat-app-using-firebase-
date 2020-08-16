import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edits/src/pages/chatRoom.dart';
import 'package:edits/src/utils/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool haveUserSearched = false;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot searchResultSnapshot;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot document;
  String peervatar;

  searchUser() {
    _scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
      return new Container(
        decoration: new BoxDecoration(color: Colors.blueGrey),
        child: new Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 50.0, 32.0, 32.0),
          child: new TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Search Your Friends',
            ),
            onSubmitted: _onSubmit,
          ),
        ),
      );
    });
  }

  _onSubmit(String s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id;
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    // id = prefs.getString('id');
    print(uid.hashCode);
    print('above is the id of the ');
    if (_textEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await databaseMethods
          .searchByName(_textEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          haveUserSearched = true;
          print('test');
        });
      });
    }
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.documents.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.documents[index].data["nickname"],
                searchResultSnapshot.documents[index].data["id"],
                index,
              );
            })
        : Container();
  }

  Widget userTile(String userName, String userEmail, index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                userEmail,
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () async {
              String peerId = searchResultSnapshot.documents[index].documentID,
                  peerAvtaar =
                      searchResultSnapshot.documents[index]['photoUrl'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chat(
                    peerId: peerId,
                    peerAvatar: peerAvtaar,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(24)),
              child: Text(
                "Message",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xffff9933),
      floatingActionButton: FloatingActionButton(
        onPressed: searchUser,
        child: Icon(
          Icons.search,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
              child: Column(
                children: [
                  userList(),
                ],
              ),
            ),
    );
  }
}
