// File: lib/Pages/AudioRecorderPage.dart

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ai_deploy/Services/gemini_service.dart';

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final GeminiService _geminiService =
  GeminiService('YOUR_GEMINI_API_KEY'); // <-- Insert your key or handle it securely

  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  // We'll store the conversation as a list of messages (Strings).
  // You can store them in Firestore or locally if needed.
  List<String> _currentConversation = [];
  // Or store multiple conversation histories:
  List<Map<String, String>> _conversationHistory = [];

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

  @override
  void dispose() {
    _speechToText.stop();
    _animationController.dispose();
    super.dispose();
  }

  // Initialize speech recognition
  void _initSpeech() async {
    bool hasPermission = await _speechToText.initialize(
      onStatus: (status) => debugPrint('SpeechToText status: $status'),
      onError: (error) => debugPrint('SpeechToText error: $error'),
    );

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied.')),
      );
    }
    setState(() {
      _speechEnabled = hasPermission;
    });
  }

  // Start listening to voice
  void _startListening() async {
    if (_speechEnabled && !_speechToText.isListening) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {
        _isListening = true;
      });
      _animationController.repeat();
    }
  }

  // Stop listening
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _animationController.stop();
    // Send last recognized words to the Gemini model
    _sendToGemini(_lastWords);
  }

  // Callback for speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  // Send recognized text to Gemini and get a response
  void _sendToGemini(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() {
      _currentConversation.add('You: $prompt');
      _currentConversation.add('Génération de la réponse...');
    });

    try {
      final response = await _geminiService.generateResponse(prompt);
      setState(() {
        // Replace the last placeholder with the actual Gemini response
        _currentConversation[_currentConversation.length - 1] = 'Gemini: $response';
      });
    } catch (e) {
      setState(() {
        _currentConversation[_currentConversation.length - 1] =
        'Erreur lors de la génération de la réponse.';
      });
    }
  }

  // Save the current conversation, then clear it
  void _saveConversation() {
    setState(() {
      _conversationHistory.add({
        'title': 'Conversation ${_conversationHistory.length + 1}',
        'content': _currentConversation.join('\n'),
      });
      _currentConversation.clear();
    });
  }

  // Load a saved conversation from _conversationHistory
  void _loadConversation(int index) {
    setState(() {
      _currentConversation = _conversationHistory[index]['content']!.split('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Vocal avec Gemini', style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
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
                    leading: const Icon(Icons.history, color: Colors.deepPurple),
                    title: Text(
                      _conversationHistory[index]['title']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context); // close drawer
                      _loadConversation(index);
                    },
                  );
                },
              ),
            ),
            if (_conversationHistory.isEmpty)
              const ListTile(
                title: Text('Aucune conversation enregistrée'),
              ),

            const Divider(),
            // Optional navigation in the Drawer:
            ListTile(
              leading: const Icon(Icons.image, color: Colors.deepPurple),
              title: const Text('Aller à ANN'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ann');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: Colors.deepPurple),
              title: const Text('Aller à CNN'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cnn');
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.deepPurple),
              title: const Text('Aller à Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: <Widget>[
            // Conversation area
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _currentConversation.length,
                itemBuilder: (context, index) {
                  final message = _currentConversation[index];
                  final isUserMessage = message.startsWith('You:');
                  return _buildChatBubble(message, isUserMessage);
                },
              ),
            ),
            const SizedBox(height: 10),
            // Microphone button with animation
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
            // Save conversation button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _saveConversation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Enregistrer la Conversation'),
              ),
            ),
            const SizedBox(height: 20),

            // Row of navigation buttons (ANN, CNN, Home) if you want them here
            // (You can also use the Drawer approach above)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/ann'),
                  child: const Text('Aller à ANN'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/cnn'),
                  child: const Text('Aller à CNN'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                  child: const Text('Aller à Home'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // A helper widget to build a chat bubble
  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[900],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
