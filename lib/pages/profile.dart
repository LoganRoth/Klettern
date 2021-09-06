import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:klettern/models/user.dart';
import 'package:klettern/widgets/header.dart';
import 'package:klettern/widgets/progress.dart';

class Profile extends StatefulWidget {
  final Function logout;
  final CollectionReference usersRef;
  final UserData currentUser;
  final String selUserId;

  Profile({this.logout, this.currentUser, this.selUserId, this.usersRef});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isCurrentUser;

  @override
  void initState() {
    _isCurrentUser = widget.currentUser.id == widget.selUserId;
    super.initState();
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEditProfileButton() {
    return Text('Edit Profile');
  }

  Widget buildProfileHeader(UserData user) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.grey,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        buildCountColumn('posts', 0),
                        buildCountColumn('followers', 0),
                        buildCountColumn('following', 0),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildEditProfileButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              user.username,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 2.0),
            child: Text(
              user.bio,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileHeaderFuture() {
    return _isCurrentUser
        ? buildProfileHeader(widget.currentUser)
        : FutureBuilder(
            future: widget.usersRef.doc(widget.selUserId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              UserData selUser = UserData.fromDocument(snapshot.data);
              return buildProfileHeader(selUser);
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        isAppTitle: false,
        titleText: widget.currentUser.username,
      ),
      body: ListView(
        children: [
          buildProfileHeaderFuture(),
        ],
      ),
    );
  }
}
