import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class WazeWidget extends StatefulWidget {
  final Function(double lat, double lon)? onLocationChanged;
  const WazeWidget({super.key, this.onLocationChanged});

  @override
  State<WazeWidget> createState() => _WazeWidgetState();
}

class _WazeWidgetState extends State<WazeWidget> {
  final TextEditingController _searchController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _hintText = "Dove vuoi andare? Parla...";

  double _heading = 0.0;
  String _altitude = "000m";
  String _longitude = "0°00'00\"E";
  String _latitude = "0°00'00\"N";

  double _currentLat = 41.8902;
  double _currentLon = 12.4922;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initGPSCompass();
  }

  void _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (_) {}
  }

  void _initGPSCompass() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
        ),
      ).listen((Position position) {
        if (mounted) {
          setState(() {
            _heading = position.heading;
            _altitude = "${position.altitude.toStringAsFixed(0)}m";
            _latitude = "${position.latitude.toStringAsFixed(4)}°N";
            _longitude = "${position.longitude.toStringAsFixed(4)}°E";
            _currentLat = position.latitude;
            _currentLon = position.longitude;
          });
        }
        if (widget.onLocationChanged != null) {
          widget.onLocationChanged!(position.latitude, position.longitude);
        }
      });
    } catch (_) {
      _simulateLocationOnWeb();
    }
  }

  void _simulateLocationOnWeb() {
    if (mounted) {
      setState(() {
        _currentLat = 45.4642;
        _currentLon = 9.1900;
        _latitude = "45.4642°N";
        _longitude = "9.1900°E";
        _altitude = "120m";
      });
      if (widget.onLocationChanged != null) {
        widget.onLocationChanged!(_currentLat, _currentLon);
      }
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() {
              _hintText = "Dove vuoi andare? Parla...";
              _isListening = false;
            });
          }
        },
        onError: (val) => setState(() {
          _isListening = false;
        }),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _hintText = "🎙️ Ti ascolto...";
        });
        _speech.listen(
          localeId: "it_IT",
          onResult: (val) {
            setState(() {
              _searchController.text = val.recognizedWords;
              if (val.finalResult) {
                _sendDestinationToWaze(val.recognizedWords);
              }
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }

  Future<void> _sendDestinationToWaze(String address) async {
    if (address.trim().isEmpty) return;
    final String encodedAddress = Uri.encodeComponent(address);
    final Uri wazeUri = Uri.parse("https://waze.com");
    try {
      if (await canLaunchUrl(wazeUri)) {
        await launchUrl(wazeUri, mode: LaunchMode.externalApplication);
        _searchController.clear();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _WazeSearchPart(
            controller: _searchController,
            isListening: _isListening,
            hintText: _hintText,
            onMicPressed: _listen,
            onSubmitted: _sendDestinationToWaze,
          ),
          const SizedBox(height: 6),
          _WazeMapPart(lat: _currentLat, lon: _currentLon),
          const SizedBox(height: 6),
          const Divider(color: Colors.white10, thickness: 1, height: 1),
          const SizedBox(height: 4),
          _WazeInstrumentsPart(
            heading: _heading,
            altitude: _altitude,
            latitude: _latitude,
            longitude: _longitude,
          ),
        ],
      ),
    );
  }
}

class _WazeSearchPart extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final String hintText;
  final VoidCallback onMicPressed;
  final Function(String) onSubmitted;

  const _WazeSearchPart({
    required this.controller,
    required this.isListening,
    required this.hintText,
    required this.onMicPressed,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isListening ? Colors.redAccent : Colors.white10,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMicPressed,
            child: Icon(
              Icons.mic,
              color: isListening ? Colors.red : Colors.cyanAccent,
              size: 16,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: isListening ? Colors.redAccent : Colors.white38,
                  fontSize: 9,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}

class _WazeMapPart extends StatelessWidget {
  final double lat;
  final double lon;

  const _WazeMapPart({required this.lat, required this.lon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          color: Colors.black26,
          child: InkWell(
            onTap: () async {
              final Uri mapUri = Uri.parse("https://openstreetmap.org");
              if (await canLaunchUrl(mapUri)) {
                await launchUrl(mapUri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, color: Colors.cyanAccent, size: 24),
                SizedBox(height: 4),
                Text(
                  "APRI MAPPA STRADALE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "Clicca per visualizzare la mappa live",
                  style: TextStyle(color: Colors.white38, fontSize: 6.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WazeInstrumentsPart extends StatelessWidget {
  final double heading;
  final String altitude;
  final String latitude;
  final String longitude;

  const _WazeInstrumentsPart({
    required this.heading,
    required this.altitude,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.cyanAccent.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "N\nW   E\nS",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Transform.rotate(
                  angle: ((heading * math.pi) / 180) * -1,
                  child: const Icon(
                    Icons.navigation_rounded,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(14),
                1: FlexColumnWidth(1),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(children: [
                  const Icon(Icons.landscape, size: 10, color: Colors.white38),
                  _buildRowText("Alt: $altitude"),
                ]),
                const TableRow(
                    children: [SizedBox(height: 2), SizedBox(height: 2)]),
                TableRow(children: [
                  const Icon(Icons.my_location,
                      size: 10, color: Colors.white38),
                  _buildRowText("Lat: $latitude"),
                ]),
                const TableRow(
                    children: [SizedBox(height: 2), SizedBox(height: 2)]),
                TableRow(children: [
                  const Icon(Icons.explore, size: 10, color: Colors.white38),
                  _buildRowText("Lon: $longitude"),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
