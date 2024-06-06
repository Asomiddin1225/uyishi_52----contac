import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uyishi_52/models/contac.dart';
import 'package:uyishi_52/services/contac_database/database_helper.dart';

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    List<Contact> contacts = await _databaseHelper.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  void _addContact() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactEditScreen(
          onSave: (contact) async {
            await _databaseHelper.insertContact(contact);
            _loadContacts();
          },
        ),
      ),
    );
  }

  void _editContact(Contact contact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactEditScreen(
          contact: contact,
          onSave: (updatedContact) async {
            await _databaseHelper.updateContact(updatedContact);
            _loadContacts();
          },
        ),
      ),
    );
  }

  void _deleteContact(int id) async {
    await _databaseHelper.deleteContact(id);
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    var contact;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Contacts'),
        backgroundColor: Colors.grey[400],
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Text(contact.phoneNumber),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editContact(contact),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteContact(contact.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addContact,
      ),
    );
  }
}

class ContactEditScreen extends StatefulWidget {
  final Contact? contact;
  final Function(Contact) onSave;

  ContactEditScreen({this.contact, required this.onSave});

  @override
  _ContactEditScreenState createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends State<ContactEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _name = widget.contact?.name ?? '';
    _phoneNumber = widget.contact?.phoneNumber ?? '';
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final contact = Contact(
        id: widget.contact?.id,
        name: _name,
        phoneNumber: _phoneNumber,
      );
      widget.onSave(contact);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null
            ? 'Yangi Contac yaratish'
            : "Contact o'zgartirish"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: "Ismi"),
                onSaved: (value) => _name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ismi";
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: InputDecoration(labelText: "Number"),
                onSaved: (value) => _phoneNumber = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Telegon Raqam Kirting";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveContact,
                child: Text('Sqalash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
