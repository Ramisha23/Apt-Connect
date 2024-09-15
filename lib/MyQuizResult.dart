import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyQuizResultPage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  MyQuizResultPage(this.userDataMap);

  @override
  _MyQuizResultPageState createState() => _MyQuizResultPageState();
}

class _MyQuizResultPageState extends State<MyQuizResultPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _quizResultFuture;

  @override
  void initState() {
    super.initState();
    _quizResultFuture = _fetchQuizResult();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchQuizResult() async {
    return _firestore
        .collection('quiz_results')
        .where('studentId', isEqualTo: widget.userDataMap['userId'])
        .limit(1) // Assuming there's only one result per student per quiz
        .get()
        .then((snapshot) => snapshot.docs.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF694F8E), // Deep Purple
        title: Text('Quiz Result',style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic )),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _quizResultFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No quiz result found.'));
          }

          final quizResult = snapshot.data!.data()!;
          final studentName = quizResult['studentName'];
          final score = quizResult['score'];
          final timestamp = (quizResult['timestamp'] as Timestamp).toDate();

          return Padding(
            padding: const EdgeInsets.all(16.0),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Name: $studentName',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF694F8E), // Deep Purple
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Timestamp: ${timestamp.toLocal()}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
