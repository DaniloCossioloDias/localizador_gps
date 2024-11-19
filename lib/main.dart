import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String _locationMessage = "Clique no botão para obter as coordenadas."; // Mensagem inicial
  String _address = "Endereço não disponível."; // Endereço inicial

  // Função para obter localização e buscar endereço
  void getLocation() async {
    try {
      // Obter permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = "Permissão negada permanentemente.";
          _address = "Não foi possível acessar o endereço.";
        });
        return;
      }

      // Obter a localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _locationMessage =
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      });

      // Obter o endereço via Nominatim API
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['address'] != null) {
          final address = data['address'];
          setState(() {
            _address =
                "${address['road'] ?? 'Rua desconhecida'}, ${address['suburb'] ?? 'Bairro desconhecido'}, ${address['city'] ?? 'Cidade desconhecida'}, ${address['state'] ?? 'Estado desconhecido'}, ${address['country'] ?? 'País desconhecido'}";
          });
        } else {
          setState(() {
            _address = "Endereço não encontrado.";
          });
        }
      } else {
        setState(() {
          _address = "Erro ao buscar endereço (${response.statusCode}).";
        });
      }
    } catch (e) {
      print("Erro ao obter localização ou endereço: $e");
      setState(() {
        _locationMessage = "Erro ao obter localização.";
        _address = "Erro inesperado.";
      });
    }
  }

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
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                _address,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
