// File: lib/drive_info.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class DriveInfoWidget extends StatefulWidget {
  const DriveInfoWidget({super.key});
  @override
  State<DriveInfoWidget> createState() => _DriveInfoWidgetState();
}

class _DriveInfoWidgetState extends State<DriveInfoWidget> {
  // Modifica questa velocità per testare la reazione cromatica di quadrante e lancetta (0-250)
  final double _velocitaCorrente = 135.0;

  final String _posizioneAttuale = "Via del Corso, Roma";
  final String _destinazioneImpostata = "Colosseo, Roma";

  final double _latitudine = 41.8902;
  final double _longitudine = 12.4922;
  final double _altitudine = 53.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xff05070b),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xffff0033).withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xffff0033).withValues(alpha: 0.12),
              blurRadius: 12,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TELEMETRIA DI GUIDA",
              style: TextStyle(
                  color: Color(0xffff0033),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5)),
          const SizedBox(height: 10),

          // 1. BLOCCO TRACK INFO
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("TRACK INFO",
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0)),
              const SizedBox(height: 2),
              Text(_posizioneAttuale,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis)),
              Text(
                  _destinazioneImpostata.isNotEmpty
                      ? "→ $_destinazioneImpostata"
                      : "→ No Target",
                  style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 10),

          // 2. RIQUADRO: GPS DATA SEPARATO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff0b0f17),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("GPS DATA",
                    style: TextStyle(
                        color: Color(0xffff0033),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("LAT: ${_latitudine.toStringAsFixed(4)}",
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold)),
                    Text("LON: ${_longitudine.toStringAsFixed(4)}",
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold)),
                    Text("HSLM: ${_altitudine.toStringAsFixed(0)}m",
                        style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const Expanded(child: SizedBox(height: 10)),

          // 3. TACHIMETRO MAESTOSO ENORME (Diametro 300 pixel)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(300, 190),
                  painter:
                      _TachimetroPremiumPainter(velocita: _velocitaCorrente),
                ),
                Positioned(
                  bottom: 35,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _velocitaCorrente.toStringAsFixed(0),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -1.0),
                      ),
                      const Text("KM/H",
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TachimetroPremiumPainter extends CustomPainter {
  final double velocita;
  _TachimetroPremiumPainter({required this.velocita});

  Color _ottieniColoreDaVelocita(double val) {
    if (val <= 80) return Colors.greenAccent;
    if (val <= 140) return Colors.yellowAccent;
    if (val <= 190) return Colors.orangeAccent;
    return const Color(0xffff0033);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width / 2;

    const double startAngle = 1.02 * math.pi;
    const double totalAngle = 0.96 * math.pi;

    final coronaPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        totalAngle, false, coronaPaint);

    const int numeroTacche = 25;
    for (int i = 0; i <= numeroTacche; i++) {
      double frazione = i / numeroTacche;
      double angoloTacca = startAngle + (frazione * totalAngle);
      double velocitaTacca = frazione * 250;

      bool isPrincipale = i % 5 == 0;
      double lunghezzaTacca = isPrincipale ? 14.0 : 7.0;

      final Color coloreTacca = _ottieniColoreDaVelocita(velocitaTacca);

      final taccaPaint = Paint()
        ..color =
            isPrincipale ? coloreTacca : coloreTacca.withValues(alpha: 0.35)
        ..strokeWidth = isPrincipale ? 3.0 : 1.5;

      double xEsterno = center.dx + (radius * math.cos(angoloTacca));
      double yEsterno = center.dy + (radius * math.sin(angoloTacca));
      double xInterno =
          center.dx + ((radius - lunghezzaTacca) * math.cos(angoloTacca));
      double yInterno =
          center.dy + ((radius - lunghezzaTacca) * math.sin(angoloTacca));

      canvas.drawLine(
          Offset(xInterno, yInterno), Offset(xEsterno, yEsterno), taccaPaint);

      if (isPrincipale) {
        // CORRETTO: Sostituito Math.round con il metodo nativo di Dart .round()
        int valoreVelocita = velocitaTacca.round();
        double xTesto = center.dx + ((radius - 28) * math.cos(angoloTacca));
        double yTesto = center.dy + ((radius - 28) * math.sin(angoloTacca));

        final textPainter = TextPainter(
          text: TextSpan(
            text: "$valoreVelocita",
            style: TextStyle(
                color: coloreTacca,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontFamily: 'monospace'),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        canvas.save();
        canvas.translate(xTesto, yTesto);
        textPainter.paint(
            canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        canvas.restore();
      }
    }

    double velocitaLimitata = velocita.clamp(0.0, 250.0);
    double frazioneVelocita = velocitaLimitata / 250.0;
    double angoloLancetta = startAngle + (frazioneVelocita * totalAngle);

    final Color coloreDinamicoLancetta =
        _ottieniColoreDaVelocita(velocitaLimitata);

    final sciaPaint = Paint()
      ..color = coloreDinamicoLancetta.withValues(alpha: 0.20)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
    double xPuntaScia = center.dx + ((radius - 10) * math.cos(angoloLancetta));
    double yPuntaScia = center.dy + ((radius - 10) * math.sin(angoloLancetta));
    canvas.drawLine(center, Offset(xPuntaScia, yPuntaScia), sciaPaint);

    final lancettaFisica = Paint()
      ..color = coloreDinamicoLancetta
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(xPuntaScia, yPuntaScia), lancettaFisica);

    canvas.drawCircle(center, 12.0, Paint()..color = const Color(0xff1a1f29));
    canvas.drawCircle(center, 8.0, Paint()..color = coloreDinamicoLancetta);
    canvas.drawCircle(center, 4.0, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _TachimetroPremiumPainter oldDelegate) =>
      oldDelegate.velocita != velocita;
}
