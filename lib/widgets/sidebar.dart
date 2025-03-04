import 'package:flutter/material.dart';
import 'dart:io';

class Sidebar extends StatelessWidget {
  final List<Directory> quickAccessDirs;
  final List<Directory> thisPCDirs;
  final Function(Directory) onDirectorySelected;

  const Sidebar({
    required this.quickAccessDirs,
    required this.thisPCDirs,
    required this.onDirectorySelected,
    Key? key,
  }) : super(key: key);

  Widget _buildSidebarItem(String title, IconData icon, Directory directory) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title),
      dense: true,
      onTap: () => onDirectorySelected(directory),
    );
  }

  Widget _buildSidebarSection(String title, List<Directory> directories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
        ...directories.map(
          (dir) => _buildSidebarItem(
            dir.path.split('/').last,
            _getFolderIcon(dir.path),
            dir,
          ),
        ),
      ],
    );
  }

  IconData _getFolderIcon(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.contains('download')) return Icons.download;
    if (lowerPath.contains('picture')) return Icons.image;
    if (lowerPath.contains('document')) return Icons.description;
    return Icons.folder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey.shade100,
      child: ListView(
        children: [
          _buildSidebarSection('Quick Access', quickAccessDirs),
          Divider(height: 1),
          _buildSidebarSection('This PC', thisPCDirs),
        ],
      ),
    );
  }
}
