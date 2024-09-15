import 'package:aptconnect/Widget/FacultyDrawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../model/workshop_model.dart'; 

class WorkshopForm extends StatefulWidget {
  final Map<String, dynamic> userDataMap;

  WorkshopForm(this.userDataMap);

  @override
  _WorkshopFormState createState() => _WorkshopFormState();
}

class _WorkshopFormState extends State<WorkshopForm> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  DateTime? _timing;
  String? _facilitator;
  DateTime? _dueDate;
  String? _description;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_title == null || _timing == null || _facilitator == null || _dueDate == null || _description == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      Workshop newWorkshop = Workshop(
        title: _title!,
        timing: _timing!,
        facilitator: _facilitator!,
        dueDate: _dueDate!,
        description: _description!,
      );

      try {
        await FirebaseFirestore.instance.collection('workshops').add({
          'title': newWorkshop.title,
          'timing': newWorkshop.timing,
          'facilitator': newWorkshop.facilitator,
          'dueDate': newWorkshop.dueDate,
          'description': newWorkshop.description,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Workshop added successfully')),
        );

        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add workshop')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Workshop',
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Color(0xFF694F8E), // Deep purple
      ),
                  drawer: CustomDrawer(userDataMap: widget.userDataMap),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Container background color
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.work), 
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _title = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Facilitator',
                        prefixIcon: Icon(Icons.person), 
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a facilitator';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _facilitator = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () {
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          maxTime: DateTime(2030),
                          onChanged: (date) {
                            // Do nothing for now
                          },
                          onConfirm: (date) {
                            setState(() {
                              _timing = date;
                            });
                          },
                          currentTime: _timing ?? DateTime.now(), 
                          locale: LocaleType.en,
                        );
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Timing',
                            suffixIcon: Icon(Icons.calendar_today), 
                          ),
                          controller: TextEditingController(
                            text: _timing == null
                                ? ''
                                : DateFormat('MMM dd, yyyy hh:mm a').format(_timing!),
                          ),
                          validator: (value) {
                            if (_timing == null) {
                              return 'Please select timing';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () {
                        DatePicker.showDatePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          maxTime: DateTime(2030),
                          onChanged: (date) {
                           
                          },
                          onConfirm: (date) {
                            setState(() {
                              _dueDate = date;
                            });
                          },
                          currentTime: _dueDate ?? DateTime.now(),
                          locale: LocaleType.en,
                        );
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Due Date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: _dueDate == null
                                ? ''
                                : DateFormat('MMM dd, yyyy').format(_dueDate!),
                          ),
                          validator: (value) {
                            if (_dueDate == null) {
                              return 'Please select due date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description), 
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _description = value;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF694F8E), // Deep purple
                  foregroundColor: Colors.white, // White text color
                  padding: EdgeInsets.symmetric(vertical: 16.0), // Button padding
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
