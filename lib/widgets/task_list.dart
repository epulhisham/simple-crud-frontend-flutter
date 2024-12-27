import 'package:flutter/material.dart';
import 'package:task_manager/widgets/file_list.dart';
import 'package:task_manager/widgets/file_upload.dart';
import 'package:task_manager/widgets/login.dart';
import 'package:task_manager/widgets/task_create.dart';
import 'package:task_manager/widgets/task_details.dart';
import '../services/task_services.dart';
import '../models/task.dart';

class TaskList extends StatefulWidget {
  final String token;

  const TaskList({super.key, required this.token});
  @override
  State<StatefulWidget> createState() {
    return _TaskListState();
  }
}

class _TaskListState extends State<TaskList> {
  late Future<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = TaskServices().fetchTasks(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FileList(token: widget.token)),
              );
            },
            icon: const Icon(Icons.folder),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FileUpload(token: widget.token)),
              );
            },
            icon: const Icon(Icons.upload),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await TaskServices().logout(widget.token);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final tasks = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 15,
              ),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.status),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetails(task: task, token: widget.token,),
                        ),
                      );

                      // Refresh the task list if the task was updated
                      if (result == true) {
                        setState(() {
                          _tasks = TaskServices().fetchTasks(widget.token);
                        });
                      }
                    },
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskCreate(token: widget.token,)),
          );

          setState(() {
            _tasks = TaskServices().fetchTasks(widget.token);
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
