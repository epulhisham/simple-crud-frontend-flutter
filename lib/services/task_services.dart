import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:task_manager/models/task.dart';

class TaskServices {
  final String baseUrl = "http://192.168.0.241:8000/api";

  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to log out');
    }
  }

  Future<List<Task>> fetchTasks(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'), headers: {
      'Content-Type': 'Application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List tasks = responseBody['data'];
      return tasks.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'status': task.status,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'status': task.status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete task');
    }
  }
}
