import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class QuizDetailPage extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final Map<String, dynamic> userDataMap;

  QuizDetailPage({required this.quiz, required this.userDataMap});

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  final Map<int, String?> _answers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _feedback = '';

  void _submitQuiz() async {
    int score = 0;
    final questions = (widget.quiz['questions'] as List).cast<Map<String, dynamic>>();

    // Calculate score
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      if (_answers[i] == question['correctAnswer']) {
        score++;
      }
    }

    // Save results to Firestore
    try {
      await _firestore.collection('quiz_results').add({
        'quizId': widget.quiz['id'], 
        'studentId': widget.userDataMap['userId'], 
        'studentName': widget.userDataMap['name'], 
        'score': score,
        'timestamp': Timestamp.now(),
      });

      // Navigate to Results Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsPage(
            score: score,
            totalQuestions: questions.length,
          ),
        ),
      );
    } catch (e) {
      print('Error submitting quiz: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit quiz.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = (widget.quiz['questions'] as List).cast<Map<String, dynamic>>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quiz['title'],
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Color(0xFF694F8E), // Deep Purple
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question['question'],
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          ...(question['options'] as List).map<Widget>((option) {
                            return RadioListTile<String>(
                              value: option,
                              groupValue: _answers[index],
                              title: Text(option),
                              onChanged: (value) {
                                setState(() {
                                  _answers[index] = value;
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF694F8E), // Deep Purple
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                textStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white), // White text color
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class QuizResultsPage extends StatelessWidget {
  final int score;
  final int totalQuestions;

  QuizResultsPage({required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Results',
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Color(0xFF694F8E), // Deep Purple
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'You scored $score out of $totalQuestions',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
