
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:treasurehunt/app/app_theme.dart';

class AdminFeedbackPage extends StatelessWidget {
  const AdminFeedbackPage({super.key});

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.exists && doc.data()?['role'] == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text('Admin - Feedbacks',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: FutureBuilder<bool>(
        future: _isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent2),
            ));
          }
          if (snapshot.data != true) {
            return Center(
              child: Text(
                'Access Denied',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 18),
              ),
            );
          }
          return _buildFeedbackList();
        },
      ),
    );
  }

  Widget _buildFeedbackList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedback_reports')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: GoogleFonts.inter(color: Colors.red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent2),
          ));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No feedback or reports found.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return _buildFeedbackCard(doc);
          },
        );
      },
    );
  }

  Widget _buildFeedbackCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String type = data['type'] ?? 'N/A';
    final String message = data['message'] ?? 'No message';
    final String userId = data['userId'] ?? 'N/A';
    final String status = data['status'] ?? 'new';
    final Timestamp? createdAt = data['createdAt'];
    final String formattedDate = createdAt != null
        ? DateFormat.yMMMd().add_jm().format(createdAt.toDate())
        : 'N/A';

    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: type == 'feedback' ? Colors.blue : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.inter(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'User: $userId',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
            const SizedBox(height: 4),
            Text(
              'Submitted: $formattedDate',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(doc),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.grey;
      case 'resolved':
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  Widget _buildActionButtons(DocumentSnapshot doc) {
    final String type = (doc.data() as Map<String, dynamic>)['type'];
    final String status = (doc.data() as Map<String, dynamic>)['status'];

    if (status != 'new') return const SizedBox.shrink();

    if (type == 'report') {
      return ElevatedButton(
        onPressed: () => _updateStatus(doc.id, 'resolved'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: Text('Resolve', style: GoogleFonts.inter()),
      );
    } else if (type == 'feedback') {
      return Row(
        children: [
          ElevatedButton(
            onPressed: () => _updateStatus(doc.id, 'approved'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Approve', style: GoogleFonts.inter()),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _updateStatus(doc.id, 'rejected'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject', style: GoogleFonts.inter()),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('feedback_reports')
          .doc(docId)
          .update({'status': newStatus});
      Get.snackbar(
        'Success',
        'Status updated to $newStatus',
        backgroundColor: AppTheme.accent2,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
