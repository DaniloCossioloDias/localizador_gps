import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String _locationMessage = "Clique no botão para obter as coordenadas.";

  void getLocation() async {
    // Obter a posição atual do dispositivo
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Atualizar o estado com as coordenadasgit remote add origin https://github.com/DaniloCossioloDias/localizador_gps.git
    setState(() {
      _locationMessage = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });
  }git commit -m "Primeiro commit do projeto"


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Localizador GPS"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: getLocation,
                child: const Text("Obter Localização"),
              ),
              const SizedBox(height: 20),
              Text(
                _locationMessage,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
