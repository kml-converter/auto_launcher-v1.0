// File: lib/meteo.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MeteoWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const MeteoWidget({super.key, this.latitude, this.longitude});

  @override
  State<MeteoWidget> createState() => _MeteoWidgetState();
}

class _MeteoWidgetState extends State<MeteoWidget> {
  String _temperature = "28°C";
  String _condition = "Partly Cloudy";
  String _minMaxTemp = "H: 31°C  L: 22°C";

  // URL dell'immagine principale volumetrica ricca di gradazioni e riflessi
  String _currentIconUrl =
      "https://imgur.com"; // Sole lucido con nuvola 3D realistica

  // Lista previsioni a 4 giorni con icone ad alta definizione ricche di sfumature
  final List<Map<String, dynamic>> _forecast = [
    {
      "giorno": "FRI",
      "icona": "https://imgur.com", // Sole e nuvola lucida
      "temp": "31°/22°"
    },
    {
      "giorno": "SAT",
      "icona": "https://imgur.com", // Nuvola volumetrica grigio-azzurra
      "temp": "29°/21°"
    },
    {
      "giorno": "SUN",
      "icona": "https://imgur.com", // Sole lucido volumetrico oro
      "temp": "30°/22°"
    },
    {
      "giorno": "MON",
      "icona": "https://imgur.com", // Pioggia e fulmini 3D sfumati
      "temp": "28°/21°"
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.latitude != null && widget.longitude != null) {
      _getWeatherReal(widget.latitude!, widget.longitude!);
    }
  }

  @override
  void didUpdateWidget(covariant MeteoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != null && widget.longitude != null) {
      if (widget.latitude != oldWidget.latitude ||
          widget.longitude != oldWidget.longitude) {
        _getWeatherReal(widget.latitude!, widget.longitude!);
      }
    }
  }

  Future<void> _getWeatherReal(double lat, double lon) async {
    try {
      final url = Uri.parse('https://open-meteo.com');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double currentTemp = data['current']['temperature_2m'];
        final int code = data['current']['weather_code'];

        final double maxTemp = data['daily']['temperature_2m_max'];
        final double minTemp = data['daily']['temperature_2m_min'];

        _temperature = "${currentTemp.toStringAsFixed(0)}°C";
        _minMaxTemp =
            "H: ${maxTemp.toStringAsFixed(0)}°C  L: ${minTemp.toStringAsFixed(0)}°C";

        // Mappatura dinamica degli asset d'immagine ad alta sfumatura
        if (code == 0) {
          _condition = "Sunny";
          _currentIconUrl = "https://imgur.com"; // Sole 3D lucido oro puro
        } else if (code <= 3) {
          _condition = "Partly Cloudy";
          _currentIconUrl = "https://imgur.com"; // Sole con nuvola lucida gloss
        } else if (code <= 65) {
          _condition = "Rainy";
          _currentIconUrl = "https://imgur.com"; // Nuvola densa realistica
        } else {
          _condition = "Stormy";
          _currentIconUrl = "https://imgur.com"; // Temporale volumetrico
        }

        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff06090e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffff0033).withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffff0033).withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // INTESTAZIONE HUD CRUSCOTTO
          const Text(
            "WEATHER",
            style: TextStyle(
              color: Color(0xffff0033),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // IMMAGINE PRINCIPALE GLOSS AD ALTA DEFINIZIONE (Sostituisce il vecchio Icon piatto)
                  Image.network(
                    _currentIconUrl,
                    width: 65,
                    height: 65,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.wb_sunny_rounded,
                        size: 65,
                        color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _condition,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _minMaxTemp,
                        style: const TextStyle(
                            color: Color(0xffff0033),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                _temperature,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Roboto'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white10),
          const SizedBox(height: 12),
          // MINI CALENDARIO ORIZZONTALE CON IMMAGINI REALI SFUMATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _forecast.map((f) {
              return Column(
                children: [
                  Text(
                    f["giorno"],
                    style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  // Icona del giorno specifico caricata come immagine 3D
                  Image.network(
                    f["icona"],
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.wb_cloudy_rounded,
                        size: 26,
                        color: Colors.white24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    f["temp"],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
