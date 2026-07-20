// File: lib/player.dart - STEP 1
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';

class CompactPlayerWidget extends StatefulWidget {
  final String carLogo;
  const CompactPlayerWidget({super.key, required this.carLogo});

  @override
  State<CompactPlayerWidget> createState() => CompactPlayerWidgetState();
}

class CompactPlayerWidgetState extends State<CompactPlayerWidget> {
  String _currentSource = "Media Player";
  String _trackTitle = "Seleziona Sorgente";
  String _trackArtist = "Tocca un'icona sotto";
  bool _isPlaying = false;
  bool _showRadioList = false;

  final List<Map<String, String>> _stazioniRadio = [
    {"nome": "Radio Rock", "frequenza": "90.3 MHz"},
    {"nome": "Virgin Radio", "frequenza": "104.5 MHz"},
    {"nome": "Radio 105", "frequenza": "105.1 MHz"},
    {"nome": "RTL 102.5", "frequenza": "102.5 MHz"},
  ];

  void externalSelectSource(String source) {
    setState(() {
      _currentSource = source;
      _showRadioList = (source == "WebRadio");
      if (source == "WebRadio") {
        _trackTitle = _stazioniRadio[0]["nome"]!;
        _trackArtist = _stazioniRadio[0]["frequenza"]!;
      }
    });
  }

  void _apriSpotify() async {
    setState(() {
      _currentSource = "Spotify";
      _trackTitle = "Spotify Streaming";
      _trackArtist = "Controllo Remoto Attivo";
      _showRadioList = false;
    });
    if (kIsWeb) {
      debugPrint("Simulazione: Apertura Spotify su Tablet");
      return;
    }
    const intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: 'com.spotify.music',
    );
    try {
      await intent.launch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Spotify non installato su questo tablet")),
      );
    }
  }

  void _apriMusicaLocale() async {
    setState(() {
      _currentSource = "Local MP3";
      _trackTitle = "Archivio Musicale";
      _trackArtist = "Memoria Interna Tablet";
      _showRadioList = false;
    });
    if (kIsWeb) {
      debugPrint("Simulazione: Apertura Lettore MP3 Locale");
      return;
    }
    const intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      type: 'audio/*',
    );
    try {
      await intent.launch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Nessun lettore musicale predefinito trovato")),
      );
    }
  }

// File: lib/player.dart - STEP 2
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xff05070b),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffff0033).withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffff0033).withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "AUDIO MANAGER",
                style: TextStyle(
                    color: Color(0xffff0033),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xff0b0f17),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(
                  _currentSource.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 46,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xff0b0f17),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Icon(
                    _showRadioList
                        ? Icons.radio_rounded
                        : Icons.audiotrack_rounded,
                    color: const Color(0xffff0033),
                    size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_trackTitle,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(_trackArtist,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
// File: lib/player.dart - STEP 3
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff1db954).withValues(alpha: 0.12),
                    foregroundColor: const Color(0xff1db954),
                    side: const BorderSide(color: Color(0xff1db954), width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _apriSpotify,
                  child: const Text("SPOTIFY",
                      style:
                          TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.withValues(alpha: 0.12),
                    foregroundColor: Colors.cyanAccent,
                    side: const BorderSide(color: Colors.cyan, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _apriMusicaLocale,
                  child: const Text("LOCAL MP3",
                      style:
                          TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withValues(alpha: 0.12),
                    foregroundColor: Colors.orangeAccent,
                    side: const BorderSide(color: Colors.orange, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => externalSelectSource("WebRadio"),
                  child: const Text("RADIO",
                      style:
                          TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_showRadioList) ...[
            Container(
              height: 32,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _stazioniRadio.length,
                itemBuilder: (context, index) {
                  final rad = _stazioniRadio[index];
                  bool isSelezionata = (_trackTitle == rad["nome"]);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _trackTitle = rad["nome"]!;
                        _trackArtist = rad["frequenza"]!;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSelezionata
                            ? const Color(0xffff0033).withValues(alpha: 0.2)
                            : const Color(0xff0b0f17),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: isSelezionata
                                ? const Color(0xffff0033)
                                : Colors.white10),
                      ),
                      child: Center(
                        child: Text(
                          rad["nome"]!,
                          style: TextStyle(
                              color:
                                  isSelezionata ? Colors.white : Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          Container(height: 1, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded,
                    color: Colors.white60, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: Colors.white,
                    size: 34),
                onPressed: () => setState(() => _isPlaying = !_isPlaying),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded,
                    color: Colors.white60, size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
