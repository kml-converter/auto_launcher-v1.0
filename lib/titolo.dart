// File: lib/titolo.dart
import 'package:flutter/material.dart';

class TitoloWidget extends StatelessWidget {
  const TitoloWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BacinellaRacingPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Testo principale in BIANCO puro
            const Text(
              "AUTO LAUNCHER",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Colors.white, // Bianco puro splendente
                letterSpacing: 2.5,
              ),
            ),
            // Numerazione versione in ROSSO corsa
            const Text(
              " v1.0",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Color(0xffff0033), // Rosso neon numerico
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Disegna la bacinella geometrica cyberpunk con bordo rosso non continuo
class _BacinellaRacingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintSfondo = Paint()
      ..color = Colors.black // Sfondo nero interno alla bacinella
      ..style = PaintingStyle.fill;

    final paintBordo = Paint()
      ..color = const Color(0xffff0033) // Rosso corsa neon
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Coordinate per la forma a trapezio/bacinella simmetrica
    final path = Path();
    path.moveTo(0, 0); // Angolo alto a sinistra
    path.lineTo(20, size.height); // Taglio diagonale verso il basso sinistra
    path.lineTo(size.width - 20, size.height); // Base inferiore dritta
    path.lineTo(size.width, 0); // Risalita diagonale verso alto destra
    path.close();

    // 1. Disegna lo sfondo nero lucido
    canvas.drawPath(path, paintSfondo);

    // 2. Disegna i bordi segmentati (Non continui)
    // Segmento laterale sinistro inclinato + angolo
    final viaSinistra = Path();
    viaSinistra.moveTo(0, 0);
    viaSinistra.lineTo(20, size.height);
    viaSinistra.lineTo(60, size.height); // Si interrompe sulla base inferiore
    canvas.drawPath(viaSinistra, paintBordo);

    // Segmento laterale destro inclinato + angolo
    final viaDestra = Path();
    viaDestra.moveTo(size.width, 0);
    viaDestra.lineTo(size.width - 20, size.height);
    viaDestra.lineTo(
        size.width - 60, size.height); // Si interrompe sulla base inferiore
    canvas.drawPath(viaDestra, paintBordo);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
