import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VisoreWidget extends StatelessWidget {
  final Function(String) onShortcutPressed;

  const VisoreWidget({super.key, required this.onShortcutPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff161b22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(41.8902, 12.4922),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://openstreetmap.org{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.auto_launcher',
                      maxZoom: 18,
                      keepBuffer: 1,
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      // AGGIORNATO: Usato .withValues() per il nuovo SDK Flutter
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("0",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1)),
                        Text("MP/h",
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white60,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 70,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xff161b22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAppShortcut(
                  Icons.send_rounded, "Navigation", Colors.blueAccent, () {}),
              _buildAppShortcut(Icons.radio, "Radio", Colors.orangeAccent, () {
                onShortcutPressed("WebRadio");
              }),
              _buildAppShortcut(Icons.music_note, "Music", Colors.pink, () {
                onShortcutPressed("Spotify");
              }),
              _buildAppShortcut(Icons.bluetooth, "BT", Colors.lightBlue, () {}),
              _buildAppShortcut(
                  Icons.play_circle_fill, "Video", Colors.green, () {}),
              _buildAppShortcut(
                  Icons.photo, "Gallery", Colors.purpleAccent, () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppShortcut(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
