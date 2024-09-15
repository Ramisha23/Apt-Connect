import 'package:aptconnect/Widget/FacultyDrawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewQuizResults extends StatelessWidget {
  final Map<String, dynamic> userDataMap;

  ViewQuizResults(this.userDataMap);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final isFaculty = userDataMap['role'] == 'faculty'; // Adjust according to how you store roles

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Results',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF694F8E), // Deep Purple
       
      ),
                        drawer: CustomDrawer(userDataMap:userDataMap),

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('quizzes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No results available.'));
          }

          final quizzes = snapshot.data!.docs;

          final resultsStream = isFaculty
              ? _firestore.collection('quiz_results').where('quizId', whereIn: quizzes.map((quiz) => quiz.id).toList()).snapshots()
              : _firestore.collection('quiz_results').snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: resultsStream,
            builder: (context, resultsSnapshot) {
              if (resultsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (resultsSnapshot.hasError) {
                return Center(child: Text('Error: ${resultsSnapshot.error}'));
              }

              if (!resultsSnapshot.hasData || resultsSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No results available.'));
              }

              final results = resultsSnapshot.data!.docs;

              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index].data() as Map<String, dynamic>;
                  final quizId = result['quizId'] ?? 'Unknown';
                  final studentName = result['studentName'] ?? 'Unknown';
                  final score = result['score'] ?? 0;
                  final timestamp = (result['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final formattedDate = "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}:${timestamp.second}";

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    color: score == 0 ? Colors.red[50] : Colors.white, // Highlight if score is 0
                    child: ListTile(
                      title: Text('$studentName '),
                      subtitle: Text('Score: $score'),
                      trailing: Text(formattedDate),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
