import 'package:flutter/material.dart';

class RnnPage extends StatelessWidget {
  const RnnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RNN Page'),
      ),
      body: Center(
        child: const Text(
          'This is the RNN Page.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
