import 'package:aptconnect/FacultyHelp.dart';
import 'package:aptconnect/FacultyWorkshop.dart';
import 'package:aptconnect/QuizResult.dart';
import 'package:aptconnect/ViewPost.dart';
import 'package:flutter/material.dart';
import 'package:aptconnect/announcement_form.dart'; // Import AnnouncementForm
import 'package:aptconnect/PostQuiz.dart';
import 'package:aptconnect/UpdateProfile.dart';
import 'package:aptconnect/WorkshopAdd.dart';
import 'package:aptconnect/login.dart';
import 'package:aptconnect/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aptconnect/AddPostPage.dart';

class InstagramHomePage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  InstagramHomePage(this.userDataMap);

  @override
  _InstagramHomePageState createState() => _InstagramHomePageState();
}

class _InstagramHomePageState extends State<InstagramHomePage> {
  int _currentIndex = 0;
  final TextEditingController _announcementController = TextEditingController();

  void _submitAnnouncement() async {
    try {
      await FirebaseFirestore.instance.collection('announcements').add({
        'username': widget.userDataMap['name'],
        'announcement': _announcementController.text,
        'likes': 0,
        'comments': [],
        'timestamp': FieldValue.serverTimestamp(),
      });

      _announcementController.clear();
    } catch (error) {
      print('Error posting announcement: $error');
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  backgroundColor: Color.fromARGB(255, 193, 144, 194), 
 
      appBar: AppBar(
        backgroundColor: Color(0xFF694F8E), 
        title: Text(
          'AptConnect',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Billabong',
            fontSize: 35.0,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
       
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
               Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                'Welcome, ${widget.userDataMap['name']}',
                style: TextStyle(
                  color: Color.fromARGB(255, 149, 82, 211),
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
                   
            AnnouncementForm(
              announcementController: _announcementController,
              submitAnnouncement: _submitAnnouncement,
            ),
            SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('announcements').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return AnnouncementWidget(
                      username: document['username'],
                      announcement: document['announcement'],
                      likes: document['likes'],
                      comments: document['comments'] ?? [],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
     drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(
          color: Color(0xFF694F8E), // Deep Purple
        ),
        child: Text(
          'AptConnect',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Billabong',
          ),
        ),
      ),
      ListTile(
        leading: Icon(Icons.calendar_today, color: Color(0xFFE3A5C7)), // Workshops
        title: Text('Workshops', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkshopForm(widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.add_box, color: Color(0xFFE3A5C7)), // Add Post
        title: Text('Add Post', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostPage(widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.post_add, color: Color(0xFFE3A5C7)), // Post Quiz
        title: Text('Post Quiz', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostQuizPage(widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.account_circle, color: Color(0xFFE3A5C7)), // Profile
        title: Text('Profile', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InstagramProfilePage(widget.userDataMap)),
          );
        },
      ),
       ListTile(
        leading: Icon(Icons.article, color:Color(0xFFE3A5C7 )), // Posts
        title: Text('View Posts',style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostViewPage(widget.userDataMap)),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.people, color: Color(0xFFE3A5C7)), // Workshop Enrolled List
        title: Text('Workshop Enrolled List', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FacultyWorkshopList()),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.show_chart, color: Color(0xFFE3A5C7)), // Quiz Results
        title: Text('Quiz Results', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewQuizResults(widget.userDataMap),
            ),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.help, color: Color(0xFFE3A5C7)), // Help Requests
        title: Text('Help Requests', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FacultyHelpRequestsPage(userDataMap: widget.userDataMap),
            ),
          );
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.exit_to_app, color: Color(0xFFE3A5C7)), // Logout
        title: Text('Logout', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
        onTap: () {
          Navigator.pop(context); // Close the drawer
          _logout(); // Call the logout method
        },
      ),
    ],
  ),
),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF694F8E), // Deep Purple
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            // Home page action
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WorkshopForm(widget.userDataMap)),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPostPage(widget.userDataMap)),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostQuizPage(widget.userDataMap)),
            );
          }
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InstagramProfilePage(widget.userDataMap)),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Workshops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class StoryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('images/logo.png'),
          fit: BoxFit.cover,
        ),
        border: Border.all(
          color: Color(0xFFE3A5C7), // Soft Pink
          width: 2.0,
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.blue,
            size: 20.0,
          ),
        ),
      ),
    );
  }
}

class AnnouncementWidget extends StatefulWidget {
  final String username;
  final String announcement;
  final int likes;
  final List<dynamic>? comments; // List of comments

  AnnouncementWidget({
    required this.username,
    required this.announcement,
    required this.likes,
    this.comments,
  });

  @override
  _AnnouncementWidgetState createState() => _AnnouncementWidgetState();
}

class _AnnouncementWidgetState extends State<AnnouncementWidget> {
  bool _isLiked = false;
  bool _showComments = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _toggleCommentsVisibility() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Convert comments if necessary
    List<Map<String, dynamic>> comments = widget.comments?.map((e) {
      if (e is Map) {
        return {
          'username': e['username'] ?? 'Anonymous',
          'text': e['text'] ?? '',
          'timestamp': e['timestamp'] ?? Timestamp.now(),
        };
      }
      return {
        'username': 'Anonymous',
        'text': '',
        'timestamp': Timestamp.now(),
      };
    }).toList() ?? [];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF694F8E), // Deep Purple
              ),
            ),
            SizedBox(height: 5.0),
            Text(widget.announcement),
            SizedBox(height: 10.0),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Color(0xFFE3A5C7) : Colors.grey, // Soft Pink when liked
                  ),
                  onPressed: _toggleLike,
                ),
                Text('${widget.likes + (_isLiked ? 1 : 0)}'),
                Spacer(),
                IconButton(
                  icon: Icon(
                    _showComments ? Icons.expand_less : Icons.expand_more,
                    color: Color(0xFF694F8E), // Deep Purple
                  ),
                  onPressed: _toggleCommentsVisibility,
                ),
              ],
            ),
            if (_showComments)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (var comment in comments)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 12,
                            child: Text(comment['username']?[0] ?? 'U'), // Initials or a default letter
                            backgroundColor: Color(0xFFE3A5C7), // Soft Pink
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  comment['username'] ?? 'Anonymous',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF694F8E), // Deep Purple
                                  ),
                                ),
                                Text(comment['text'] ?? ''),
                                SizedBox(height: 4.0),
                                Text(
                                  _formatTimestamp(comment['timestamp']),
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final DateTime date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    }
    return 'Unknown time';
  }
}
