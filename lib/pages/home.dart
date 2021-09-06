import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:klettern/models/user.dart';
import 'package:klettern/pages/activity_feed.dart';
import 'package:klettern/pages/profile.dart';
import 'package:klettern/pages/search.dart';
import 'package:klettern/pages/timeline.dart';
import 'package:klettern/pages/upload.dart';

class Home extends StatefulWidget {
  final GoogleSignIn googleSignIn;
  final UserData currentUser;

  Home({this.googleSignIn, this.currentUser});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleSignIn _googleSignIn;
  UserData _currentUser;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance.ref();
  final _postsRef = FirebaseFirestore.instance.collection('posts');
  final _usersRef = FirebaseFirestore.instance.collection('users');
  PageController _pageController;
  int _pageIdx = 0;

  // State Functions
  @override
  void initState() {
    _pageController = PageController();
    _googleSignIn = widget.googleSignIn;
    _currentUser = widget.currentUser;

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Functions
  void logout() async {
    if ((_googleSignIn != null) && (_googleSignIn.currentUser != null)) {
      await _googleSignIn.signOut();
    }
    _auth.signOut();
  }

  void onPageChanged(int idx) {
    setState(() {
      _pageIdx = idx;
    });
  }

  void onTap(int idx) async {
    if (idx == 2) {
      await Navigator.of(context).push(_createRoute());
    } else {
      _pageController.jumpToPage(idx); //,
      // duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    }
  }

  // Widgets
  Scaffold buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: [
          Timeline(),
          Search(
              currentUser:
                  _currentUser), // -> this will be replaced with "Explore"
          Container(), //Upload Place Holder
          ActivityFeed(),
          Profile(
            logout: logout,
            currentUser: _currentUser,
            selUserId: _currentUser.id,
            usersRef: _usersRef,
          ),
        ],
        controller: _pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _pageIdx,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            activeIcon: Icon(Icons.whatshot_outlined),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            activeIcon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box_outlined,
              size: 35.0,
            ),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            activeIcon: Icon(Icons.notifications_active_outlined),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Upload(
        currentUser: _currentUser,
        storage: _storage,
        postRef: _postsRef,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = Offset(0.0, 1.0);
        final end = Offset.zero;
        final curve = Curves.ease;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHomeScreen();
  }
}
