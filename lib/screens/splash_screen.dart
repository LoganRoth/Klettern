import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:klettern/models/user.dart';
import 'package:klettern/pages/create_account.dart';
import 'package:klettern/pages/home.dart';

class SplashScreen extends StatefulWidget {
  final String uid;

  SplashScreen({this.uid});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          FirebaseFirestore.instance.collection('users').doc(widget.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot docData = snapshot.data;
          final userProvs = _auth.currentUser.providerData;
          bool googleUser = false;
          bool appleUser = false;
          userProvs.forEach((provider) {
            if (provider.providerId == 'google.com') {
              googleUser = true;
            } else if (provider.providerId == 'apple.com') {
              appleUser = true;
            }
          });
          if (googleUser) {
            return FutureBuilder(
              future: _googleSignIn.signInSilently(suppressErrors: false),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (docData.exists) {
                    UserData currentUser = UserData.fromDocument(docData);
                    return Home(
                      currentUser: currentUser,
                      googleSignIn: _googleSignIn,
                    );
                  } else {
                    return CreateAccount(
                      uid: widget.uid,
                    );
                  }
                } else {
                  return buildSpash();
                }
              },
            );
          } else if (appleUser) {
            return FutureBuilder(
              // TODO replace with Apple
              future: _googleSignIn.signInSilently(suppressErrors: false),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (docData.exists) {
                    UserData currentUser = UserData.fromDocument(docData);
                    return Home(
                      currentUser: currentUser,
                      googleSignIn: _googleSignIn,
                    );
                  } else {
                    return CreateAccount(
                      uid: widget.uid,
                    );
                  }
                } else {
                  return buildSpash();
                }
              },
            );
          } else {
            if (docData.exists) {
              UserData currentUser = UserData.fromDocument(docData);
              return Home(
                currentUser: currentUser,
              );
            } else {
              return CreateAccount(
                uid: widget.uid,
              );
            }
          }
        } else {
          return buildSpash();
        }
      },
    );
  }

  Scaffold buildSpash() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColorDark,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        child: Center(
          child: Text(
            'Klettern',
            style: TextStyle(
                fontFamily: "Signatra", fontSize: 90.0, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
