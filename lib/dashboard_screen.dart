// File: lib/dashboard_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

// Importazioni dei componenti locali esterni
import 'config.dart';
import 'meteo.dart';
import 'news.dart';
import 'player.dart';
import 'titolo.dart';
import 'visore.dart';
import 'waze.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _timeString = "12:00";
  String _dayString = "Day";
  String _carLogo = "Caricamento...";
  String _mp3Path = "";
  String _mp4Path = "";

  double? _latcondivisa;
  double? _lonCondivisa;

  final GlobalKey<CompactPlayerWidgetState> _playerKey =
      GlobalKey<CompactPlayerWidgetState>();

  @override
  void initState() {
    super.initState();
    _loadConfig();
    Timer.periodic(const Duration(seconds: 1), (t) => _updateTime());
  }

  Future<void> _loadConfig() async {
    final data = await ConfigManager.load();
    if (mounted) {
      setState(() {
        _carLogo = data['logo'] ?? "Auto";
        _mp3Path = data['mp3'] ?? "";
        _mp4Path = data['mp4'] ?? "";
      });
    }
  }

  void _showSettingsDialog() {
    final TextEditingController logoController =
        TextEditingController(text: _carLogo);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff161b22),
          title: const Text("Impostazioni Cruscotto",
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: logoController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Nome Auto / Logo",
              labelStyle: TextStyle(color: Colors.white60),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white60),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
              onPressed: () async {
                await ConfigManager.save(
                    logoController.text, _mp3Path, _mp4Path);
                if (!mounted) return;
                Navigator.pop(context);
                _loadConfig();
              },
              child: const Text("Salva", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _updateTime() {
    final now = DateTime.now();
    final giorni = [
      "Lunedì",
      "Martedì",
      "Mercoledì",
      "Giovedì",
      "Venerdì",
      "Sabato",
      "Domenica"
    ];

    final giornoNum = now.day.toString().padLeft(2, '0');
    final meseNum = now.month.toString().padLeft(2, '0');
    final annoNum = now.year;

    if (mounted) {
      setState(() {
        _timeString =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        _dayString = "${giorni[now.weekday - 1]} $giornoNum/$meseNum/$annoNum";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      body: SafeArea(
        child: Row(
          children: [
            // 1. BARRA VERTICALE SINISTRA
            Container(
              width: 60,
              color: const Color(0xff161b22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: const Icon(Icons.home, color: Colors.white70),
                      onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.radio, color: Colors.white70),
                      onPressed: () {
                        _playerKey.currentState
                            ?.externalSelectSource("WebRadio");
                      }),
                  IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white70),
                      onPressed: _showSettingsDialog),
                  IconButton(
                      icon: const Icon(Icons.phone, color: Colors.white70),
                      onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.apps, color: Colors.white70),
                      onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.wb_sunny, color: Colors.white70),
                      onPressed: () {}),
                ],
              ),
            ),
            // 2. AREA CENTRALE DEL CRUSCOTTO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // BARRA DI STATO SUPERIORE - AGGIORNATA
                    // Sostituisci il Container della barra superiore con questo:
                    Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Colors.black, // Sfondo nero puro
                        border: Border(
                          bottom: BorderSide(
                            color: Color(
                                0xffff0033), // Linea rossa sportiva inferiore continua
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: TitoloWidget(),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "🌐 $_dayString  $_timeString",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors
                                    .white, // Ora il testo è bianco pulito come nell'immagine
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        children: [
                          // COLONNA SINISTRA: METEO, MINI PLAYER E RIQUADRO NEWS GENEROSO
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                MeteoWidget(
                                    latitude: _latcondivisa,
                                    longitude: _lonCondivisa),
                                const SizedBox(height: 12),
                                CompactPlayerWidget(
                                    key: _playerKey, carLogo: _carLogo),
                                const SizedBox(height: 12),
                                const Expanded(
                                  child: NewsWidget(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // COLONNA CENTRALE: VISORE MAPPA
                          Expanded(
                            flex: 3,
                            child: VisoreWidget(
                              onShortcutPressed: (source) {
                                _playerKey.currentState
                                    ?.externalSelectSource(source);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // COLONNA DESTRA: WAZE
                          Expanded(
                            flex: 2,
                            child: WazeWidget(
                              onLocationChanged: (lat, lon) {
                                setState(() {
                                  _latcondivisa = lat;
                                  _lonCondivisa = lon;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // <--- Questa è la parentesi di chiusura della classe che mancava
