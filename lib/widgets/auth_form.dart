import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.resetFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;
  final void Function(
    String email,
    BuildContext ctx,
  ) resetFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isInReset = false;
  var _userEmail = '';
  var _password = '';

  void _tryLogin() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _password.trim(),
        true,
        context,
      );
    }
  }

  void _trySignUp() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _password.trim(),
        false,
        context,
      );
    }
  }

  void _tryReset() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.resetFn(
        _userEmail.trim(),
        context,
      );
    }
    _isInReset = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                    ),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  if (!_isInReset)
                    TextFormField(
                      key: ValueKey('password'),
                      validator: (value) {
                        if (value.isEmpty || (value.length < 7)) {
                          return 'Password must be at least 7 characters';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      onSaved: (value) {
                        _password = value;
                      },
                    ),
                  SizedBox(
                    height: 12,
                  ),
                  if (widget.isLoading)
                    Center(child: CircularProgressIndicator()),
                  if (!widget.isLoading && !_isInReset)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          child: Text('Login'),
                          color: Colors.green[700],
                          onPressed: () {
                            _tryLogin();
                          },
                        ),
                        SizedBox(width: 60),
                        RaisedButton(
                          child: Text('Sign Up'),
                          onPressed: () {
                            _tryLogin();
                          },
                        ),
                      ],
                    ),
                  if (!widget.isLoading && _isInReset)
                    RaisedButton(
                      child: Text('Send Reset Email'),
                      color: Colors.green[700],
                      onPressed: () {
                        _tryReset();
                      },
                    ),
                  if (!widget.isLoading && !_isInReset)
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _isInReset = true;
                        });
                      },
                      child: Text('Forgot password?'),
                    ),
                  if (!widget.isLoading && _isInReset)
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _isInReset = false;
                        });
                      },
                      child: Text('Sign In'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
