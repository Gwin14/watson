import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(FileManagerApp());
}

class FileManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FileExplorer(),
    );
  }
}

class FileExplorer extends StatefulWidget {
  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  Directory? currentDirectory;
  List<FileSystemEntity> files = [];
  String currentPath = '';
  bool isGridView = false;
  String sortBy = 'name';
  FileSystemEntity? selectedItem;

  @override
  void initState() {
    super.initState();
    _initDirectory();
  }

  Future<void> _initDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      currentDirectory = directory;
      currentPath = directory.path;
      _listFiles();
    });
  }

  void _listFiles() {
    setState(() {
      files =
          currentDirectory!.listSync()..sort(
            (a, b) =>
                sortBy == 'name'
                    ? a.path.compareTo(b.path)
                    : b.statSync().modified.compareTo(a.statSync().modified),
          );
    });
  }

  void _navigateTo(Directory dir) {
    setState(() {
      currentDirectory = dir;
      currentPath = dir.path;
      _listFiles();
    });
  }

  void _navigateBack() async {
    if (currentDirectory!.parent.path != currentDirectory!.path) {
      _navigateTo(currentDirectory!.parent);
    }
  }

  Widget _buildFileItem(FileSystemEntity file) {
    final isSelected = selectedItem == file;
    final stat = file.statSync();
    final isDirectory = stat.type == FileSystemEntityType.directory;
    final icon = isDirectory ? Icons.folder : Icons.insert_drive_file;
    final color = isSelected ? Colors.blue.shade100 : Colors.transparent;

    return ListTile(
      leading: Icon(icon, color: isDirectory ? Colors.blue : Colors.grey),
      title: Text(file.path.split('/').last),
      subtitle: Text(
        isDirectory
            ? 'Directory'
            : '${(stat.size / 1024).toStringAsFixed(2)} KB',
      ),
      trailing: Text(stat.modified.toString().split(' ')[0]),
      onTap: () {
        if (isDirectory) {
          _navigateTo(Directory(file.path));
        } else {
          setState(() => selectedItem = file);
        }
      },
      onLongPress: () => _showContextMenu(file),
      tileColor: color,
    );
  }

  Widget _buildGridViewItem(FileSystemEntity file) {
    final isDirectory = file.statSync().type == FileSystemEntityType.directory;

    return GridTile(
      child: InkWell(
        onTap: () => isDirectory ? _navigateTo(Directory(file.path)) : null,
        onLongPress: () => _showContextMenu(file),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDirectory ? Icons.folder : Icons.insert_drive_file,
              size: 50,
              color: isDirectory ? Colors.blue : Colors.grey,
            ),
            Text(file.path.split('/').last),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(FileSystemEntity file) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(file.path.split('/').last),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${file.statSync().type}'),
                Text('Size: ${file.statSync().size} bytes'),
                Text('Modified: ${file.statSync().modified}'),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  file.deleteSync();
                  _listFiles();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPath),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
          DropdownButton<String>(
            value: sortBy,
            items: [
              DropdownMenuItem(child: Text('Name'), value: 'name'),
              DropdownMenuItem(child: Text('Date'), value: 'date'),
            ],
            onChanged:
                (value) => setState(() {
                  sortBy = value!;
                  _listFiles();
                }),
          ),
        ],
      ),
      body:
          currentDirectory == null
              ? Center(child: CircularProgressIndicator())
              : isGridView
              ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                ),
                itemCount: files.length,
                itemBuilder:
                    (context, index) => _buildGridViewItem(files[index]),
              )
              : ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) => _buildFileItem(files[index]),
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create_new_folder),
        onPressed: () async {
          final newDir =
              await Directory('${currentDirectory!.path}/New Folder').create();
          _listFiles();
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                'Quick Access',
                style: TextStyle(color: Colors.white),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => _navigateTo(Directory(currentPath)),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Documents'),
              onTap:
                  () => _navigateTo(Directory('/storage/emulated/0/Documents')),
            ),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('Downloads'),
              onTap:
                  () => _navigateTo(Directory('/storage/emulated/0/Download')),
            ),
          ],
        ),
      ),
    );
  }
}
