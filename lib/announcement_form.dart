import 'package:flutter/material.dart';

class AnnouncementForm extends StatelessWidget {
  final TextEditingController announcementController;
  final VoidCallback submitAnnouncement;

  AnnouncementForm({
    required this.announcementController,
    required this.submitAnnouncement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Post an Announcement',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 12.0),
          TextField(
            controller: announcementController,
            decoration: InputDecoration(
              hintText: 'Write your announcement here...',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: submitAnnouncement,
            child:     Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF694F8E), Color(0xFFE3A5C7)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Post',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
            ),
        
        ],
      ),
    );
  }
}
