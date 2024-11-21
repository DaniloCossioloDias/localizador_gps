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
  String _address = "Endereço não disponível.";
  String _weatherInfo = "Informações do clima não disponíveis.";
  String _temperature = "Temperatura não disponível.";

  // Outras funções permanecem iguais (getLocation, getAddress, getWeather)
  void getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _address = "Não foi possível acessar o endereço.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Obtendo o endereço
      await getAddress(position.latitude, position.longitude);

      // Obtendo informações do clima
      await getWeather(position.latitude, position.longitude);
    } catch (e) {
      print("Erro ao obter localização ou endereço: $e");
      setState(() {
        _address = "Erro inesperado.";
        _weatherInfo = "Informações do clima não disponíveis.";
        _temperature = "Temperatura não disponível.";
      });
    }
  }

  Future<void> getAddress(double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';
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
  }

  Future<void> getWeather(double latitude, double longitude) async {
    const apiKey = 'ac656d1d03be8dd2533850936f86f59b';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _temperature = "${data['main']['temp']}°C";
        _weatherInfo = "${data['weather'][0]['description']}";
      });
    } else {
      setState(() {
        _weatherInfo = "Erro ao buscar clima (${response.statusCode}).";
        _temperature = "Erro ao obter temperatura.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue, Colors.indigo],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _temperature,
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _weatherInfo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _address,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: getLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Substitui "primary"
                    foregroundColor: Colors.blue, // Substitui "onPrimary"
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  child: const Text("Atualizar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}