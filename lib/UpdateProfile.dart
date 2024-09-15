import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileDetailPage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  ProfileDetailPage(this.userDataMap);

  @override
  _ProfileDetailPageState createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  String _batchName = ''; 
  String _semester = ''; 

  @override
  void initState() {
    super.initState();
    _batchName = widget.userDataMap['batchName'] ?? '';
    _semester = widget.userDataMap['semester'] ?? '';
  }

  void _saveProfileChanges() {
    String userId = widget.userDataMap['userId'];
    FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'batchName': _batchName,
      'semester': _semester,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $error')));
    });
  }

  @override
  Widget build(BuildContext context) {
    String initials = widget.userDataMap['name'][0].toUpperCase();
    String profileImageUrl = widget.userDataMap['profileImageUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF694F8E), // Deep Purple
        title: Text(
          'Profile Detail',
          style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveProfileChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 6,
                    offset: Offset(0, 3), 
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Color(0xFF694F8E), // Deep Purple
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? Text(
                            initials,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null, 
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.userDataMap['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF694F8E), // Deep Purple
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.userDataMap['email'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    labelText: 'Batch Name',
                    initialValue: _batchName,
                    onChanged: (value) {
                      setState(() {
                        _batchName = value;
                      });
                    },
                    icon: Icons.school,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    labelText: 'Semester',
                    initialValue: _semester,
                    onChanged: (value) {
                      setState(() {
                        _semester = value;
                      });
                    },
                    icon: Icons.calendar_today,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required String initialValue,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF694F8E)), // Deep Purple
          labelText: labelText,
          labelStyle: TextStyle(
            color: Color(0xFF694F8E), // Deep Purple
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF694F8E), width: 2.0), // Deep Purple
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
