// File: voice_service.dart
import 'dart:async';
import 'package:flutter_wake_word/flutter_wake_word.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

class VoiceService {
  final stt.SpeechToText _speechOnline = stt.SpeechToText();
  KeyWordFlutterPC? _wakeWordDetector;
  StreamSubscription? _wakeWordSubscription;
  bool _isListeningOnline = false;

  final Function(String) onStatusChanged;

  VoiceService({required this.onStatusChanged});

  Future<void> inizializzaServizio() async {
    onStatusChanged("Inizializzazione microfono...");

    try {
      // 1. Inizializzazione Speech To Text Online
      bool onlineDisponibile = await _speechOnline.initialize(
        onError: (val) {
          onStatusChanged("Errore: ${val.errorMsg}");
          _ripristinaAscoltoOffline();
        },
        onStatus: (val) => onStatusChanged("Stato: $val"),
      );

      if (!onlineDisponibile) {
        onStatusChanged("Riconoscimento vocale non supportato.");
        return;
      }

      // 2. Inizializzazione motore offline per la parola chiave 'Kal'
      _wakeWordDetector = createKeyWordFlutterPCInstance('main');

      _wakeWordSubscription =
          _wakeWordDetector?.onVADDetectionEvent().listen((event) async {
        await _onPhraseDetected();
      });

      await _wakeWordDetector?.startVADDetection();
      onStatusChanged(
          "In ascolto... Pronuncia la parola chiave o tocca il microfono.");
    } catch (e) {
      onStatusChanged("Errore hardware: $e");
    }
  }

  // Azione triggerata dalla parola chiave 'Kal'
  Future<void> _onPhraseDetected() async {
    if (_isListeningOnline) return;
    await _wakeWordDetector?.stopVADDetection();
    await Future.delayed(const Duration(milliseconds: 350));
    _avviaAscoltoComandoOnline();
  }

  // AZIONE ASSOCIATA AL TOCCO DEL PULSANTE MICROFONO (Interruttore manuale/automatico)
  void forzaRilevamentoSimulato() async {
    if (_isListeningOnline) {
      // Se stai già parlando e ripremi, spegne e processa subito
      _disattivaMicrofonoEProcessa();
    } else {
      // Altrimenti forza l'apertura dell'ascolto
      await _wakeWordDetector?.stopVADDetection();
      _avviaAscoltoComandoOnline();
    }
  }

  void _avviaAscoltoComandoOnline() async {
    _isListeningOnline = true;
    onStatusChanged("Ascolto in corso... Parla ora.");

    await _speechOnline.listen(
      localeId: "it_IT",
      listenFor: const Duration(seconds: 8), // Tempo massimo totale per parlare
      pauseFor: const Duration(
          seconds:
              3), // SPEGNIMENTO AUTOMATICO: si chiude dopo 3 secondi di silenzio
      onResult: (result) async {
        String fraseCompleta = result.recognizedWords.toLowerCase();
        onStatusChanged("Hai detto: $fraseCompleta");

        if (result.finalResult) {
          _isListeningOnline = false;
          await _speechOnline.stop();
          await _apriNavigatoreDaTesto(fraseCompleta);
          await _ripristinaAscoltoOffline();
        }
      },
    );
  }

  void _disattivaMicrofonoEProcessa() async {
    if (!_isListeningOnline) return;
    _isListeningOnline = false;

    String ultimaFrase = _speechOnline.lastRecognizedWords.toLowerCase();
    await _speechOnline.stop();

    if (ultimaFrase.isNotEmpty) {
      await _apriNavigatoreDaTesto(ultimaFrase);
    }
    await _ripristinaAscoltoOffline();
  }

  Future<void> _ripristinaAscoltoOffline() async {
    _isListeningOnline = false;
    try {
      await _wakeWordDetector?.startVADDetection();
      onStatusChanged("In ascolto della parola chiave...");
    } catch (_) {}
  }

  Future<void> _apriNavigatoreDaTesto(String testo) async {
    if (testo.contains("portami in") || testo.contains("naviga verso")) {
      String indirizzo = "";

      if (testo.contains("portami in")) {
        indirizzo = testo.split("portami in").last.trim();
      } else {
        indirizzo = testo.split("naviga verso").last.trim();
      }

      if (indirizzo.isNotEmpty) {
        onStatusChanged("Apertura Waze...");
        final Uri wazeUri = Uri.parse(
            "https://waze.com{Uri.encodeComponent(indirizzo)}&navigate=yes");

        if (await canLaunchUrl(wazeUri)) {
          await launchUrl(wazeUri, mode: LaunchMode.externalApplication);
        } else {
          onStatusChanged("Errore: Impossibile avviare Waze.");
        }
      }
    }
  }

  void dispose() {
    _wakeWordSubscription?.cancel();
    try {
      _wakeWordDetector?.stopVADDetection();
    } catch (_) {}
    try {
      _speechOnline.stop();
    } catch (_) {}
  }
}
