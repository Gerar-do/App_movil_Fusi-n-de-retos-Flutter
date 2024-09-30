import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Iterable<Contact>? _contacts;
  Map<String, dynamic>? _weatherData; // Mapa para almacenar los datos del clima
  final String cityName = 'Chiapas'; // Nombre de la ciudad para la consulta

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _fetchWeather(); // Llamada a la API del clima
  }

  Future<void> _fetchContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: true);
    setState(() {
      _contacts = contacts;
    });
  }

  // Función para obtener el clima de la API
  Future<void> _fetchWeather() async {
    final Uri url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=67791e5ac5dfb40e1118b40e3637f6a8&units=metric');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        _weatherData = jsonResponse; // Almacena los datos del clima
      });
    } else {
      setState(() {
        _weatherData = null; // Establece los datos a nulos si no se puede obtener
      });
    }
  }

  void _callContact(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  void _sendMessage(String phoneNumber) async {
    final Uri url = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contactos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Mostrar el clima
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _weatherData == null
                ? Center(child: CircularProgressIndicator()) // Mostrar carga mientras se obtienen los datos del clima
                : Column(
              children: [
                Text(
                  'Clima en ${_weatherData!['name']}',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                Text(
                  '${_weatherData!['main']['temp']}°C',
                  style: TextStyle(color: Colors.white, fontSize: 48),
                ),
                Text(
                  '${_weatherData!['weather'][0]['description']}',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          ),
          // Mostrar los contactos
          Expanded(
            child: _contacts == null
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _contacts!.length,
              itemBuilder: (context, index) {
                Contact contact = _contacts!.elementAt(index);

                return ListTile(
                  leading: contact.avatar != null && contact.avatar!.isNotEmpty
                      ? CircleAvatar(
                    backgroundImage: MemoryImage(contact.avatar!),
                    radius: 25,
                  )
                      : CircleAvatar(
                    child: Icon(Icons.person, color: Colors.blueAccent),
                    backgroundColor: Colors.white,
                    radius: 25,
                  ),
                  title: Text(
                    contact.displayName ?? '',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    contact.phones?.isNotEmpty == true
                        ? contact.phones!.first.value!
                        : 'Sin número',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailPage(
                          contact: contact,
                          onCall: _callContact,
                          onMessage: _sendMessage,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContactDetailPage extends StatelessWidget {
  final Contact contact;
  final Function(String) onCall;
  final Function(String) onMessage;

  ContactDetailPage({
    required this.contact,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.displayName ?? 'Detalles del contacto', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            contact.avatar != null && contact.avatar!.isNotEmpty
                ? ClipOval(
              child: Image.memory(
                contact.avatar!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            )
                : Icon(Icons.person, size: 100, color: Colors.white),
            SizedBox(height: 16),
            Text(
              contact.displayName ?? 'Sin nombre',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () {
                    if (contact.phones?.isNotEmpty == true) {
                      onCall(contact.phones!.first.value!);
                    }
                  },
                  iconSize: 40,
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.message),
                  color: Colors.blue,
                  onPressed: () {
                    if (contact.phones?.isNotEmpty == true) {
                      onMessage(contact.phones!.first.value!);
                    }
                  },
                  iconSize: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
