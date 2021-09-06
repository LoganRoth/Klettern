import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:klettern/models/user.dart';
import 'package:klettern/screens/splash_screen.dart';
import 'package:klettern/widgets/header.dart';
import 'package:klettern/widgets/progress.dart';
import 'package:klettern/widgets/show_alert.dart';

class CreateAccount extends StatefulWidget {
  final String uid;

  CreateAccount({this.uid});
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _usersRef = FirebaseFirestore.instance.collection('users');
  TextEditingController _usernameController;
  final _timestamp = DateTime.now();
  String _username;
  String _warning;
  bool _isCreated = false;
  bool _isCreating = false;

  @override
  void initState() {
    _usernameController = new TextEditingController(text: _username);
    super.initState();
  }

  void submit() async {
    final String nameUnderTest = _usernameController.text.trim();
    if (nameUnderTest.isEmpty || nameUnderTest.length < 3) {
      setState(() {
        _warning = 'Username is too short';
      });
      return;
    } else if (nameUnderTest.length > 20) {
      setState(() {
        _warning = 'Username is too long, max of 20 characters';
      });
      return;
    }

    bool isTaken = await UserData().isUsernameTaken(nameUnderTest);
    if (!isTaken) {
      _username = nameUnderTest;
      await createUserInFirebase();
      setState(() {
        _isCreated = true;
      });
    } else {
      setState(() {
        _warning = 'Username is taken';
      });
    }
  }

  Future<void> createUserInFirebase() async {
    final DocumentSnapshot doc = await _usersRef.doc(widget.uid).get();
    List<String> usernameSearch = [];
    String searchStr = '';
    for (int i = 0; i < _username.length; i++) {
      searchStr = searchStr + _username[i];
      usernameSearch.add(searchStr);
    }

    if (!doc.exists) {
      await _usersRef.doc(widget.uid).set({
        'id': widget.uid,
        'username': _username,
        'bio': '',
        'timestamp': _timestamp,
        'usernameSearch': usernameSearch,
        'photoURL': '',
      });
    }
  }

  void warningNullSetter() {
    setState(() {
      _warning = null;
    });
  }

  @override
  Widget build(BuildContext parentContext) {
    return _isCreated
        ? SplashScreen(
            uid: widget.uid,
          )
        : Scaffold(
            appBar: header(context, titleText: 'Set up your Profile'),
            body: ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      showAlert(context, _warning, warningNullSetter),
                      Padding(
                        padding: EdgeInsets.only(top: 25.0),
                        child: Text(
                          'Create a username',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Username',
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText:
                                  'Username must be at least 3 characters',
                            ),
                          ),
                        ),
                      ),
                      if (_isCreating) circularProgress(),
                      if (!_isCreating)
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
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.black),
                            ),
                            onPressed: submit,
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
