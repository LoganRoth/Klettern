import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:klettern/screens/auth_screen.dart';
import 'package:klettern/screens/splash_screen.dart';
import 'package:klettern/widgets/progress.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Center(
              child: circularProgress(),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Klettern',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.green,
                accentColor: Colors.brown,
                buttonColor: Colors.green[700],
                highlightColor: Colors.black,
                disabledColor: Colors.grey),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  return SplashScreen(
                    uid: snapshot.data.uid,
                  );
                } else {
                  return AuthScreen();
                }
              },
            ),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Center(
            child: circularProgress(),
          ),
        );
      },
    );
  }
}
