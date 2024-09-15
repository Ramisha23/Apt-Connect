import 'package:aptconnect/GroupReq.dart';
import 'package:aptconnect/GroupScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinGroupPage extends StatefulWidget {
  final Map<String, dynamic> userDataMap;
  final String groupId;

  JoinGroupPage({required this.userDataMap, required this.groupId});

  @override
  _JoinGroupPageState createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  bool isMember = false;
  bool isPending = false;

  @override
  void initState() {
    super.initState();
    checkMembershipStatus();
    listenToGroupChanges();
  }

  void checkMembershipStatus() {
    // Check if current user is already a member of the group
    String userId = widget.userDataMap['userId'];
    List<dynamic> members = widget.userDataMap['groups'] ?? [];

    if (members.contains(widget.groupId)) {
      setState(() {
        isMember = true;
      });
    }
  }

  void listenToGroupChanges() {
    // Listen to changes in the group document to detect acceptance
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots().listen((snapshot) {
      if (!snapshot.exists) return;

      var groupData = snapshot.data() as Map<String, dynamic>;
      List<dynamic> members = groupData['members'] ?? [];
      List<dynamic> requests = groupData['requests'] ?? [];
      String userId = widget.userDataMap['userId'];

      setState(() {
        isMember = members.contains(userId);
        isPending = requests.contains(userId) && !isMember;
      });

      if (isMember) {
        // Navigate to group screen when request is accepted
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GroupChatPage(
              groupId: widget.groupId,
              userDataMap: widget.userDataMap,
              groupName: groupData['groupName'], // Pass groupName from groupData
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Group'),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              // Navigate to GroupRequestsPage with userDataMap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GroupRequestsPage(userDataMap: widget.userDataMap, groupId: widget.groupId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Group not found.'));
          }

          var groupData = snapshot.data!.data() as Map<String, dynamic>;
          String groupName = groupData['groupName'];
          String groupDescription = groupData['groupDescription'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  groupName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  groupDescription,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              if (isMember)
                Center(child: Text('You are already a member of this group.')),
              if (!isMember && !isPending)
                Center(
                  child: ElevatedButton(
                    onPressed: () => _requestToJoinGroup(widget.groupId),
                    child: Text('Join Group'),
                  ),
                ),
              if (isPending)
                Center(
                  child: Text('Request Pending'),
                ),
            ],
          );
        },
      ),
    );
  }

  void _requestToJoinGroup(String groupId) {
    String userId = widget.userDataMap['userId'];

    // Update Firestore to add user's request to join the group
    FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'requests': FieldValue.arrayUnion([userId]),
    }).then((value) {
      // Update UI to show pending state
      setState(() {
        isPending = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent to join group')));
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send request: $error')));
    });
  }
}
