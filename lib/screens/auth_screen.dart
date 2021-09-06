import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:klettern/screens/login_screen.dart';
import 'package:klettern/screens/register_with_email.dart';
import 'package:klettern/widgets/show_alert.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final usersRef = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;
  String _warning;

  // Functions
  Future<void> login() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(),
      ),
    );
  }

  Future<void> registerWithGoogle() async {
    final GoogleSignInAccount _googleSignInAccount =
        await _googleSignIn.signIn();
    if (_googleSignInAccount != null) {
      final GoogleSignInAuthentication _googleSignInAuthentication =
          await _googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: _googleSignInAuthentication.accessToken,
        idToken: _googleSignInAuthentication.idToken,
      );
      try {
        await _auth.signInWithCredential(credential);
      } catch (error) {
        setState(() {
          _warning = error.toString();
        });
      }
    }
  }

  Future<void> registerWithApple() async {
    // TODO
    setState(() {
      _warning = 'Register with Apple not implemented yet';
    });
  }

  Future<void> registerWithEmail() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterWithEmail(),
      ),
    );
  }

  void warningNullSetter() {
    setState(() {
      _warning = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              Container(
                height: MediaQuery.of(context).size.height * 0.10,
                child: Text(
                  'Klettern',
                  style: TextStyle(
                      fontFamily: "Signatra",
                      fontSize: 90.0,
                      color: Colors.white),
                ),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      (_warning != null ? 0.17 : 0.25)),
              showAlert(context, _warning, warningNullSetter),
              buildRegistration(),
            ],
          ),
        ),
      ),
    );
  }

  Card buildRegistration() {
    return Card(
      margin: EdgeInsets.all(0.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Already have an account?',
                style: TextStyle(fontSize: 15.0, color: Colors.black),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 40.0,
              child: FlatButton(
                color: Colors.green[800],
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.black,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50)),
                child: Text(
                  'Log In',
                  style: TextStyle(fontSize: 15.0, color: Colors.black),
                ),
                onPressed: login,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'New to Klettern? Sign up now!',
                style: TextStyle(fontSize: 15.0, color: Colors.black),
              ),
            ),
            // TODO Add Apple Sign In
            if (Platform.isIOS)
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 40.0,
                child: FlatButton.icon(
                  color: Colors.black,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.black,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  icon: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/apple_apple.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  label: Text(
                    'Continue with Apple',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: registerWithApple,
                ),
              ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 40.0,
              child: FlatButton.icon(
                color: Colors.grey[200],
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.black,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50)),
                icon: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/google_g.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                label: Text(
                  'Continue with Google',
                  style: TextStyle(fontSize: 15.0, color: Colors.black),
                ),
                onPressed: registerWithGoogle,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 40.0,
              child: FlatButton(
                color: Colors.grey[200],
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.black,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50)),
                onPressed: registerWithEmail,
                child: Text(
                  'Sign Up with Email',
                  style: TextStyle(fontSize: 15.0, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
