import 'dart:html' as html;
import 'dart:typed_data';

import 'package:aptconnect/Widget/FacultyDrawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InstagramProfilePage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  InstagramProfilePage(this.userDataMap);

  @override
  _InstagramProfilePageState createState() => _InstagramProfilePageState();
}

class _InstagramProfilePageState extends State<InstagramProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _profileImageUrl;
  late String _userName;
  String? _bio;
  String? _education;
  List<String>? _batches;
  int _postCount = 0;

  @override
  void initState() {
    super.initState();
    _userName = widget.userDataMap['name'] ?? 'Unknown';
    _bio = widget.userDataMap['bio'];
    _education = widget.userDataMap['education'];
    _batches = List<String>.from(widget.userDataMap['batches'] ?? []);
    _loadProfilePicture();
    _loadPosts();
  }

  Future<void> _loadProfilePicture() async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('Users')
          .doc(widget.userDataMap['userId'])
          .get();
      setState(() {
        _profileImageUrl = userDoc['profileImageUrl'];
      });
    } catch (e) {
      print('Error fetching profile picture: $e');
    }
  }

  Future<void> _loadPosts() async {
    try {
      QuerySnapshot postDocs = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: widget.userDataMap['userId'])
          .get();
      setState(() {
        _postCount = postDocs.size;
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  Future<void> _updateProfilePicture() async {
    try {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = false;
      input.click();

      input.onChange.listen((e) async {
        final files = input.files;
        if (files!.isEmpty) return;

        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]!);
        reader.onLoadEnd.listen((e) async {
          final Uint8List fileData = reader.result as Uint8List;

          final uploadTask = _storage
              .ref()
              .child('profile_pictures/${DateTime.now().millisecondsSinceEpoch}_${files[0]!.name}')
              .putData(fileData);

          try {
            final snapshot = await uploadTask.whenComplete(() => {});
            final downloadUrl = await snapshot.ref.getDownloadURL();

            await _firestore
                .collection('Users')
                .doc(widget.userDataMap['userId'])
                .update({'profileImageUrl': downloadUrl});

            setState(() {
              _profileImageUrl = downloadUrl;
            });
          } catch (e) {
            print('Error uploading profile picture: $e');
          }
        });
      });
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<void> _editProfile() async {
    final bioController = TextEditingController(text: _bio);
    final educationController = TextEditingController(text: _education);
    final batchesController = TextEditingController(text: _batches?.join(', '));

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bioController,
                decoration: InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              TextField(
                controller: educationController,
                decoration: InputDecoration(labelText: 'Education'),
              ),
              TextField(
                controller: batchesController,
                decoration: InputDecoration(labelText: 'Batches (comma-separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String bio = bioController.text.trim();
                String education = educationController.text.trim();
                List<String> batches = batchesController.text.trim().split(',').map((s) => s.trim()).toList();

                await _firestore.collection('Users').doc(widget.userDataMap['userId']).update({
                  'bio': bio,
                  'education': education,
                  'batches': batches,
                });

                setState(() {
                  _bio = bio;
                  _education = education;
                  _batches = batches;
                });

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _userName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: _editProfile,
          ),
        ],
      ),
                  drawer: CustomDrawer(userDataMap: widget.userDataMap),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: _updateProfilePicture,
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.deepPurple, // Default background color
                      backgroundImage: _profileImageUrl != null
                          ? CachedNetworkImageProvider(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null
                          ? Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : '',
                              style: TextStyle(
                                fontSize: 40.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Bio: ${_bio ?? 'No bio available'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Education: ${_education ?? 'No education info available'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Batches: ${_batches?.join(', ') ?? 'No batches available'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 32.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildStatsColumn(_postCount.toString(), 'Posts'),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Divider(height: 32.0),
            StreamBuilder(
              stream: _firestore
                  .collection('posts')
                  .where('userId', isEqualTo: widget.userDataMap['userId'])
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = snapshot.data!.docs[index];
                    final imageUrl = post['imageUrl']; 

                    return imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200.0,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              }
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Log error details
                              print('Error loading image: $error');
                              return Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 50.0,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50.0,
                            ),
                          );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsColumn(String count, String label) {
    return Column(
      children: <Widget>[
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
