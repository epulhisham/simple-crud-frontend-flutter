import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/services/task_services.dart';

class FileUpload extends StatefulWidget {
  final String token;
  const FileUpload({super.key, required this.token});

  @override
  State<FileUpload> createState() {
    return _FileUploadState();
  }
}

class _FileUploadState extends State<FileUpload> {
  // File? _selectedFile;
  List<File> _selectedFiles = [];
  bool _isLoading = false;

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  void removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> uploadFiles() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      for (File file in _selectedFiles) {
        await TaskServices().uploadFile(widget.token, file);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Files Uploaded successfully!')),
      );

      setState(() {
        _selectedFiles.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload file'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFiles,
              child: const Text('Select files'),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    return ListTile(
                      title: Text(file.path.split('/').last),
                      trailing: IconButton(
                        onPressed: () => removeFile(index),
                        icon: const Icon(Icons.close),
                      ),
                    );
                  }),
            ),
            const SizedBox(
              height: 16,
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: uploadFiles,
                    child: const Text('Upload'),
                  ),
          ],
        ),
      ),
    );
  }
}
