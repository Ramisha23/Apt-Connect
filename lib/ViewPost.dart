import 'dart:typed_data';
import 'package:aptconnect/Widget/FacultyDrawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class PostViewPage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  PostViewPage(this.userDataMap);

  @override
  _PostViewPageState createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Posts',
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Color(0xFF694F8E), // Deep Purple
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts available.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postData = posts[index].data();
              final postId = posts[index].id;

              return PostWidget(
                postId: postId,
                title: postData['title'],
                username: postData['username'],
                description: postData['description'],
                imageUrl: postData['imageUrl'],
                likes: postData['likes'],
                comments: postData['comments'] ?? [],
                currentUsername: widget.userDataMap['name'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  final String postId;
  final String title;
  final String username;
  final String description;
  final String imageUrl;
  final int likes;
  final List<dynamic> comments;
  final String currentUsername;

  PostWidget({
    required this.postId,
    required this.title,
    required this.username,
    required this.description,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.currentUsername,
  });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  bool _areCommentsVisible = false;
  late FirebaseFirestore _firestore;
  final TextEditingController _commentController = TextEditingController();
  String? _profileImageUrl; // Nullable to avoid LateInitializationError

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _loadProfileImage(); // Load the profile image of the post creator
  }

  Future<void> _loadProfileImage() async {
    try {
      final userSnapshot = await _firestore.collection('users').doc(widget.username).get();
      final userData = userSnapshot.data();
      if (userData != null) {
        setState(() {
          _profileImageUrl = userData['profileImageUrl'] ?? ''; // Update with the profile image URL
        });
      }
    } catch (e) {
      print('Error fetching profile image for ${widget.username}: $e');
      setState(() {
        _profileImageUrl = ''; // Fallback if error occurs
      });
    }
  }

  void _toggleLike() async {
    try {
      setState(() {
        _isLiked = !_isLiked;
      });
      await _firestore.collection('posts').doc(widget.postId).update({
        'likes': FieldValue.increment(_isLiked ? 1 : -1),
      });
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  void _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      try {
        await _firestore.collection('posts').doc(widget.postId).update({
          'comments': FieldValue.arrayUnion([
            {
              'username': widget.currentUsername,
              'text': commentText,
              'timestamp': Timestamp.now(),
            }
          ]),
        });
        _commentController.clear();
        setState(() {});
      } catch (e) {
        print('Error adding comment: $e');
      }
    }
  }

  // Future<void> _downloadImage(String url) async {
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final bytes = response.bodyBytes;
  //       final blob = html.Blob([Uint8List.fromList(bytes)]);
  //       final blobUrl = html.Url.createObjectUrlFromBlob(blob);
  //       final anchor = html.AnchorElement(href: blobUrl)
  //         ..setAttribute('download', 'image_${DateTime.now().millisecondsSinceEpoch}.jpg')
  //         ..click();
  //       html.Url.revokeObjectUrl(blobUrl);
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image downloaded successfully')));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download image: ${response.reasonPhrase}')));
  //     }
  //   } catch (e) {
  //     print('Error downloading image: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download image: ${e.toString()}')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12.0),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.grey[300],
              backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                  ? NetworkImage(_profileImageUrl!)
                  : null,
              child: (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                  ? Text(
                      widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            title: Text(
              widget.username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(widget.title, style: TextStyle(color: Colors.grey[700])),
          
           
          
          ),
          if (widget.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1),
                        ),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Icon(Icons.error, color: Colors.red));
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.description, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.thumb_up_alt : Icons.thumb_up_off_alt,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                SizedBox(width: 4),
                Text(
                  '${widget.likes}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    _areCommentsVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _areCommentsVisible = !_areCommentsVisible;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_areCommentsVisible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.comments.map<Widget>((comment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16.0,
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            (comment['username'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment['username'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(comment['text'] ?? 'No text', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF694F8E),
                  ),
                  child: Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
