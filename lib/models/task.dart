class Task {
  final int id;
  final String title;
  final String description;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> task) {
    return Task(
      id: task['id'],
      title: task['title'],
      description: task['description'] ?? '',
      status: task['status'],
    );
  }
}
