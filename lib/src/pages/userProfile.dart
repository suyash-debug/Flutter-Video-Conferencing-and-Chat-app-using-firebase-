import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  TextEditingController _controllerNickname;
  TextEditingController _controllerAboutMe;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String displayName;
  bool isLoading = false;
  String nickname;
  String aboutMe;
  String currentUserId;
  bool onSubmitted = false;

  void _profilePhoto() {}

  void _updateData() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    Firestore.instance.collection('users').document(uid).updateData(
      {
        'nickname': nickname,
        'aboutMe': aboutMe,
      },
    );

    displayName = nickname;

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocal();
  }

  void getLocal() async {
    setState(() {
      isLoading = true;
    });
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((value) {
      print(value.data['nickname']);
      nickname = value.data['nickname'];
      aboutMe = value.data['aboutMe'];
      print(nickname);
      print(aboutMe);
    });
    currentUserId = user.uid;
    displayName = user.displayName;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: AppBar(
        title: Text('Your Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 36,
                    ),
                    GestureDetector(
                      onTap: _profilePhoto,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(
                                      'https://googleflutter.com/sample_image.jpg') ??
                                  CircularProgressIndicator(),
                              fit: BoxFit.fill),
                        ),
                      ),
                    ),
                    Text(
                      nickname ?? displayName,
                      style: TextStyle(color: Colors.purple),
                    ),
                    Text(
                      aboutMe ?? 'null',
                      style: TextStyle(color: Colors.purple),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: Form(
                          child: Column(
                            children: [
                              TextFormField(
                                // onFieldSubmitted: _updateData,
                                // autofocus: true,
                                controller: _controllerNickname,
                                onChanged: (value) {
                                  nickname = value;
                                },
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                ),
                                decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.edit),
                                  errorStyle: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  contentPadding: EdgeInsets.only(top: 14.0),
                                  hintText: 'Nickname....',
                                  hintStyle: TextStyle(
                                    color: Colors.purple,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  focusColor: Colors.green,
                                ),
                              ),
                              SizedBox(height: 30.0),
                              TextFormField(
                                // autofocus: true,
                                controller: _controllerAboutMe,
                                onChanged: (value) {
                                  aboutMe = value;
                                },
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                ),
                                decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.edit),
                                  errorStyle: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  contentPadding: EdgeInsets.only(top: 14.0),
                                  hintText: 'About Me...',
                                  hintStyle: TextStyle(
                                    color: Colors.green,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  focusColor: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    RaisedButton(
                      // color: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)),
                      clipBehavior: Clip.hardEdge,
                      onPressed: _updateData,
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[Colors.orange, Colors.redAccent],
                          ),
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: const Text('Update',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Flexible(
        child: Column(
          children: <Widget>[
            Container(
              child: Text(
                'Nickname: ${document['nickname']}',
                style: TextStyle(color: Colors.green),
              ),
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
            ),
            Container(
              child: Text(
                'About me: ${document['aboutMe'] ?? 'Not available'}',
                style: TextStyle(color: Colors.green),
              ),
            )
          ],
        ),
      );
    }
  }
}
