import 'package:flutter/material.dart';

class AnnPage extends StatelessWidget {
  const AnnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANN Page'),
      ),
      body: Center(
        child: const Text(
          'This is the ANN Page.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
