import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/file_item.dart';
import '../widgets/grid_view_item.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  Directory? currentDirectory;
  List<FileSystemEntity> files = [];
  String currentPath = '';
  bool isGridView = false;
  String sortBy = 'name';
  List<Directory> quickAccessDirs = [];
  List<Directory> thisPCDirs = [];

  @override
  void initState() {
    super.initState();
    _initDirectory();
    _loadSidebarItems();
  }

  Future<void> _initDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      currentDirectory = directory;
      currentPath = directory.path;
      _listFiles();
    });
  }

  Future<void> _loadSidebarItems() async {
    final List<Directory> quickAccess = [];
    final List<Directory> thisPC = [];

    // Quick Access
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) quickAccess.add(downloadsDir);

    final documentsDir = await getApplicationDocumentsDirectory();
    quickAccess.add(documentsDir);

    final picturesDir = Directory('/storage/emulated/0/Pictures');
    if (await picturesDir.exists()) quickAccess.add(picturesDir);

    // This PC
    final rootDir = Directory('/');
    thisPC.add(rootDir);

    setState(() {
      quickAccessDirs = quickAccess;
      thisPCDirs = thisPC;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPath),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
          DropdownButton<String>(
            value: sortBy,
            items: [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'date', child: Text('Date')),
            ],
            onChanged:
                (value) => setState(() {
                  sortBy = value!;
                  _listFiles();
                }),
          ),
        ],
      ),
      body: Row(
        children: [
          Sidebar(
            quickAccessDirs: quickAccessDirs,
            thisPCDirs: thisPCDirs,
            onDirectorySelected: _navigateTo,
          ),
          VerticalDivider(width: 1),
          Expanded(
            child:
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
                          (context, index) => GridViewItem(
                            entity: files[index],
                            onTap: _navigateTo,
                          ),
                    )
                    : ListView.builder(
                      itemCount: files.length,
                      itemBuilder:
                          (context, index) => FileItem(
                            entity: files[index],
                            onTap: _navigateTo,
                          ),
                    ),
          ),
        ],
      ),
    );
  }
}
