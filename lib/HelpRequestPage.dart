import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HelpRequestPage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  HelpRequestPage({required this.userDataMap});

  @override
  _HelpRequestPageState createState() => _HelpRequestPageState();
}

class _HelpRequestPageState extends State<HelpRequestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> students = [];
  List<DocumentSnapshot> faculty = [];
  String _selectedStudentId = '';
  String _selectedFacultyId = '';
  String _description = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    var userSnapshot = await _firestore.collection('Users').get();
    setState(() {
      students = userSnapshot.docs.where((doc) => doc['role'] == 'Student' && doc.id != widget.userDataMap['userId']).toList();
      faculty = userSnapshot.docs.where((doc) => doc['role'] == 'Faculty').toList();
    });
  }

  void _sendHelpRequest() async {
    if (_description.isNotEmpty) {
      try {
        await _firestore.collection('HelpRequests').add({
          'studentId': widget.userDataMap['userId'],
          'studentName': widget.userDataMap['name'],
          'facultyId': _selectedFacultyId,
          'facultyName': _selectedFacultyId.isNotEmpty ? (faculty.firstWhere((doc) => doc.id == _selectedFacultyId)['name']) : '',
          'requestType': _selectedFacultyId.isNotEmpty ? 'faculty' : 'student',
          'description': _description,
          'timestamp': Timestamp.now(),
          'status': 'pending',
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Help request sent successfully')));
        setState(() {
          _description = '';
          _selectedStudentId = '';
          _selectedFacultyId = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send help request')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request Help',
          style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
        ),
        backgroundColor: Color(0xFF694F8E), // Deep Purple
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Field
            Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              maxLines: 4,
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe your issue...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF694F8E), width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Faculty Dropdown
            Text(
              'Request Help From Faculty:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFacultyId.isNotEmpty ? _selectedFacultyId : null,
              hint: Text('Select Faculty'),
              items: faculty.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(doc['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFacultyId = value ?? '';
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF694F8E), width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Send Request Button
            Center(
              child: ElevatedButton(
                onPressed: _sendHelpRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 183, 146, 235), // Deep Purple
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text('Send Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
