import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:aptconnect/Widget/FacultyDrawer.dart';
class AddPostPage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  const AddPostPage(this.userDataMap, {Key? key}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _imageUrl = '';
  bool _isUploading = false;
  late final String _userId;
  late final String _username;

  @override
  void initState() {
    super.initState();
    _userId = widget.userDataMap['userId'] ?? 'unknown';
    _username = widget.userDataMap['name'] ?? 'anonymous';
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) {
          print('No image selected.');
          return;
        }

        final file = files[0];
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);

        reader.onLoadEnd.listen((e) async {
          String uniqueFileName =
              DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('images/$uniqueFileName.jpg');

          try {
            final Uint8List bytes = reader.result as Uint8List;
            final blob = html.Blob([bytes]);
            final uploadTask = storageReference.putBlob(blob);

            uploadTask.snapshotEvents.listen((event) async {
              switch (event.state) {
                case TaskState.success:
                  try {
                    String downloadURL =
                        await storageReference.getDownloadURL();
                            await Future.delayed(Duration(seconds: 2));

                    setState(() {
                      _imageUrl = downloadURL;
                      _isUploading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Image uploaded successfully.')),
                    );
                  } catch (e) {
                    print('Error getting download URL: $e');
                    setState(() {
                      _isUploading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to get image URL.')),
                    );
                  }
                  break;
                case TaskState.error:
                  print('Upload failed with error.');
                  setState(() {
                    _isUploading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to upload image.')),
                  );
                  break;
                default:
                  break;
              }
            }).onError((error) {
              print('Upload failed with error: $error');
              setState(() {
                _isUploading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to upload image.')),
              );
            });
          } catch (e) {
            print('Error during upload: $e');
            setState(() {
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image.')),
            );
          }
        });
      });
    } else {
      ImagePicker imagePicker = ImagePicker();
      XFile? imageFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (imageFile != null) {
        setState(() {
          _isUploading = true;
        });

        String uniqueFileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('images/$uniqueFileName.jpg');

        try {
          final File file = File(imageFile.path);
          final uploadTask = storageReference.putFile(file);

          uploadTask.snapshotEvents.listen((event) async {
            switch (event.state) {
              case TaskState.success:
                try {
                  String downloadURL = await storageReference.getDownloadURL();
                  setState(() {
                    _imageUrl = downloadURL;
                    _isUploading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Image uploaded successfully.')),
                  );
                } catch (e) {
                  print('Error getting download URL: $e');
                  setState(() {
                    _isUploading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to get image URL.')),
                  );
                }
                break;
              case TaskState.error:
                print('Upload failed with error.');
                setState(() {
                  _isUploading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to upload image.')),
                );
                break;
              default:
                break;
            }
          }).onError((error) {
            print('Upload failed with error: $error');
            setState(() {
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image.')),
            );
          });
        } catch (e) {
          print('Error during upload: $e');
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image.')),
          );
        }
      } else {
        print('No image selected.');
      }
    }
  }

  Future<void> _submitPost() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty && _imageUrl.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('posts').add({
          'imageUrl': _imageUrl,
          'title': title,
          'description': description,
          'timestamp': Timestamp.now(),
          'userId': _userId,
          'username': _username,
          'likes': 0,
          'comments': [],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post uploaded successfully.')),
        );

        _clearForm();
      } catch (e) {
        print('Error adding post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add post.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and upload an image.')),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _imageUrl = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Create a Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: Text(
              'Post',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        backgroundColor: Color(0xFF694F8E), // Deep purple
        elevation: 1,
      ),
            drawer: CustomDrawer(userDataMap: widget.userDataMap),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // White container background
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Add a title...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Divider(color: Colors.grey),
              // Description input
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Add a description...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(fontSize: 16, color: Colors.black),
                maxLines: null,
              ),
              Divider(color: Colors.grey),
              SizedBox(height: 10.0),
              // Image upload section
              _imageUrl.isNotEmpty
                  ? Image.network(
                      _imageUrl,
                      height: 200,
                      fit: BoxFit.cover, 
                      errorBuilder: (context, error, stackTrace) {
                       print('Error loading image: ${error.toString()}');
                  print('Stack trace: ${stackTrace.toString()}');

                        return Center(child: Text('Failed to load image'));
                      },
                      loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
              
                    )
                  : GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[200],
                        child: Center(
                          child: _isUploading
                              ? CircularProgressIndicator()
                              : Text('Tap to add an image',
                                  style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
              SizedBox(height: 20.0),
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF694F8E), // Deep purple
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Post',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
