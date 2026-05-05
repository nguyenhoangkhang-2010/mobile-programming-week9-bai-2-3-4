import 'dart:io';
import 'package:flutter/material.dart';
import '../models/my_contact.dart'; 
import '../services/database_helper.dart';
import 'add_contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MyContact> _allSqliteContacts = [];
  List<MyContact> _filteredSqliteContacts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final sqliteData = await DatabaseHelper.instance.getAllContacts();

      setState(() {
        _allSqliteContacts = sqliteData;
        _filteredSqliteContacts = sqliteData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredSqliteContacts = _allSqliteContacts.where((c) {
        return c.name.toLowerCase().contains(query.toLowerCase()) ||
               c.phone.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.deepPurple),
        title: const Text(
          "My Contacts",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddContactScreen()),
              );
              if (result == true) _refreshData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredSqliteContacts.isEmpty 
                    ? const Center(child: Text("Không có danh bạ nào"))
                    : ListView.builder(
                        itemCount: _filteredSqliteContacts.length,
                        itemBuilder: (context, index) {
                          final c = _filteredSqliteContacts[index];
                          return _buildContactItem(
                            name: c.name,
                            phone: c.phone,
                            imagePath: c.imagePath,
                            onEdit: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddContactScreen(contact: c)),
                              );
                              if (result == true) _refreshData();
                            },
                            onDelete: () => _showDeleteConfirm(c.id!),
                          );
                        },
                      ),
                ),
              ],
            ),
    );
  }

  Widget _buildContactItem({
    required String name,
    required String phone,
    String? imagePath,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage: (imagePath != null && imagePath.isNotEmpty) 
                ? FileImage(File(imagePath)) 
                : null,
            child: (imagePath == null || imagePath.isEmpty) 
                ? const Icon(Icons.person, color: Colors.white) 
                : null,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            phone,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                  onPressed: onEdit),
              IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                  onPressed: onDelete),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80, right: 20),
          child: Divider(height: 1, color: Colors.grey[300]),
        ),
      ],
    );
  }

  void _showDeleteConfirm(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa liên hệ này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteContact(id);
              Navigator.pop(ctx);
              _refreshData();
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}