import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String _bio;
  String _username;
  String _originalBio;
  String _originalUsername;
  bool _dirtyBio;
  bool _dirtyUsername;
  String photoURL;
  final String id;

  UserData({
    this.id,
  });

  factory UserData.fromDocument(DocumentSnapshot doc) {
    UserData thisUser = UserData(
      id: doc.id,
    );
    thisUser._originalUsername = doc['username'];
    thisUser._originalBio = doc['bio'];
    thisUser._dirtyBio = false;
    thisUser._dirtyUsername = false;
    thisUser._username = doc['username'];
    thisUser._bio = doc['bio'];
    thisUser.photoURL = doc['photoURL'];
    return thisUser;
  }

  String get bio => _bio;

  set bio(String newBio) {
    if (newBio != _originalBio) {
      _dirtyBio = true;
      _bio = newBio;
    } else {
      _dirtyBio = false;
    }
  }

  String get username => _username;

  Future<String> checkAndUpdateLocalUsername(String newUsername) async {
    String updated = '';
    if (newUsername != _originalUsername) {
      bool taken = await isUsernameTaken(newUsername);
      if (!taken) {
        _dirtyUsername = true;
        updated = '';
        _username = newUsername;
      } else {
        updated = 'Username is taken';
      }
    } else {
      updated = 'Username is same as server username';
      _dirtyUsername = false;
    }
    return updated;
  }

  bool isDirty() {
    return _dirtyBio || _dirtyUsername;
  }

  Future<bool> isUsernameTaken(String newUsername) async {
    bool isTaken = false;
    try {
      final QuerySnapshot name = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: newUsername)
          .get();
      if (name.size > 0) {
        isTaken = true;
      }
    } catch (error) {
      isTaken = true;
    }
    return isTaken;
  }

  Future<bool> updateUserData() async {
    if (isDirty()) {
      bool isSuccess = true;
      try {
        await FirebaseFirestore.instance.collection('users').doc(id).set(
          {
            'username': _username,
            'bio': _bio,
          },
          SetOptions(
            merge: true,
          ),
        );
      } catch (error) {
        isSuccess = false;
      }
      return isSuccess;
    }
    return true;
  }
}
