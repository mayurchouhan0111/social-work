import 'package:flutter/material.dart';

class FeedbackReportPage extends StatelessWidget {
  final String itemId;

  const FeedbackReportPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback and Report')),
      body: Center(child: Text('Feedback for item $itemId')),
    );
  }
}