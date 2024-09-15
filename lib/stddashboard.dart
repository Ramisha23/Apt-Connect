import 'package:aptconnect/HelpRequestPage.dart';
import 'package:aptconnect/MyQuizResult.dart';
import 'package:aptconnect/StudentHelp.dart';
import 'package:aptconnect/ViewWorkshops.dart';
import 'package:aptconnect/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aptconnect/QuizList.dart';
import 'package:aptconnect/ViewPost.dart';
import 'package:aptconnect/profile.dart';
import 'package:aptconnect/UpdateProfile.dart';

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  StudentDashboard(this.userDataMap);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_selectedIndex) {
      case 1:
        body = QuizListPage(userDataMap: widget.userDataMap);
        break;
      case 2:
        body = PostViewPage(widget.userDataMap);
        break;
      case 3:
        body = ProfileDetailPage(widget.userDataMap);
        break;
      default:
        body = AnnouncementsFeed(userDataMap: widget.userDataMap);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF694F8E), // Deep Purple
     
      ),
      body: body,
    drawer: Drawer(
  child: Column(
    children: <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(
          color: Color(0xFF694F8E), // Deep Purple
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'AptConnect',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      ListTile(
        leading: Icon(Icons.dashboard, color: Color(0xFF694F8E)), // Dashboard
        title: Text('Dashboard'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.quiz, color: Color(0xFF694F8E)), // Quiz
        title: Text('Quiz'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuizListPage(userDataMap: widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.article, color: Color(0xFF694F8E)), // Posts
        title: Text('Posts'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostViewPage(widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.person, color: Color(0xFF694F8E)), // Profile
        title: Text('Profile'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileDetailPage(widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.work, color: Color(0xFF694F8E)), // Workshop
        title: Text('Workshop'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkshopList(widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.show_chart, color: Color(0xFF694F8E)), // My Progress
        title: Text('My Progress'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyQuizResultPage(widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.help, color: Color(0xFF694F8E)), // Get Help
        title: Text('Get Help'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelpRequestPage(userDataMap: widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.support, color: Color(0xFF694F8E)), // Help Requests
        title: Text('Help Requests'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentHelpRequestsPage(userDataMap: widget.userDataMap)),
          );
        },
      ),
      Spacer(),
      ListTile(
        leading: Icon(Icons.exit_to_app, color: Color(0xFFE3A5C7)), // Soft Pink
        title: Text('Logout', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.pop(context); // Close the drawer
          _logout(context); // Call the logout method with the current context
        },
      ),
    ],
  ),
),
bottomNavigationBar: BottomNavigationBar(
  items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard), // Feed
      label: 'Feed',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.quiz), // Quiz
      label: 'Quiz',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.article), // Posts
      label: 'Posts',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person), // Profile
      label: 'Profile',
    ),
  ],
  currentIndex: _selectedIndex,
  selectedItemColor: Color(0xFF694F8E), // Deep Purple
  unselectedItemColor: Colors.grey,
  onTap: _onItemTapped,
),

    );
  }
}

class AnnouncementsFeed extends StatelessWidget {
  final Map<String, dynamic> userDataMap;

  AnnouncementsFeed({required this.userDataMap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('announcements').orderBy('timestamp', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No announcements available.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            var announcement = snapshot.data!.docs[index];

            return PostWidget(
              userDataMap: userDataMap,
              announcementId: announcement.id,
              username: announcement['username'] ?? '',
              caption: announcement['announcement'] ?? '',
              likes: announcement['likes'] ?? 0,
              comments: (announcement['comments'] ?? []) as List<dynamic>,
            );
          },
        );
      },
    );
  }
}

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> userDataMap;
  final String announcementId;
  final String username;
  final String caption;
  final int likes;
  final List<dynamic> comments;

  PostWidget({
    required this.userDataMap,
    required this.announcementId,
    required this.username,
    required this.caption,
    required this.likes,
    required this.comments,
  });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  bool _showComments = false;
  TextEditingController _commentController = TextEditingController();

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        FirebaseFirestore.instance.collection('announcements').doc(widget.announcementId).update({
          'likes': FieldValue.increment(1),
        });
      } else {
        FirebaseFirestore.instance.collection('announcements').doc(widget.announcementId).update({
          'likes': FieldValue.increment(-1),
        });
      }
    });
  }

  void _addComment() {
    String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      FirebaseFirestore.instance.collection('announcements').doc(widget.announcementId).update({
        'comments': FieldValue.arrayUnion([
          {
            'username': widget.userDataMap['name'] ?? '', // Ensure username is not null
            'text': commentText,
            'timestamp': Timestamp.now(),
          }
        ]),
      }).then((value) {
        _commentController.clear();
      }).catchError((error) {
        print('Failed to add comment: $error');
      });
    }
  }

  Color _getColorFromLetter(String letter) {
    // Generate a color based on the ASCII value of the letter
    int hash = letter.codeUnitAt(0);
    return Color.fromARGB(
      255,
      (hash * 10) % 256,
      (hash * 20) % 256,
      (hash * 30) % 256,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract the first letter of the username
    String firstLetter = widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '';

    return Card(
      margin: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundColor: _getColorFromLetter(firstLetter),
              child: Text(
                firstLetter,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
            title: Text(
              widget.username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(Icons.more_vert),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(widget.caption),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: _isLiked ? Icon(Icons.favorite, color: Color.fromARGB(255, 222, 17, 17)) : Icon(Icons.favorite_border),
                      onPressed: _toggleLike,
                    ),
                    SizedBox(width: 4.0),
                    Text('${widget.likes}'),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    setState(() {
                      _showComments = !_showComments;
                    });
                  },
                ),
              ],
            ),
          ),
          Divider(),
          if (_showComments && widget.comments != null) // Ensure comments is not null
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Comments:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  children: _buildCommentList(), // Helper method to build comment list
                ),
              ],
            ),
          if (_showComments)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  TextButton(
                    onPressed: _addComment,
                    child: Text('Post'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCommentList() {
    return widget.comments.map<Widget>((comment) {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        leading: CircleAvatar(
          radius: 16.0,
          backgroundColor: _getColorFromLetter(comment['username'][0] ?? ' '),
          child: Text(
            comment['username'][0] ?? '',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
        ),
        title: Text(comment['username'] ?? ''),
        subtitle: Text(comment['text'] ?? ''),
      );
    }).toList();
  }
}
