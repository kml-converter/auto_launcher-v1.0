// File: lib/meteo.dart - STEP 1
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
  String _temperature = "28°";
  String _condition = "Partly Cloudy";
  String _minMaxTemp = "H: 31°  L: 22°";
  String _currentIconAsset = "assets/sole_nuvola_3d.png";

  // Questa lista ora si autocompila dinamicamente via codice
  List<Map<String, dynamic>> _forecast = [];

  @override
  void initState() {
    super.initState();
    _calcolaGiorniPrevisioni(); // Calcola subito i 4 giorni reali successivi ad oggi
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

  // Genera i nomi corretti dei prossimi 4 giorni in base alla data odierna del tablet
  void _calcolaGiorniPrevisioni() {
    final oraInAuto = DateTime.now();
    final stringheGg = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    final List<Map<String, dynamic>> listaTemporanea = [];

    for (int i = 1; i <= 4; i++) {
      // Prende il giorno successivo (+1, +2, +3, +4)
      final giornoFuturo = oraInAuto.add(Duration(days: i));
      final nomeGiornoFiltrato = stringheGg[giornoFuturo.weekday % 7];

      listaTemporanea.add({
        "giorno": nomeGiornoFiltrato,
        "icona":
            "assets/sole_nuvola_3d.png", // Default prima del caricamento di rete
        "temp": "--°/--°"
      });
    }

    setState(() {
      _forecast = listaTemporanea;
    });
  }

  Future<void> _getWeatherReal(double lat, double lon) async {
    try {
      final url = Uri.parse('https://open-meteo.com');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 1. Dati correnti del cruscotto
        final double currentTemp = data['current']['temperature_2m'];
        final int code = data['current']['weather_code'];
        final double maxTempToday = data['daily']['temperature_2m_max'][0];
        final double minTempToday = data['daily']['temperature_2m_min'][0];

        _temperature = "${currentTemp.toStringAsFixed(0)}°";
        _minMaxTemp =
            "H: ${maxTempToday.toStringAsFixed(0)}°  L: ${minTempToday.toStringAsFixed(0)}°";
        _currentIconAsset = _associaIconaMeteo(code);

        // 2. Calcolo dinamico dei 4 giorni successivi reali presi dal server
        final oraInAuto = DateTime.now();
        final stringheGg = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        final List<Map<String, dynamic>> nuovaListaForecast = [];

        for (int i = 1; i <= 4; i++) {
          final giornoFuturo = oraInAuto.add(Duration(days: i));
          final nomeGiornoFiltrato = stringheGg[giornoFuturo.weekday % 7];

          final int codiceMeteoGiorno = data['daily']['weather_code'][i];
          final double maxGg = data['daily']['temperature_2m_max'][i];
          final double minGg = data['daily']['temperature_2m_min'][i];

          nuovaListaForecast.add({
            "giorno": nomeGiornoFiltrato,
            "icona": _associaIconaMeteo(codiceMeteoGiorno),
            "temp": "${maxGg.toStringAsFixed(0)}°/${minGg.toStringAsFixed(0)}°"
          });
        }

        if (mounted) {
          setState(() {
            _forecast = nuovaListaForecast;
            if (code == 0)
              _condition = "Sunny";
            else if (code <= 3)
              _condition = "Partly Cloudy";
            else if (code <= 65)
              _condition = "Rainy";
            else
              _condition = "Stormy";
          });
        }
      }
    } catch (_) {}
  }

  // Associa i codici Open-Meteo ai tuoi file 123x123 locali salvati negli assets
  String _associaIconaMeteo(int code) {
    if (code == 0) return "assets/sole_3d.png";
    if (code <= 3) return "assets/sole_nuvola_3d.png";
    if (code <= 65) return "assets/nuvola_3d.png";
    return "assets/temporale_3d.png";
  }

// File: lib/meteo.dart - STEP 2
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff05070b),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xffff0033).withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xffff0033).withValues(alpha: 0.12),
              blurRadius: 12,
              spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "WEATHER STATION",
            style: TextStyle(
                color: Color(0xffff0033),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset(
                      _currentIconAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.wb_sunny_rounded,
                          size: 50,
                          color: Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_condition,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_minMaxTemp,
                          style: const TextStyle(
                              color: Color(0xffff0033),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
              Text(_temperature,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white10),
          const SizedBox(height: 10),

          // Genera i widget per i 4 giorni futuri leggendo la lista autocompilata
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _forecast.map((f) {
              return Column(
                children: [
                  Text(f["giorno"],
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Image.asset(
                    f["icona"],
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.wb_cloudy_rounded,
                        size: 24,
                        color: Colors.white24),
                  ),
                  const SizedBox(height: 6),
                  Text(f["temp"],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
