import 'package:flutter/material.dart';
import 'dart:io';

class FileItem extends StatelessWidget {
  final FileSystemEntity entity;
  final Function(Directory) onTap;

  const FileItem({required this.entity, required this.onTap, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        entity is Directory ? Icons.folder : Icons.insert_drive_file,
      ),
      title: Text(entity.path.split('/').last),
      onTap: () {
        if (entity is Directory) {
          onTap(entity as Directory);
        } else {
          // Handle file tap
        }
      },
    );
  }
}
