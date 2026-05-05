import 'dart:io';
import 'package:app_week_9_bai_2/models/my_contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_helper.dart';

class AddContactScreen extends StatefulWidget {
  final MyContact? contact;
  const AddContactScreen({super.key, this.contact});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phone;
      _emailController.text = widget.contact!.email;
      if (widget.contact!.imagePath != null) {
        _selectedImage = File(widget.contact!.imagePath!);
      }
    }
  }

  void _handleSave() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;

    final contactData = MyContact(
      id: widget.contact?.id,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      imagePath: _selectedImage?.path,
    );

    if (widget.contact == null) {
      await DatabaseHelper.instance.insertContact(contactData);
    } else {
      await DatabaseHelper.instance.updateContact(contactData);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contact == null ? "Thêm mới" : "Cập nhật")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (photo != null) setState(() => _selectedImage = File(photo.path));
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                child: _selectedImage == null ? const Icon(Icons.add_a_photo) : null,
              ),
            ),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Họ tên")),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Số điện thoại")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: Text(widget.contact == null ? "Lưu danh bạ" : "Cập nhật thay đổi"),
            )
          ],
        ),
      ),
    );
  }
}