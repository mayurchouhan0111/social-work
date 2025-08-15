import 'package:flutter/material.dart';

class MainNavPage extends StatelessWidget {
  const MainNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Navigation')),
      body: const Center(
        child: Text('Main Navigation Page'),
      ),
    );
  }
}