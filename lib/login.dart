import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aptconnect/signup.dart'; 
import 'package:aptconnect/home.dart';
import 'package:aptconnect/stddashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff694F8E), Color(0xffE3A5C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                  child: Text(
                    'AptConnect',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for the logo
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0), // Increased padding for a larger container
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff694F8E), // Deep purple text
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Make it work, make it right, make it fast.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30),
                          _buildTextField(
                            labelText: 'Email',
                            icon: FontAwesomeIcons.envelope,
                            isPassword: false,
                            controller: emailController,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            labelText: 'Password',
                            icon: FontAwesomeIcons.lock,
                            isPassword: true,
                            controller: passwordController,
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              _forgotPassword(context);
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xff694F8E), // Deep purple for links
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                                    width: double.infinity,

                            decoration: BoxDecoration(
                              
                              borderRadius: BorderRadius.circular(50),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF694F8E), Color(0xFFE3A5C7)],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  signInWithEmailAndPassword(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                    context,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent, // Set to transparent to show gradient
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
     padding: EdgeInsets.all(12.0),                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white, // White text on the button
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignupPage()), 
                              );
                            },
                            child: Text(
                              "Don't have an account? Signup",
                              style: TextStyle(
                                color: Color(0xff694F8E), // Deep purple for signup link
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    IconData? icon,
    bool? isPassword,
    required TextEditingController controller,
  }) {
    bool _obscureText = isPassword ?? false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: controller,
          obscureText: _obscureText,
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            labelText: labelText,
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    size: 20,
                    color: Color(0xff694F8E), // Deep purple icons
                  )
                : null,
            suffixIcon: isPassword ?? false
                ? IconButton(
                    icon: Icon(
                      _obscureText ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                      color: Color(0xff694F8E),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $labelText';
            }
            return null;
          },
        );
      },
    );
  }

  void signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .get();

        if (userData.exists && userData.data() != null) {
          Map<String, dynamic> userDataMap =
              userData.data() as Map<String, dynamic>;

          String userRole = userDataMap['role'];

          if (userRole == 'Faculty') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => InstagramHomePage(userDataMap)),
            );
          } else if (userRole == 'Student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => StudentDashboard(userDataMap)),
            );
          } else {
            showAlertDialog(context, 'Unrecognized Role',
                'Your account role is unrecognized.');
          }
        } else {
          showAlertDialog(context, 'Error', 'User data not found.');
        }
      }
    } catch (e) {
      showAlertDialog(context, 'Sign-in Failed',
          'Unable to sign in. Please try again.');
    }
  }

  void _forgotPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address below to receive a password reset link.',
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String email = emailController.text.trim();
                if (email.isEmpty) {
                  showAlertDialog(context, 'Error', 'Please enter an email address.');
                  return;
                }

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Navigator.of(context).pop();
                  showAlertDialog(context, 'Password Reset', 'Password reset email sent. Please check your inbox.');
                } catch (e) {
                  String errorMessage;
                  if (e is FirebaseAuthException) {
                    switch (e.code) {
                      case 'invalid-email':
                        errorMessage = 'The email address is not valid.';
                        break;
                      case 'user-not-found':
                        errorMessage = 'No user found with this email address.';
                        break;
                      default:
                        errorMessage = 'An error occurred. Please try again later.';
                        break;
                    }
                  } else {
                    errorMessage = 'An unexpected error occurred. Please try again.';
                  }
                  showAlertDialog(context, 'Error', errorMessage);
                }
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
