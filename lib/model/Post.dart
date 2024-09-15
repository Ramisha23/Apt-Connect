import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String username;
  final String imageUrl;
  final String description;
  final int likes;
  final List<Map<String, dynamic>> comments; // Updated type to handle map data
  final Timestamp timestamp;

  Post({
    required this.id,
    required this.title,
    required this.username,
    required this.imageUrl,
    required this.description,
    required this.likes,
    required this.comments,
    required this.timestamp,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      username: data['username'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      likes: data['likes'] ?? 0,
      comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
