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
  Map<String, dynamic>? _weatherData;
  final String cityName = 'Chiapas';

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _fetchWeather();
  }

  Future<void> _fetchContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: true);
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _fetchWeather() async {
    final Uri url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=67791e5ac5dfb40e1118b40e3637f6a8&units=metric');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        _weatherData = jsonResponse;
      });
    } else {
      setState(() {
        _weatherData = null;
      });
    }
  }

  void _callContact(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _sendMessage(String phoneNumber) async {
    final Uri url = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openGitHubRepo() async {
    const String url = 'https://github.com/Gerar-do/App_movil_Fusi-n-de-retos-Flutter.git';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication); // Abre en el navegador externo
    } else {
      throw 'No se pudo abrir $url';
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
          // Mostrar el clima con un tamaño reducido
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _weatherData == null
                ? Center(child: CircularProgressIndicator())
                : Column(
              children: [
                Text(
                  'Clima en ${_weatherData!['name']}',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  '${_weatherData!['main']['temp']}°C',
                  style: TextStyle(color: Colors.white, fontSize: 36),
                ),
                Text(
                  '${_weatherData!['weather'][0]['description']}',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          // Tarjeta de perfil con nombre y matrícula
          Card(
            color: Colors.grey[900],
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('asset/img/perfil.jpg'),
                      radius: 30,
                    ),
                    title: Text(
                      'Gerardo Jafet Toledo Cañaveral',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Matrícula: 211228\nTeléfono: 9614425550',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.call, color: Colors.green),
                        onPressed: () => _callContact('9614425550'),
                      ),
                      IconButton(
                        icon: Icon(Icons.message, color: Colors.blue),
                        onPressed: () => _sendMessage('9614425550'),
                      ),
                      IconButton(
                        icon: Icon(Icons.link, color: Colors.blue),
                        onPressed: _openGitHubRepo,
                      ),
                    ],
                  ),
                ],
              ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
