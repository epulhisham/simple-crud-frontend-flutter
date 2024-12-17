import 'package:flutter/material.dart';
import 'package:task_manager/widgets/task_create.dart';
import 'package:task_manager/widgets/task_details.dart';
import '../services/task_services.dart';
import '../models/task.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});
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
    _tasks = TaskServices().fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Manager')),
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
                          builder: (context) => TaskDetails(task: task),
                        ),
                      );

                      // Refresh the task list if the task was updated
                      if (result == true) {
                        setState(() {
                          _tasks = TaskServices().fetchTasks();
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
            MaterialPageRoute(builder: (context) => TaskCreate()),
          );

          setState(() {
            _tasks = TaskServices().fetchTasks();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
