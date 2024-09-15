import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WorkshopList extends StatelessWidget {
  final Map<String, dynamic> userDataMap;

  WorkshopList(this.userDataMap);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workshop List',
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
              final workshopId = workshops[index].id; // Get the document ID
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
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final userId = userDataMap['userId'] as String;

                      if (enrolledStudents.contains(userId)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('You are already enrolled in this workshop')),
                        );
                        return;
                      }

                      try {
                        // Update Firestore to enroll the student
                        await FirebaseFirestore.instance.collection('workshops').doc(workshopId).update({
                          'enrolledStudents': FieldValue.arrayUnion([userId]),
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Enrolled successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to enroll')),
                        );
                      }
                    },
                    child: Text('Enroll'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, 
                      backgroundColor: Color(0xFF694F8E), // Deep purple
                    ),
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
