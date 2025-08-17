
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treasurehunt/app/app_theme.dart';

class FeedbackReportPage extends StatefulWidget {
  final String itemId;

  const FeedbackReportPage({super.key, required this.itemId});

  @override
  _FeedbackReportPageState createState() => _FeedbackReportPageState();
}

class _FeedbackReportPageState extends State<FeedbackReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          Get.snackbar(
            'Error',
            'You must be logged in to submit.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        final type = _tabController.index == 0 ? 'feedback' : 'report';

        await FirebaseFirestore.instance.collection('feedback_reports').add({
          'itemId': widget.itemId,
          'userId': user.uid,
          'message': _messageController.text,
          'type': type,
          'status': 'new',
          'createdAt': FieldValue.serverTimestamp(),
        });

        Get.snackbar(
          'Success',
          'Your $type has been submitted.',
          backgroundColor: AppTheme.accent2,
          colorText: Colors.white,
        );

        _messageController.clear();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to submit. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          'Feedback & Report',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent2,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(),
          tabs: const [
            Tab(text: 'Feedback'),
            Tab(text: 'Report'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTextField(),
                    _buildTextField(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.accent2),
                    )
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _messageController,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter your message...',
        hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      maxLength: 1000,
      maxLines: 10,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Message cannot be empty.';
        }
        return null;
      },
    );
  }
}
