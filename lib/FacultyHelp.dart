import 'package:aptconnect/Widget/FacultyDrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FacultyHelpRequestsPage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  FacultyHelpRequestsPage({required this.userDataMap});

  @override
  _FacultyHelpRequestsPageState createState() => _FacultyHelpRequestsPageState();
}

class _FacultyHelpRequestsPageState extends State<FacultyHelpRequestsPage> {
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
        .where('facultyId', isEqualTo: widget.userDataMap['userId'])
        .get();
    setState(() {
      requests = requestSnapshot.docs;
    });
  }

  void _respondToRequest(DocumentSnapshot request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController responseController = TextEditingController();
        return AlertDialog(
          title: Text('Respond to Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Request ID: ${request.id}'),
              SizedBox(height: 10),
              Text('Student: ${request['studentName']}'),
              SizedBox(height: 10),
              TextField(
                controller: responseController,
                decoration: InputDecoration(
                  labelText: 'Your Response',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Send'),
              onPressed: () async {
                await _firestore.collection('HelpRequests').doc(request.id).update({
                  'status': 'Responded',
                  'response': responseController.text,
                });
                Navigator.of(context).pop();
                _fetchHelpRequests(); // Refresh the list after responding
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Requests'),
        backgroundColor: Color(0xFF694F8E), // Deep Purple
      ),
                  drawer: CustomDrawer(userDataMap: widget.userDataMap),

      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          var request = requests[index].data() as Map<String, dynamic>;
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('Request ID: ${requests[index].id}'),
              subtitle: Text('Student: ${request['studentName']} - ${request['description']}'),
              trailing: Text('Status: ${request['status']}'),
              onTap: () {
                _respondToRequest(requests[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
