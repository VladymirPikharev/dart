import 'dart:convert';
import 'dart:io';

class Contact {
  final String name;
  final String phone;

  Contact({required this.name, required this.phone});

  // Convert to JSON
  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};

  // Constructor for Contact from JSON
  static Contact fromJson(Map<String, dynamic> json) {
    return Contact(name: json['name'], phone: json['phone']);
  }
}

class ContactBook {
  final List<Contact> _contacts = [];
  final String filePath;
  final bool debug;
  final Function(String) logger;

  ContactBook({required this.filePath, this.debug = false, required this.logger}) {
    _loadContacts();
  }

  void _log(String message) {
    if (debug) {
      logger(message);
    }
  }

  // Load Contacts
  void _loadContacts() {
    _log('Loading contacts from $filePath');
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final contents = file.readAsStringSync();
        final jsonData = jsonDecode(contents) as List;
        _contacts.addAll(jsonData.map((json) => Contact.fromJson(json)).toList());
        _log('Loaded ${_contacts.length} contacts');
      }
    } catch (e) {
      _log('Failed to load contacts: $e');
    }
  }

  // Save contacts
  void _saveContacts() {
    _log('Saving contacts to $filePath');
    try {
      final file = File(filePath);
      final jsonData = jsonEncode(_contacts.map((contact) => contact.toJson()).toList());
      file.writeAsStringSync(jsonData);
      _log('Contacts saved');
    } catch (e) {
      _log('Failed to save contacts: $e');
    }
  }

  // Add new Contact
  void addContact(String name, String phone) {
    if (!phone.startsWith('+380') || phone.length != 13) {
      _log('Invalid phone number: $phone');
      print('Error: Invalid phone number. It should start with +380 and be 13 characters long.');
      return;
    }
    final contact = Contact(name: name, phone: phone);
    _contacts.add(contact);
    _saveContacts();
    _log('Added contact: $name, $phone');
  }

  // Show all contacts
  void showContacts() {
    _log('Showing contacts');
    if (_contacts.isEmpty) {
      print('No contacts found.');
    } else {
      for (final contact in _contacts) {
        print('Name: ${contact.name}, Phone: ${contact.phone}');
      }
    }
  }

  // Search Contacts
  void searchContacts(String query) {
    _log('Searching contacts for query: $query');
    final results = _contacts.where((contact) =>
    contact.name.contains(query) || contact.phone.contains(query));
    if (results.isEmpty) {
      print('No contacts found for query: $query');
    } else {
      for (final contact in results) {
        print('Name: ${contact.name}, Phone: ${contact.phone}');
      }
    }
  }

  // Remove Contact
  void removeContact(String query) {
    _log('Removing contact for query: $query');
    _contacts.removeWhere((contact) =>
    contact.name.contains(query) || contact.phone.contains(query));
    _saveContacts();
    _log('Removed contact(s) for query: $query');
  }
}

void main(List<String> arguments) {
  final logger = (String message) => print('DEBUG: $message');

  final contactBook = ContactBook(
    filePath: 'contacts.json',
    debug: arguments.contains('--debug'),
    logger: logger,
  );

  if (arguments.isEmpty) {
    print('No command provided.');
    return;
  }

  final command = arguments[0];
  switch (command) {
    case 'add':
      if (arguments.length != 3) {
        print('Usage: dart run contact_book.dart add <name> <phone>');
      } else {
        contactBook.addContact(arguments[1], arguments[2]);
      }
      break;
    case 'show':
      contactBook.showContacts();
      break;
    case 'search':
      if (arguments.length != 2) {
        print('Usage: dart run contact_book.dart search <query>');
      } else {
        contactBook.searchContacts(arguments[1]);
      }
      break;
    case 'remove':
      if (arguments.length != 2) {
        print('Usage: dart run contact_book.dart remove <query>');
      } else {
        contactBook.removeContact(arguments[1]);
      }
      break;
    default:
      print('Unknown command: $command');
      break;
  }
}
