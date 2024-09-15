import 'package:aptconnect/GroupReq.dart';
import 'package:aptconnect/JoinGroup.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroupDialog extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  CreateGroupDialog(this.userDataMap);

  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {



  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();


  

 void _createGroup() {
  String groupName = _groupNameController.text.trim();
  String groupDescription = _groupDescriptionController.text.trim();
  String createdBy = widget.userDataMap['userId']; // Assuming userId is stored in userDataMap

  if (groupName.isNotEmpty && groupDescription.isNotEmpty) {
    // Add new group to Firestore
    FirebaseFirestore.instance.collection('groups').add({
      'groupName': groupName,
      'groupDescription': groupDescription,
      'createdBy': createdBy,
      'members': [createdBy],  // Add creator as the first member
      'requests': [],          // Initialize requests array as empty
    }).then((DocumentReference docRef) {
      // Extract the generated groupId from the DocumentReference
      String groupId = docRef.id;

      // Show success message or navigate to group details
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group created successfully')));
      
      // Navigate to JoinGroupPage or GroupRequestsPage with userDataMap and groupId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupRequestsPage(userDataMap: widget.userDataMap, groupId: groupId),
        ),
      );
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create group: $error')));
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter group name and description')));
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _groupNameController,
            decoration: InputDecoration(
              labelText: 'Group Name',
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _groupDescriptionController,
            decoration: InputDecoration(
              labelText: 'Group Description',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createGroup,
          child: Text('Create'),
        ),
      ],
    );
  }
}
