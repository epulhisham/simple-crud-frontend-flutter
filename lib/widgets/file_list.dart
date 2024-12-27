import 'package:flutter/material.dart';
import 'package:task_manager/services/task_services.dart';
import 'package:intl/intl.dart';

class FileList extends StatefulWidget {
  final String token;
  const FileList({super.key, required this.token});

  @override
  State<FileList> createState() {
    return _FileListState();
  }
}

class _FileListState extends State<FileList> {
  late Future<List<dynamic>> _files;

  @override
  void initState() {
    super.initState();
    _files = TaskServices().fetchFiles(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Files'),
      ),
      body: FutureBuilder<List<dynamic>>(
          future: _files,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No files uploaded yet.'),
              );
            } else {
              final files = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 15,
                  bottom: 15,
                ),
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final DateTime dateTime =
                        DateTime.parse(file['created_at']);
                    final String formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

                    return ListTile(
                      title: Text(file['name']),
                      subtitle: Text(
                        'Size: ${(int.parse(file['size']) / 1024).toStringAsFixed(2)} KB\n'
                        'Uploaded: $formattedDate', // File size and upload timestamp
                      ),
                      trailing: IconButton(
                          onPressed: () {}, icon: const Icon(Icons.download)),
                    );
                  },
                ),
              );
            }
          }),
    );
  }
}
