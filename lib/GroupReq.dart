import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupRequestsPage extends StatelessWidget {
  final Map<String, dynamic> userDataMap;
  final String groupId; // Assuming groupId is passed to this widget

  GroupRequestsPage({required this.userDataMap, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Join Requests'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Group not found.'));
          }

          var groupData = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> requests = groupData['requests'] ?? [];
          String creatorId = groupData['creator'];

          // Only show requests if the current user is the creator of the group
          if (creatorId != userDataMap['userId']) {
            return Center(child: Text('You are not authorized to view this page.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (BuildContext context, int index) {
              String userId = requests[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      trailing: CircularProgressIndicator(),
                    );
                  }
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('User not found'),
                    );
                  }
                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(userData['username'] ?? 'Username not available'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => _acceptRequest(context, groupId, userId),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => _rejectRequest(context, groupId, userId),
                        ),
                      ],
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

  void _acceptRequest(BuildContext context, String groupId, String userId) {
    // Update Firestore to add user to group members and remove from requests
    FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
      'requests': FieldValue.arrayRemove([userId]),
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request accepted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to accept request: $error')));
    });
  }

  void _rejectRequest(BuildContext context, String groupId, String userId) {
    // Update Firestore to remove user from requests
    FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'requests': FieldValue.arrayRemove([userId]),
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request rejected')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to reject request: $error')));
    });
  }
}
