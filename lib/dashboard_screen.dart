// File: lib/dashboard_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'config.dart';
import 'meteo.dart';
import 'news.dart';
import 'player.dart';
import 'titolo.dart';
import 'visore.dart';
import 'drive_info.dart'; // Importa il nuovo file della telemetria

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
          backgroundColor: const Color(0xff06090e),
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
                  borderSide: BorderSide(color: Color(0xffff0033))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white60),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffff0033)),
              onPressed: () async {
                await ConfigManager.save(
                    logoController.text, _mp3Path, _mp4Path);
                if (!mounted) return;
                Navigator.pop(context);
                _loadConfig();
              },
              child: const Text("Salva", style: TextStyle(color: Colors.white)),
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
    if (mounted) {
      setState(() {
        _timeString =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        _dayString =
            "${giorni[now.weekday - 1]} $giornoNum/$meseNum/${now.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            // BARRA VERTICALE SINISTRA
            Container(
              width: 55,
              decoration: const BoxDecoration(
                color: Color(0xff06090e),
                border: Border(
                    right: BorderSide(color: Color(0xffff0033), width: 1)),
              ),
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
                ],
              ),
            ),
            // CORPO CENTRALE CRUSCOTTO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.black,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Align(
                              alignment: Alignment.center,
                              child: TitoloWidget()),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "🌐 $_dayString $_timeString",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontSize: 13,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        children: [
                          // COLONNA SINISTRA
                          Expanded(
                            flex: 22,
                            child: Column(
                              children: [
                                MeteoWidget(
                                    latitude: _latcondivisa,
                                    longitude: _lonCondivisa),
                                const SizedBox(height: 8),
                                const Expanded(child: DriveInfoWidget()),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // COLONNA CENTRALE (VISORE HUD)
                          Expanded(
                            flex: 34,
                            child: VisoreWidget(
                              onShortcutPressed: (source) {
                                _playerKey.currentState
                                    ?.externalSelectSource(source);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // COLONNA DESTRA
                          Expanded(
                            flex: 22,
                            child: Column(
                              children: [
                                CompactPlayerWidget(
                                    key: _playerKey, carLogo: _carLogo),
                                const SizedBox(height: 8),
                                const Expanded(child: NewsWidget()),
                              ],
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
}
