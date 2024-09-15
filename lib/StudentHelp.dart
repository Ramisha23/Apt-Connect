import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentHelpRequestsPage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  StudentHelpRequestsPage({required this.userDataMap});

  @override
  _StudentHelpRequestsPageState createState() => _StudentHelpRequestsPageState();
}

class _StudentHelpRequestsPageState extends State<StudentHelpRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> requests = [];

  @override
  void initState() {
    super.initState();
    _fetchHelpRequests();
  }

  void _fetchHelpRequests() async {
    var requestSnapshot = await _firestore
        .collection('HelpRequests')
        .where('studentId', isEqualTo: widget.userDataMap['userId'])
        .get();
    setState(() {
      requests = requestSnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Help Requests',style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic )),
        backgroundColor: Color(0xFF694F8E), // Deep Purple
      ),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          var request = requests[index].data() as Map<String, dynamic>;
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('Request ID: ${requests[index].id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${request['status']}'),
                  if (request['response'] != null && request['response'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Response: ${request['response']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Text(
                request['requestType'] == 'faculty' ? 'To Faculty' : 'To Fellow Student',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
