// File: lib/news.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class NewsWidget extends StatefulWidget {
  const NewsWidget({super.key});

  @override
  State<NewsWidget> createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  List<Map<String, String>> _feedNotizie = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _scaricaNotizieReali();
  }

  Future<void> _scaricaNotizieReali() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final List<Map<String, String>> notizieAggregate = [];

    // URL ufficiali dei Feed RSS
    final contattiFeed = [
      {"sorgente": "ANSA", "url": "https://ansa.it", "colore": "0xff00ffcc"},
      {
        "sorgente": "MILANO FINANZA",
        "url": "https://milanofinanza.it",
        "colore": "0xffffff00"
      }
    ];

    try {
      for (var feed in contattiFeed) {
        final risposta = await http
            .get(Uri.parse(feed["url"]!))
            .timeout(const Duration(seconds: 5));
        if (risposta.statusCode == 200) {
          final documento = xml.XmlDocument.parse(risposta.body);
          final elementi = documento.findAllElements('item');

          int contatore = 0;
          for (var nodo in elementi) {
            if (contatore >= 5)
              break; // Prendi le ultime 5 notizie per ogni fonte

            final titolo = nodo.findElements('title').first.innerText.trim();

            notizieAggregate.add({
              "fonte": feed["sorgente"]!,
              "colore": feed["colore"]!,
              "testo": titolo,
            });
            contatore++;
          }
        }
      }

      if (mounted) {
        setState(() {
          _feedNotizie = notizieAggregate;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Connessione assente. Controlla la rete del tablet.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.rss_feed, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "FEED NOTIZIE LIVE",
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon:
                    const Icon(Icons.refresh, color: Colors.white60, size: 18),
                onPressed: _scaricaNotizieReali,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Expanded(
                child: Center(
                    child: CircularProgressIndicator(color: Colors.redAccent)))
          else if (_errorMessage.isNotEmpty)
            Expanded(
                child: Center(
                    child: Text(_errorMessage,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13))))
          else
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _feedNotizie.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white10, height: 14),
                itemBuilder: (context, index) {
                  final item = _feedNotizie[index];
                  final coloreFonte = Color(int.parse(item["colore"]!));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: coloreFonte, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item["fonte"]!,
                            style: TextStyle(
                                color: coloreFonte,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["testo"]!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, height: 1.3),
                        softWrap: true,
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
