import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'QuizDetail.dart';

class QuizListPage extends StatelessWidget {
  final Map<String, dynamic> userDataMap;

  QuizListPage({required this.userDataMap});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchQuizzes() async {
    final quizzesSnapshot = await _firestore.collection('quizzes').get();
    final quizzes = quizzesSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id, // Add the document ID to the quiz data
        ...data,
      };
    }).toList();
    
    // Filter quizzes to exclude those already submitted by the user
    final userId = userDataMap['userId']; // Adjust if your user ID key is different
    final resultsSnapshot = await _firestore
        .collection('quiz_results')
        .where('studentId', isEqualTo: userId)
        .get();
    final submittedQuizIds = resultsSnapshot.docs.map((doc) => doc['quizId'] as String).toSet();

    return quizzes.where((quiz) => !submittedQuizIds.contains(quiz['id'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF694F8E), // Deep Purple
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No quizzes available', style: TextStyle(color: Colors.grey)));
          }
          final quizzes = snapshot.data!;

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Container(
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    quiz['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF694F8E), // Deep Purple
                    ),
                  ),
                  subtitle: Text(
                    quiz['description'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizDetailPage(
                          quiz: quiz,
                          userDataMap: userDataMap,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
