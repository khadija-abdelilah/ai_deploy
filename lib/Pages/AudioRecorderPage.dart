import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ai_deploy/Services/gemini_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assistant Vocal avec Gemini',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: AudioRecorderPage(),
    );
  }
}

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final GeminiService _geminiService = GeminiService('AIzaSyBTjoqC3-CU-hMJonWsADVRP9gOC9qwelw');
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  List<Map<String, String>> _conversationHistory = [];
  List<String> _currentConversation = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _initSpeech() async {
    bool hasPermission = await _speechToText.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission denied.')),
      );
    }

    setState(() {
      _speechEnabled = hasPermission;
    });
  }

  void _startListening() async {
    if (_speechEnabled && !_speechToText.isListening) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {
        _isListening = true;
      });
      _animationController.repeat();
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _animationController.stop();
    _sendToGemini(_lastWords);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  void _sendToGemini(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() {
      _currentConversation.add('You: $prompt');
      _currentConversation.add('Génération de la réponse...');
    });

    try {
      final response = await _geminiService.generateResponse(prompt);
      setState(() {
        _currentConversation[_currentConversation.length - 1] = 'Gemini: $response';
      });
    } catch (e) {
      setState(() {
        _currentConversation[_currentConversation.length - 1] =
        'Erreur lors de la génération de la réponse.';
      });
    }
  }

  void _saveConversation() {
    setState(() {
      _conversationHistory.add({
        'title': 'Conversation ${_conversationHistory.length + 1}',
        'content': _currentConversation.join('\n'),
      });
      _currentConversation.clear();
    });
  }

  void _loadConversation(int index) {
    setState(() {
      _currentConversation = _conversationHistory[index]['content']!.split('\n');
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assistant Vocal avec Gemini', style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Historique des Conversations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _conversationHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.history, color: Colors.deepPurple),
                    title: Text(
                      _conversationHistory[index]['title']!,
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () => _loadConversation(index),
                  );
                },
              ),
            ),
            if (_conversationHistory.isEmpty)
              ListTile(
                title: Text('Aucune conversation enregistrée'),
              ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _currentConversation.length,
                itemBuilder: (context, index) {
                  final isUserMessage = _currentConversation[index].startsWith('You:');
                  return _buildChatBubble(_currentConversation[index], isUserMessage);
                },
              ),
            ),
            SizedBox(height: 10), // Add spacing before the buttons
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.05 * _animationController.value,
                    child: FloatingActionButton(
                      onPressed: _isListening ? _stopListening : _startListening,
                      backgroundColor: _isListening ? Colors.red : Colors.deepPurple,
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _saveConversation,
                child: Text('Enregistrer la Conversation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[900],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: isUser ? Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : Radius.circular(20),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
