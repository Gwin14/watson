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

  Widget _buildSidebarItem(String title, IconData icon, Directory directory) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title),
      dense: true,
      onTap: () => _navigateTo(directory),
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
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey.shade100,
            child: ListView(
              children: [
                _buildSidebarSection('Quick Access', quickAccessDirs),
                Divider(height: 1),
                _buildSidebarSection('This PC', thisPCDirs),
              ],
            ),
          ),
          VerticalDivider(width: 1),
          // Main Content
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
                          (context, index) => _buildGridViewItem(files[index]),
                    )
                    : ListView.builder(
                      itemCount: files.length,
                      itemBuilder:
                          (context, index) => _buildFileItem(files[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridViewItem(FileSystemEntity entity) {
    return GestureDetector(
      onTap: () {
        if (entity is Directory) {
          _navigateTo(entity);
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

  Widget _buildFileItem(FileSystemEntity entity) {
    return ListTile(
      leading: Icon(
        entity is Directory ? Icons.folder : Icons.insert_drive_file,
      ),
      title: Text(entity.path.split('/').last),
      onTap: () {
        if (entity is Directory) {
          _navigateTo(entity);
        } else {
          // Handle file tap
        }
      },
    );
  }

  // Mantenha os métodos restantes (_buildFileItem, _buildGridViewItem, etc) do código anterior
}
