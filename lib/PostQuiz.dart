import 'package:aptconnect/Widget/FacultyDrawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aptconnect/QuizResult.dart'; // Adjust import according to your project structure

class PostQuizPage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  PostQuizPage(this.userDataMap);

  @override
  _PostQuizPageState createState() => _PostQuizPageState();
}

class _PostQuizPageState extends State<PostQuizPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _questionController = TextEditingController();
  final _optionControllers = List.generate(4, (_) => TextEditingController());
  final _correctOptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _quizId;

  void _postQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final question = _questionController.text.trim();
    final options = _optionControllers.map((controller) => controller.text.trim()).toList();
    final correctAnswer = _correctOptionController.text.trim();

    try {
      final quizRef = await _firestore.collection('quizzes').add({
        'title': title,
        'description': description,
        'questions': [
          {
            'question': question,
            'options': options,
            'correctAnswer': correctAnswer,
          },
        ],
        'createdBy': widget.userDataMap['name'],
        'createdAt': Timestamp.now(),
      });

      setState(() {
        _quizId = quizRef.id; // Store the quiz ID
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quiz posted successfully!')));
      _clearForm();
    } catch (e) {
      print('Error posting quiz: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post quiz.')));
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _questionController.clear();
    _optionControllers.forEach((controller) => controller.clear());
    _correctOptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Quiz',
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Color(0xFF694F8E), // Deep purple
      ),
                  drawer: CustomDrawer(userDataMap: widget.userDataMap),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextField(_titleController, 'Quiz Title'),
              SizedBox(height: 16.0),
              _buildTextField(_descriptionController, 'Description'),
              SizedBox(height: 16.0),
              _buildTextField(_questionController, 'Question'),
              SizedBox(height: 16.0),
              ...List.generate(4, (index) => _buildTextField(_optionControllers[index], 'Option ${index + 1}')),
              _buildTextField(_correctOptionController, 'Correct Answer'),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _postQuiz,
                child: Text(
                  'Post Quiz',
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF694F8E), // Deep purple
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
         
            
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Color(0xFF694F8E), // Deep purple
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
