// File: lib/Pages/CnnPage.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CnnPage extends StatefulWidget {
  const CnnPage({Key? key}) : super(key: key);

  @override
  _CnnPageState createState() => _CnnPageState();
}

class _CnnPageState extends State<CnnPage> {
  File? _imageFile;
  String? _prediction;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compression de l'image
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _prediction = null;
        });
      }
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Caméra'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getPrediction() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: votre logique
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _prediction = "Dog"; // Exemple
      });
    } catch (e) {
      print('Erreur lors de la prédiction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la prédiction: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classification CNN'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "CLASSIFICATION D'IMAGE",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _showImageSourceSelection,
              icon: const Icon(Icons.upload),
              label: const Text('Télécharger une Image'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            _imageFile != null
                ? Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _getPrediction,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Classer l\'Image'),
                  ),
                  const SizedBox(height: 20),
                  _prediction != null
                      ? Text(
                    'Prédiction: $_prediction',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : Container(),
                ],
              ),
            )
                : Container(),
          ],
        ),
      ),

      // Boutons pour naviguer
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            // Retour à la page ANN
            onPressed: () => Navigator.pushNamed(context, '/ann'),
            child: const Text('Aller à ANN'),
          ),
          ElevatedButton(
            // Vers l'assistant vocal
            onPressed: () => Navigator.pushNamed(context, '/assistant'),
            child: const Text('Aller à l\'Assistant'),
          ),
          ElevatedButton(
            // Vers la Home
            onPressed: () => Navigator.pushNamed(context, '/home'),
            child: const Text('Aller à Home'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
