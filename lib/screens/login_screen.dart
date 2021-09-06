import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:klettern/widgets/header.dart';
import 'package:klettern/widgets/progress.dart';
import 'package:klettern/widgets/show_alert.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final _auth = FirebaseAuth.instance;
  TextEditingController _emailController;
  TextEditingController _pwdController;
  bool _isLoggingIn = false;
  bool _isResetting = false;
  String _email;
  String _password;
  String _warning;

  @override
  void initState() {
    _emailController = new TextEditingController(text: _email);
    _pwdController = new TextEditingController(text: _password);
    super.initState();
  }

  void submit() async {
    final email = _emailController.text;
    final pwd = _pwdController.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _warning = 'Invalid email';
      });
      return;
    }
    if (pwd.isEmpty) {
      setState(() {
        _warning = 'No password';
      });
      return;
    }
    if (pwd.length < 8) {
      setState(() {
        _warning = 'Password must be at least 8 characters';
      });
      return;
    }
    _email = email;
    _password = pwd;
    try {
      setState(() {
        _isLoggingIn = true;
      });

      await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        _isLoggingIn = false;
        _warning = error.toString();
      });
    }
  }

  Future<void> loginWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        await _auth.signInWithCredential(credential);
        Navigator.pop(context);
      } catch (error) {
        setState(() {
          _warning = error.toString();
        });
      }
    }
  }

  Future<void> loginWithApple() async {
    // TODO
    setState(() {
      _warning = 'Register with Apple not implemented yet';
    });
  }

  void showPopUp(String resetEmail) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => Platform.isIOS
          ? CupertinoAlertDialog(
              title: Text('Password Reset'),
              content: Text(
                  'This will send you an email with instructions to reset your password'),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Ok'),
                  onPressed: () async {
                    setState(() {
                      _isResetting = true;
                    });
                    Navigator.of(ctx).pop();
                    try {
                      await _auth.sendPasswordResetEmail(email: resetEmail);
                    } catch (err) {
                      var msg = 'An error occurred, please check your email';
                      if (err.message != null) {
                        msg = err.message;
                      }
                      _warning = msg;
                    }
                    setState(() {
                      _isResetting = false;
                    });
                  },
                ),
              ],
            )
          : AlertDialog(
              title: Text('Password Reset'),
              content: Text(
                  'This will send you an email with instructions to reset your password'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Cancel'),
                ),
                FlatButton(
                  onPressed: () async {
                    setState(() {
                      _isResetting = true;
                    });
                    Navigator.of(ctx).pop();
                    try {
                      await _auth.sendPasswordResetEmail(email: resetEmail);
                    } catch (err) {
                      var msg = 'An error occurred, please check your email';
                      if (err.message != null) {
                        msg = err.message;
                      }
                      _warning = msg;
                    }
                    setState(() {
                      _isResetting = false;
                    });
                  },
                  child: Text('Ok'),
                ),
              ],
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
      appBar: header(
        context,
        isAppTitle: true,
        actions: [
          FlatButton(
            onPressed: submit,
            child: _isLoggingIn
                ? circularProgress()
                : Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
          )
        ],
      ),
      body: ListView(
        children: [
          Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  showAlert(context, _warning, warningNullSetter),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
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
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white),
                                  ),
                                  onPressed: loginWithApple,
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
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.black),
                                ),
                                onPressed: loginWithGoogle,
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              controller: _emailController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                                labelStyle: TextStyle(fontSize: 15.0),
                                hintText: 'Enter a valid email address',
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            TextField(
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              controller: _pwdController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password',
                                labelStyle: TextStyle(fontSize: 15.0),
                                hintText:
                                    'Password must be at least 8 characters',
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  FlatButton(
                                    onPressed: () async {
                                      final resetEmail = _emailController.text;
                                      if (resetEmail.isEmpty) {
                                        setState(() {
                                          _warning =
                                              'Please enter a valid email address to reset your password';
                                        });
                                      } else {
                                        showPopUp(resetEmail);
                                      }
                                    },
                                    child: Text('Forgot password?'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isResetting)
                    Center(
                      child: circularProgress(),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
