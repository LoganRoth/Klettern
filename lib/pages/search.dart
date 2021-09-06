import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:klettern/models/user.dart';
import 'package:klettern/widgets/progress.dart';

class Search extends StatefulWidget {
  final UserData currentUser;

  Search({this.currentUser});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot> _searchResultsFuture;

  // Functions
  void handleSearch(String query) {
    if (query.isNotEmpty) {
      String lowerquery = query.toLowerCase();
      Future<QuerySnapshot> users = FirebaseFirestore.instance
          .collection('users')
          .where('usernameSearch', arrayContains: lowerquery)
          .get();
      setState(() {
        _searchResultsFuture = users;
      });
    } else {
      setState(() {
        _searchResultsFuture = null;
      });
    }
  }

  void clearSearch() {
    _searchController.clear();
  }

  // Widgets
  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        decoration: InputDecoration(
          hintText: 'Search for another climber',
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        controller: _searchController,
        onFieldSubmitted: handleSearch,
        onChanged: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height: 300.0,
            ),
            // TODO Add a picture of a mountain?
            Text(
              'TODO, move this...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder buildSearchResults() {
    return FutureBuilder(
      future: _searchResultsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<UserResult> results = [];
          QuerySnapshot docData = snapshot.data;
          docData.docs.forEach((doc) {
            UserData oneUser = UserData.fromDocument(doc);
            if (oneUser.username != widget.currentUser.username) {
              results.add(
                UserResult(
                  user: oneUser,
                ),
              );
            }
          });
          return ListView(
            children: results,
          );
        } else {
          return circularProgress();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: _searchResultsFuture == null
          ? buildNoContent()
          : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final UserData user;

  UserResult({
    this.user,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.person), // Change to be photoURL
            // backgroundColor: Colors.grey,
            // backgroundImage: CachedNetworkImageProvider(user.photoURL),
          ),
          title: Text(user.username),
          onTap: () => print('tapped'),
        ),
        Divider(
          color: Colors.black,
        ),
      ],
    );
  }
}
