import 'dart:async';
import 'package:flutter/material.dart';
import 'voice_service.dart';
import 'dashboard_screen.dart';

class SchermataPrincipale extends StatefulWidget {
  const SchermataPrincipale({super.key});

  @override
  _SchermataPrincipaleState createState() => _SchermataPrincipaleState();
}

class _SchermataPrincipaleState extends State<SchermataPrincipale> {
  String _statoSottoTitolo = "Inizializzazione...";
  late VoiceService _voiceService;

  @override
  void initState() {
    super.initState(); // Corretto

    _voiceService = VoiceService(
      onStatusChanged: (nuovoStato) {
        setState(() {
          _statoSottoTitolo = nuovoStato;
        });
      },
    );
    _voiceService.inizializzaServizio();

    // Transizione automatica alla dashboard dopo 3 secondi
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text("Assistente Vocale Cal"),
        backgroundColor: const Color(0xff161b22),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              _statoSottoTitolo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const DashboardScreen()),
                );
              },
              child: const Text("Vai alla Dashboard",
                  style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}
