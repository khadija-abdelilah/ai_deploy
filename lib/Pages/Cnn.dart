import 'package:flutter/material.dart';

class CnnPage extends StatelessWidget {
  const CnnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CNN Page'),
      ),
      body: Center(
        child: const Text(
          'This is the CNN Page.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
