import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Richiesto per caricare il file JSON dagli assets
import 'dart:convert'; // Richiesto per decodificare il JSON
import 'package:just_audio/just_audio.dart';
import 'package:android_intent_plus/android_intent.dart';

class CompactPlayerWidget extends StatefulWidget {
  final String carLogo;
  const CompactPlayerWidget({super.key, required this.carLogo});

  @override
  State<CompactPlayerWidget> createState() => CompactPlayerWidgetState();
}

class CompactPlayerWidgetState extends State<CompactPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _currentSource = "Nessuna";
  String _trackTitle = "unknown";
  String _artistName = "unknown";
  bool _isPlaying = false;
  List<Map<String, String>> _radioList = [];
  String? _selectedRadioUrl;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Carica le radio dal file JSON interno
  Future<void> _loadInternalRadios() async {
    try {
      final String response = await rootBundle.loadString('assets/radios.json');
      final List<dynamic> data = json.decode(response);

      List<Map<String, String>> temp = data.map((item) {
        return {
          'name': item['name'].toString(),
          'url': item['url'].toString(),
        };
      }).toList();

      setState(() {
        _radioList = temp;
      });
    } catch (e) {
      debugPrint("Errore nel caricamento del file JSON interno: $e");
      _loadDefaultBackupRadios();
    }
  }

  // CORREZIONE: Inseriti URL di streaming diretti, HTTPS e compatibili con le policy CORS del Web
  void _loadDefaultBackupRadios() {
    setState(() {
      _radioList = [
        {'name': 'Radio Ibiza (Web OK)', 'url': 'https://radionetz.de'},
        {'name': 'SomaFM Groove (Web OK)', 'url': 'https://somafm.com'},
        {'name': 'Swiss Jazz (Web OK)', 'url': 'https://srg-ssr.ch'},
      ];
    });
  }

  Future<void> _selectSource(String source) async {
    setState(() {
      _currentSource = source;
    });
    _audioPlayer.stop();

    if (source == "Spotify") {
      setState(() {
        _isPlaying = true;
        _trackTitle = "Spotify Active";
        _artistName = widget.carLogo;
      });
      _sendMediaIntent("PLAY_PAUSE");
    } else if (source == "WebRadio") {
      setState(() {
        _isPlaying = false;
        _trackTitle = "Scegli Radio";
        _artistName = "Web Streaming";
      });
      await _loadInternalRadios();
    }
  }

  void externalSelectSource(String source) {
    _selectSource(source);
  }

  Future<void> _playRadio(String url, String name) async {
    try {
      setState(() {
        _trackTitle = name;
        _artistName = "Connessione Web...";
        _selectedRadioUrl = url;
        _isPlaying = false;
      });

      await _audioPlayer.stop();

      // Configurazione ottimale per i flussi audio in streaming su HTML5 (Web)
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
        ),
      );

      _audioPlayer.play();

      setState(() {
        _isPlaying = true;
        _artistName = "Live Streaming Web";
      });
    } catch (e) {
      debugPrint("Errore di riproduzione Web: $e");
      setState(() {
        _artistName = "Errore CORS o URL";
        _isPlaying = false;
      });
    }
  }

  Future<void> _sendMediaIntent(String action) async {
    int keyCode = (action == "NEXT")
        ? 87
        : (action == "PREVIOUS")
            ? 88
            : 85;
    try {
      final intent = AndroidIntent(
          action: 'android.intent.action.MEDIA_BUTTON',
          arguments: <String, dynamic>{
            'android.intent.extra.KEY_EVENT': <String, dynamic>{
              'action': 0,
              'keyCode': keyCode
            }
          });
      await intent.launch();
    } catch (_) {}
  }

  void _togglePlay() {
    if (_currentSource == "Spotify") {
      _sendMediaIntent("PLAY_PAUSE");
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } else if (_currentSource == "WebRadio" && _selectedRadioUrl != null) {
      if (_isPlaying) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xff06090e), // Sfondo del riquadro scurissimo
        borderRadius:
            BorderRadius.circular(12), // Angoli arrotondati come nell'immagine
        border: Border.all(
          color: const Color(0xffff0033)
              .withOpacity(0.8), // Bordo Rosso Corsa Neon
          width: 1.5,
        ),
        boxShadow: [
          // Bagliore neon soffuso esterno tipico dei cruscotti sportivi
          BoxShadow(
            color: const Color(0xffff0033).withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _selectSource("Spotify"),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xff112936),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.music_note,
                  color: Colors.cyanAccent, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_trackTitle,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(_artistName,
                    style: const TextStyle(fontSize: 12, color: Colors.white38),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.skip_previous,
                            size: 20, color: Colors.white70),
                        onPressed: () => _sendMediaIntent("PREVIOUS")),
                    IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 20, color: Colors.white),
                        onPressed: _togglePlay),
                    IconButton(
                        icon: const Icon(Icons.skip_next,
                            size: 20, color: Colors.white70),
                        onPressed: () => _sendMediaIntent("NEXT")),
                    const SizedBox(width: 8),
                    // CORREZIONE: Chiusura corretta di tutta la struttura della UI del Dropdown e del Widget
                    if (_currentSource == "WebRadio" && _radioList.isNotEmpty)
                      Expanded(
                        child: DropdownButton<String>(
                          isDense: true,
                          hint: const Text("Radio",
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white38)),
                          dropdownColor: const Color(0xff161b22),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                          value: _selectedRadioUrl,
                          items: _radioList
                              .map((r) => DropdownMenuItem(
                                  value: r['url'],
                                  child: Text(r['name']!, maxLines: 1)))
                              .toList(),
                          onChanged: (url) {
                            if (url != null) {
                              final chosen =
                                  _radioList.firstWhere((e) => e['url'] == url);
                              _playRadio(url, chosen['name']!);
                            }
                          },
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
