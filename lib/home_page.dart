
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class MyHomePage extends StatefulWidget {
  final Database database;

  const MyHomePage({required this.database});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> myData = [];
  bool _isLoading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _refreshData() async {
    final data = await DatabaseHelper.getItems(widget.database);
    setState(() {
      myData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> showMyForm(int? id) async {
    _titleController.text = '';
    _descriptionController.text = '';

    // If id is not null, fetch existing data
    if (id != null) {
      final existingData = myData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descriptionController.text = existingData['description'];
    }

    // Show modal bottom sheet for the form
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // prevent the soft keyboard from covering the text fields
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                // Save new data
                if (id == null) {
                  await addItem();
                }

                // Update existing data
                if (id != null) {
                  await updateItem(id);
                }

                // Clear the text fields
                _titleController.text = '';
                _descriptionController.text = '';

                // Close the bottom sheet
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create New' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addItem() async {
    await DatabaseHelper.createItem(
        widget.database, _titleController.text, _descriptionController.text);
    _refreshData();
  }

  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
        widget.database, id, _titleController.text, _descriptionController.text);
    _refreshData();
  }

  void deleteItem(int id) async {
    await DatabaseHelper.deleteItem(widget.database, id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted!'),
      backgroundColor: Colors.green,
    ));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite CRUD'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : myData.isEmpty
          ? const Center(child: Text("No Data Available!!!"))
          : ListView.builder(
        itemCount: myData.length,
        itemBuilder: (context, index) => Card(
          color: index % 2 == 0 ? Colors.green : Colors.green[200],
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Text(myData[index]['title']),
            subtitle: Text(myData[index]['description']),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showMyForm(myData[index]['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteItem(myData[index]['id']),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }
}
