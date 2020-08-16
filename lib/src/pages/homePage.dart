import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edits/src/pages/chat.dart';
import 'package:edits/src/pages/index.dart';
import 'package:edits/src/pages/allUsers.dart';
import 'package:edits/src/pages/userProfile.dart';
import 'package:edits/src/utils/database.dart';
import 'package:edits/src/utils/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool showFab = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool haveUserSearched = false;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot searchResultSnapshot;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, initialIndex: 1, length: 3);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        showFab = true;
      } else {
        showFab = false;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text(
            "stayConnected",
            style: TextStyle(color: Colors.white70),
          ),
          elevation: 0.7,
          leading: IconButton(
            icon: Icon(
              Icons.account_circle,
              color: Colors.white70,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfile(),
                ),
              );
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white70,
            tabs: <Widget>[
              Tab(
                // text: "Video Call",
                icon: Icon(
                  Icons.video_call,
                  color: Colors.white70,
                ),
              ),
              Tab(
                // text: "Friends",
                icon: Icon(
                  Icons.chat,
                  color: Colors.white70,
                ),
              ),
              Tab(
                // text: "Logs",
                icon: Icon(
                  Icons.compare_arrows,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white70,
              ),
              onPressed: () {
                // SearchUser();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
            ),
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white70,
              ),
              onPressed: () {
                AuthProvider().logOut();
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            IndexPage(),
            ChatPage(),
            AllUsers(),
          ],
        ),
      ),
    );
  }
}
