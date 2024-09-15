
import 'package:aptconnect/home.dart';
import 'package:flutter/material.dart';
import 'package:aptconnect/FacultyHelp.dart';
import 'package:aptconnect/FacultyWorkshop.dart';
import 'package:aptconnect/QuizResult.dart';
import 'package:aptconnect/ViewPost.dart';
import 'package:flutter/material.dart';
import 'package:aptconnect/announcement_form.dart'; 
import 'package:aptconnect/PostQuiz.dart';
import 'package:aptconnect/UpdateProfile.dart';
import 'package:aptconnect/WorkshopAdd.dart';
import 'package:aptconnect/login.dart';
import 'package:aptconnect/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aptconnect/AddPostPage.dart';

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic> userDataMap; // Assuming you pass user data map

  CustomDrawer({required this.userDataMap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            leading: Icon(Icons.dashboard, color: Color(0xFFE3A5C7)), // Workshops
            title: Text('Dashboard', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InstagramHomePage(userDataMap)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today, color: Color(0xFFE3A5C7)), // Workshops
            title: Text('Workshops', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkshopForm(userDataMap)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add_box, color: Color(0xFFE3A5C7)), // Add Post
            title: Text('Add Post', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPostPage(userDataMap)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.post_add, color: Color(0xFFE3A5C7)), // Post Quiz
            title: Text('Post Quiz', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostQuizPage(userDataMap)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Color(0xFFE3A5C7)), // Profile
            title: Text('Profile', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InstagramProfilePage(userDataMap)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.article, color: Color(0xFFE3A5C7)), // Posts
            title: Text('View Posts',style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostViewPage(userDataMap)),
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
                MaterialPageRoute(builder: (context) => ViewQuizResults(userDataMap)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Color(0xFFE3A5C7)), // Help Requests
            title: Text('Help Requests', style: TextStyle(color: Color(0xFF694F8E), fontStyle: FontStyle.italic)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FacultyHelpRequestsPage(userDataMap: userDataMap)),
              );
            },
          ),
          Divider(),
      
        ],
      ),
    );
  }

}
