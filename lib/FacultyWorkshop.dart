import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FacultyWorkshopList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workshop Enrollments',
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Color(0xFF694F8E), // Deep purple
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('workshops').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No workshops available'));
          }

          final workshops = snapshot.data!.docs;

          return ListView.builder(
            itemCount: workshops.length,
            itemBuilder: (context, index) {
              final workshop = workshops[index].data() as Map<String, dynamic>;
              final workshopId = workshops[index].id;
              final title = workshop['title'] ?? 'No Title';
              final timing = (workshop['timing'] as Timestamp).toDate();
              final facilitator = workshop['facilitator'] ?? 'Unknown';
              final dueDate = (workshop['dueDate'] as Timestamp).toDate();
              final description = workshop['description'] ?? 'No Description';
              final enrolledStudents = (workshop['enrolledStudents'] as List<dynamic>?) ?? [];

              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Facilitator: $facilitator'),
                      Text('Timing: ${DateFormat('MMM dd, yyyy hh:mm a').format(timing)}'),
                      Text('Due Date: ${DateFormat('MMM dd, yyyy').format(dueDate)}'),
                      SizedBox(height: 8.0),
                      Text('Description: $description'),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.people, color: Colors.blue), // Icon representing students
                          SizedBox(width: 8.0),
                          Text(
                            '${enrolledStudents.length} student(s) enrolled',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      ...enrolledStudents.map((studentId) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(studentId),
                      )).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
    
  }
}
