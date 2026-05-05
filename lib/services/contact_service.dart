import 'package:app_week_9_bai_2/models/my_contact.dart';
import 'database_helper.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';

class ContactService {
  Future<List<MyContact>> getStoredContacts() async {
    return await DatabaseHelper.instance.getAllContacts();
  }

  Future<void> saveContact(MyContact contact) async {
    await DatabaseHelper.instance.insertContact(contact);
  }

  Future<List<ContactInfo>> getDeviceContacts() async {
    return await FlutterContactsService.getContacts();
  }
}