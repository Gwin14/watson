import 'package:flutter/material.dart';
import 'dart:io';

class GridViewItem extends StatelessWidget {
  final FileSystemEntity entity;
  final Function(Directory) onTap;

  const GridViewItem({required this.entity, required this.onTap, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (entity is Directory) {
          onTap(entity as Directory);
        } else {
          // Handle file tap
        }
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              entity is Directory ? Icons.folder : Icons.insert_drive_file,
              size: 50,
            ),
            Text(
              entity.path.split('/').last,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
