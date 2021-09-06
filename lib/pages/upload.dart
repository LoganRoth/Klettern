import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klettern/models/user.dart';
import 'package:klettern/widgets/progress.dart';
import 'package:klettern/widgets/show_alert.dart';
import 'package:klettern/widgets/temp_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Img;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final UserData currentUser;
  final Reference storage;
  final CollectionReference postRef;

  Upload({
    this.currentUser,
    this.storage,
    this.postRef,
  });
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController _tagsController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _captionController = TextEditingController();
  bool _videoUploadReady = false;
  bool _isLoading = false;
  String _warning;
  NewPost post;
  List<String> _tags;
  PickedFile _video;
  File _uploadFile;
  ImagePicker _picker = ImagePicker();
  String postId = Uuid().v4();

  @override
  void initState() {
    _tags = [];
    super.initState();
  }

  // Functions
  void handleTakePhoto() async {
    Navigator.of(context).pop();
    PickedFile file = await _picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      _video = file;
    });
  }

  void handlePhotoFromGallery() async {
    Navigator.of(context).pop();
    PickedFile file = await _picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      _video = file;
    });
  }

  void prepVideo() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          children: [
            SimpleDialogOption(
              child: Text('Take Photo With Camera'),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text('Choose From Photos'),
              onPressed: handlePhotoFromGallery,
            ),
            SimpleDialogOption(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // bool isReady = false;
    // setState(() {
    //   _isLoading = true;
    // });

    // // Get video ready
    // isReady = true;

    // _videoUploadReady = isReady;
    // setState(() {
    //   _isLoading = false;
    // });
  }

  void warningNullSetter() {
    setState(() {
      _warning = null;
    });
  }

  void removeVideo() {
    setState(() {
      _videoUploadReady = false;
    });
  }

  // Widgets
  Scaffold buildUploadScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('New Climb'),
        actions: [
          FlatButton(
              child: Text(
                'Post',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          showAlert(
            context,
            _warning,
            warningNullSetter,
          ),
          buildVideoUpload(),
          TextFormField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Caption',
              filled: true,
            ),
          ),
          TextFormField(
            maxLength: 25,
            controller: _tagsController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Tag',
              filled: true,
            ),
            onFieldSubmitted: (val) {
              if (val.isNotEmpty) {
                if (_tags.length < 10) {
                  _tagsController.clear();
                  _tags.add(val);
                  setState(() {});
                } else {
                  tempDialog(
                    context: context,
                    title: 'Tag Limit',
                    content: 'Only 10 tags can be added per climb',
                    button1: 'Ok',
                    oneButton: true,
                  );
                }
              }
            },
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            color: Theme.of(context).primaryColorDark,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.15,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 6 / 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 3,
              ),
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: GridTile(
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: AutoSizeText(_tags[i]),
                          )),
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _tags.removeAt(i);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              itemCount: _tags.length,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.05,
                child: RaisedButton.icon(
                  icon: Icon(Icons.location_on),
                  label: Text('Use Current Location'),
                  onPressed: () {},
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.05,
                child: RaisedButton.icon(
                  icon: Icon(Icons.map),
                  label: Text('Select Location on Map'),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              color: Colors.red,
              child: Center(
                child: Container(color: Colors.white, child: Text('Location')),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildVideoUpload() {
    return _videoUploadReady
        ? _isLoading
            ? Container(
                height: MediaQuery.of(context).size.width * 0.25,
                child: circularProgress(),
              )
            : Container(
                color: Colors.lightGreenAccent[400],
                height: MediaQuery.of(context).size.width * 0.25,
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Video ready to go!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      FlatButton.icon(
                        icon: Icon(Icons.clear),
                        label: Text(
                          'Remove',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          tempDialog(
                            context: context,
                            title: 'Remove Selected Video',
                            content:
                                'Are you sure you don\'t want to use this video?',
                            button1: 'Remove',
                            button1Action: removeVideo,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
        : Container(
            height: MediaQuery.of(context).size.width * 0.25,
            child: ListTile(
              leading: Icon(
                Icons.add_box_outlined,
                size: MediaQuery.of(context).size.width * 0.17,
              ),
              title: Center(
                  child: Text(
                'Upload a video of your climb!',
                style: TextStyle(
                  fontSize: 17.0,
                ),
              )),
              onTap: prepVideo,
            ),
          );
  }

  Future<void> compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Img.Image imgFile = Img.decodeImage(await _video.readAsBytes());
    final compressedImg = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(
        Img.encodeJpg(
          imgFile,
          quality: 85,
        ),
      );
    setState(() {
      _uploadFile = compressedImg;
    });
  }

  Future<String> uploadImage(File imageFile) async {
    final ref = widget.storage.child("post_$postId.jpg");
    final storageSnap = await ref.putFile(imageFile).whenComplete(() => null);
    String url = await storageSnap.ref.getDownloadURL();
    return url;
  }

  void createPostInFireStore({
    String mediaUrl,
    String location,
    String caption,
  }) {
    widget.postRef
        .doc(widget.currentUser.id)
        .collection('userPosts')
        .doc(postId)
        .set(
      {
        'postId': postId,
        'ownerId': widget.currentUser.id,
        'username': widget.currentUser.username,
        'mediaUrl': mediaUrl,
        'caption': caption,
        'location': location,
        'timestamp': DateTime.now(),
        'likes': {},
      },
    );
    _captionController.clear();
    _locationController.clear();
    setState(() {
      _uploadFile = null;
      _video = null;
      _isLoading = false;
      postId = Uuid().v4();
    });
  }

  void handleSubmit() async {
    setState(() {
      _isLoading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(_uploadFile);
    createPostInFireStore(
      mediaUrl: mediaUrl,
      location: _locationController.text,
      caption: _captionController.text,
    );
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _video = null;
            });
          },
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          FlatButton(
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            onPressed: _isLoading ? null : () => handleSubmit(),
          ),
        ],
      ),
      body: ListView(
        children: [
          _isLoading
              ? linearProgress()
              : SizedBox(
                  height: 0,
                ),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(
                        File(_video.path),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          ListTile(
            title: Container(
              width: MediaQuery.of(context).size.width * 0.78,
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: MediaQuery.of(context).size.width * 0.78,
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                'Use Current Location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              onPressed: getUserLocation,
            ),
          ),
        ],
      ),
    );
  }

  void getUserLocation() async {
    // This Does Not Work
    return;
    Position pos = await Geolocator().getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    List<Placemark> plcs = await Geolocator().placemarkFromPosition(pos);
    Placemark plc = plcs[0];
    String formatAddr = '${plc.locality}, ${plc.country}';
    _locationController.text = formatAddr;
  }

  @override
  Widget build(BuildContext context) {
    return _video == null ? buildUploadScreen() : buildUploadForm();
  }
}

class NewPost extends StatelessWidget {
  final String video;
  final String caption;
  final double lat;
  final double long;
  final List<String> tags;

  NewPost({
    this.video,
    this.caption,
    this.lat,
    this.long,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
