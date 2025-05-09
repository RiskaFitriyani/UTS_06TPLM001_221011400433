import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riska Fitriyani',
      debugShowCheckedModeBanner: false,
      home: const RiskaWeatherApp(),
    );
  }
}

class RiskaWeatherApp extends StatefulWidget {
  const RiskaWeatherApp({super.key});

  @override
  State<RiskaWeatherApp> createState() => _RiskaWeatherAppState();
}

class _RiskaWeatherAppState extends State<RiskaWeatherApp> {
  String kota = "Harap tunggu";
  double suhu = 0;
  double suhuRendah = 0;
  double suhuTinggi = 0;
  String cuaca = "Harap tunggu";
  String tanggal = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initLocationAndFetchWeather();
  }

  Future<void> _initLocationAndFetchWeather() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      _fetchWeather();
    } else {
      setState(() {
        kota = "Akses ditolak";
      });
    }
  }

  Future<void> _fetchWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      String apiKey = 'f373bfa1a9f89e6a280ed0b32849b605';
      String url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          kota = data['name'] ?? 'Unknown';
          suhu = data['main']['temp'].toDouble();
          suhuRendah = data['main']['temp_min'].toDouble();
          suhuTinggi = data['main']['temp_max'].toDouble();
          cuaca = data['weather'][0]['main'];
        });
      } else {
        setState(() {
          kota = "Gagal ambil data";
        });
      }
    } catch (e) {
      setState(() {
        kota = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg.jpeg', fit: BoxFit.cover),
          // ignore: deprecated_member_use
          Container(color: Colors.black.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  kota,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tanggal,
                  style: const TextStyle(fontSize: 22, color: Colors.white70),
                ),

                const SizedBox(height: 80),
                Text(
                  "${suhu.round()}°C",
                  style: const TextStyle(
                    fontSize: 80,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(color: Colors.white, thickness: 1.5),
                const SizedBox(height: 10),
                Text(
                  cuaca,
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${suhuRendah.round()}°C / ${suhuTinggi.round()}°C",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
