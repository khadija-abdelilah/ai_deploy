import 'package:ai_deploy/Services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reconnaissance Vocale avec Gemini',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: AudioRecorderPage(),
    );
  }
}

class AudioRecorderPage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AudioRecorderPage> {
  final SpeechToText _speechToText = SpeechToText();
  final GeminiService _geminiService = GeminiService('AIzaSyBTjoqC3-CU-hMJonWsADVRP9gOC9qwelw'); // Remplacez par votre clé API
  bool _speechEnabled = false;
  String _lastWords = '';
  String _geminiResponse = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initialiser la reconnaissance vocale
  void _initSpeech() async {
    bool hasPermission = await _speechToText.initialize();
    setState(() {
      _speechEnabled = hasPermission;
    });

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission du microphone refusée.')),
      );
    }
  }

  /// Commencer l'écoute avec vérification des permissions
  void _startListening() async {
    if (_speechEnabled && !_speechToText.isListening) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {});
    } else if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La reconnaissance vocale n\'est pas disponible.')),
      );
    }
  }

  /// Arrêter l'écoute et envoyer le texte à Gemini
  void _stopListening() async {
    await _speechToText.stop();
    _sendToGemini(_lastWords); // Envoyer le texte reconnu à Gemini
    setState(() {});
  }

  /// Gestion des résultats de la reconnaissance vocale
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  /// Envoyer le texte reconnu à Gemini pour générer une réponse
  void _sendToGemini(String prompt) async {
    if (prompt.isEmpty) {
      setState(() {
        _geminiResponse = 'Aucun texte à envoyer.';
      });
      return;
    }

    setState(() {
      _geminiResponse = 'Génération de la réponse...';
    });

    final response = await _geminiService.generateResponse(prompt);
    setState(() {
      _geminiResponse = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assistant Vocal avec Gemini'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Texte reconnu :',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _speechToText.isListening
                          ? _lastWords
                          : _speechEnabled
                          ? 'Appuyez sur "Start" pour commencer à écouter...'
                          : 'La reconnaissance vocale n\'est pas disponible.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // Zone pour afficher la réponse de Gemini
              if (_geminiResponse.isNotEmpty)
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Réponse Gemini : $_geminiResponse',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              // Boutons Start et Stop
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _speechToText.isListening ? null : _startListening,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      "Start",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _speechToText.isListening ? _stopListening : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      "Stop",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}