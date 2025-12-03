import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class ContactModel {
  final String id;
  final String? name;
  final String? phoneNumber;

  ContactModel({this.name, this.phoneNumber}) : id = Uuid().v4();
}

class ContactBook extends ValueNotifier<List<ContactModel>> {
  ContactBook._() : super([]);
  static final ContactBook _shared = ContactBook._();
  factory ContactBook() => _shared;
  int get contactsCount => value.length;

  void addContact(ContactModel contact) {
    value.add(contact);
    notifyListeners();
  }

  void removeContact(ContactModel contact) {
    value.contains(contact) ? value.remove(contact) : null;
    notifyListeners();
  }

  ContactModel? showContact(int index) =>
      value.length > index ? value[index] : null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: HomePage(),
      routes: {'/new-contact': (context) => NewContactView()},
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Contacts', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new-contact');
        },
        child: Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: ContactBook(),
        builder: (context, value, child) {
          final contact = value as List<ContactModel>;
          return ListView.builder(
            itemCount: contact.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey(contact[index].id),
                onDismissed: (direction) {
                  ContactBook().removeContact(contact[index]);
                },
                child: ListTile(
                  title: Text(
                    contact[index].name ?? '',
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    contact[index].phoneNumber ?? '',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  late final TextEditingController _nameController;
  late final GlobalKey<FormState> _formState;

  @override
  void initState() {
    _nameController = TextEditingController();
    _formState = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Contact')),
      body: Form(
        key: _formState,
        child: Column(
          children: [
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter contact name',
              ),
            ),
            TextButton(
              onPressed: () {
                final contact = ContactModel(name: _nameController.text);
                if (_formState.currentState!.validate()) {
                  ContactBook().addContact(contact);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
