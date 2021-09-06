import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:klettern/widgets/header.dart';
import 'package:klettern/widgets/progress.dart';
import 'package:klettern/widgets/show_alert.dart';

class RegisterWithEmail extends StatefulWidget {
  @override
  _RegisterWithEmailState createState() => _RegisterWithEmailState();
}

class _RegisterWithEmailState extends State<RegisterWithEmail> {
  TextEditingController _emailController;
  TextEditingController _pwdController;
  final _auth = FirebaseAuth.instance;
  bool _isRegistering = false;
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
    final email = _emailController.text.trim();
    final pwd = _pwdController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _warning = 'Email is not in a valid format';
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
        _isRegistering = true;
      });
      await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        _isRegistering = false;
        _warning = error.toString();
      });
    }
  }

  void warningNullSetter() {
    setState(() {
      _warning = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Sign Up with Email'),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isRegistering) circularProgress(),
                  if (!_isRegistering)
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
                          style: TextStyle(fontSize: 15.0, color: Colors.black),
                        ),
                        onPressed: submit,
                      ),
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
