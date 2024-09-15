import 'package:flutter/material.dart';

class StudentProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Student Progress',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // Handle notifications icon press
            },
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Handle menu icon press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildProgressCard(
              title: 'Grades',
              subtitle: 'View your current grades',
              icon: Icons.grade,
              color: Colors.blue,
              onTap: () {
                // Handle tap on grades
              },
            ),
            SizedBox(height: 20.0),
            _buildProgressCard(
              title: 'Attendance',
              subtitle: 'Check your attendance record',
              icon: Icons.calendar_today,
              color: Colors.orange,
              onTap: () {
                // Handle tap on attendance
              },
            ),
            SizedBox(height: 20.0),
            _buildProgressCard(
              title: 'Assignments',
              subtitle: 'See upcoming assignments',
              icon: Icons.assignment,
              color: Colors.green,
              onTap: () {
                // Handle tap on assignments
              },
            ),
            SizedBox(height: 20.0),
            _buildProgressCard(
              title: 'Exams',
              subtitle: 'Prepare for upcoming exams',
              icon: Icons.school,
              color: Colors.purple,
              onTap: () {
                // Handle tap on exams
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'IGTV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28.0,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18.0, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: StudentProgressPage(),
    debugShowCheckedModeBanner: false,
  ));
}
