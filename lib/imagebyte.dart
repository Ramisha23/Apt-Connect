import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUpload extends StatefulWidget {
  const ImageUpload({super.key});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final CollectionReference reference = FirebaseFirestore.instance.collection('products');
  String imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image to DB"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter image description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (imageUrl.isNotEmpty)
              ImageFromNetwork(imageUrl: imageUrl),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                ImagePicker imagePicker = ImagePicker();
                XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                if (file != null) {
                  print('Selected image path: ${file.path}');

                  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
                  Reference referenceImageToUpload = FirebaseStorage.instance
                      .ref()
                      .child('images/$uniqueFileName');

                  try {
                    // Convert XFile to a blob or a file-like object supported in web
                    final blob = await file.readAsBytes();
                    final metadata = SettableMetadata(contentType: 'image/jpeg');

                    // Upload the blob and wait for the upload to complete
                    await referenceImageToUpload.putData(blob, metadata);

                    // After upload is complete, get and print the download URL
                    String downloadURL = await referenceImageToUpload.getDownloadURL();
                    print('Download URL: $downloadURL');

                    // Update the state to display the image or use the URL as needed
                    setState(() {
                      imageUrl = downloadURL;
                    });
                  } catch (e) {
                    print('Error uploading image: $e');
                  }
                } else {
                  print('No image selected.');
                }
              },
              child: Text("Upload Image"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("Register work");
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageFromNetwork extends StatefulWidget {
  final String imageUrl;

  ImageFromNetwork({required this.imageUrl});

  @override
  _ImageFromNetworkState createState() => _ImageFromNetworkState();
}

class _ImageFromNetworkState extends State<ImageFromNetwork> {
  late Future<Uint8List> _imageData;

  @override
  void initState() {
    super.initState();
    _imageData = fetchImage(widget.imageUrl);
  }

  Future<Uint8List> fetchImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return Image.memory(snapshot.data!);
        } else {
          return Center(child: Text('No image available'));
        }
      },
    );
  }
}
