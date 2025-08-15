import 'package:flutter/material.dart';

class AdminFeedbackPage extends StatelessWidget {
  const AdminFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Feedbacks')),
      body: const Center(child: Text('List of feedbacks and reports goes here')),
    );
  }
}