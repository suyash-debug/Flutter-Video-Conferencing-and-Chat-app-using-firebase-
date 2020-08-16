import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edits/src/models/Users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences prefs;
  FirebaseUser currentUser;

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(userid: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signUpWithEmailAndPassword(
      String email, String password, String nickname) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser firebaseUser = result.user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: firebaseUser.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if (documents.length == 0) {
          // Update data to server if new user
          Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .setData(
            {
              'nickname': nickname,
              'photoUrl': null,
              'id': firebaseUser.uid,
              'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
              'chattingWith': null,
              'aboutMe': null
            },
          );
          // Write data to local
          currentUser = firebaseUser;
          await prefs.setString('id', currentUser.uid);
          await prefs.setString('nickname', currentUser.displayName);
          await prefs.setString('photoUrl', currentUser.photoUrl);
          print(prefs.getString('id'));
          print('this ismy name');
        } else {
          // Write data to local
          await prefs.setString('id', documents[0]['id']);
          await prefs.setString('nickname', documents[0]['nickname']);
          await prefs.setString('photoUrl', documents[0]['photoUrl']);
          await prefs.setString('aboutMe', documents[0]['aboutMe']);
        }
        await prefs.setString('id', documents[0]['id']);
      }

      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("error logging out");
    }
  }

  Future<String> loginWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn();
      if (account == null) return null;
      AuthResult res =
          await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: (await account.authentication).idToken,
        accessToken: (await account.authentication).accessToken,
      ));
      FirebaseUser firebaseUser = res.user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: firebaseUser.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if (documents.length == 0) {
          // Update data to server if new user
          Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .setData(
            {
              'nickname': firebaseUser.displayName,
              'photoUrl': firebaseUser.photoUrl,
              'id': firebaseUser.uid,
              'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
              'chattingWith': null,
              'aboutMe': null
            },
          );
          // Write data to local
          currentUser = firebaseUser;
          await prefs.setString('id', currentUser.uid);
          await prefs.setString('nickname', currentUser.displayName);
          await prefs.setString('photoUrl', currentUser.photoUrl);
          print(prefs.getString('id'));
          print('this ismy name');
        } else {
          // Write data to local
          await prefs.setString('id', documents[0]['id']);
          await prefs.setString('nickname', documents[0]['nickname']);
          await prefs.setString('photoUrl', documents[0]['photoUrl']);
          await prefs.setString('aboutMe', documents[0]['aboutMe']);
        }
        await prefs.setString('id', documents[0]['id']);
      }
      String id = prefs.getString('id');
      return id;
    } catch (e) {
      print(e.message);
      print("Error logging with google");
      return null;
    }
  }
}
