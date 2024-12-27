import 'package:flutter/material.dart';
import '../services/task_services.dart';
import '../models/task.dart';

class TaskCreate extends StatefulWidget {
  final String token;
  const TaskCreate({super.key, required this.token});
  @override
  State<StatefulWidget> createState() {
    return _TaskCreateState();
  }
}

class _TaskCreateState extends State<TaskCreate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _status = 'Pending'; // Default status

  // Create Task using TaskServices
  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new Task object
        final task = Task(
          id: 0, // Dummy ID, Laravel will assign one
          title: _titleController.text,
          description: _descriptionController.text,
          status: _status,
        );

        // Call TaskServices to create the task
        await TaskServices().createTask(task, widget.token);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task created successfully!')),
        );

        Navigator.pop(context); // Navigate back after success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Pending', 'Completed']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitTask, // Call the new function
                child: Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
