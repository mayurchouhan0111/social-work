import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasurehunt/app/controllers/item_claims_controller.dart';
import 'package:treasurehunt/app/models/claim_model.dart';
import 'package:treasurehunt/app/app_theme.dart';

class ItemClaimsPage extends StatelessWidget {
  const ItemClaimsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ItemClaimsController());
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accent2.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppTheme.accent1,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent2, AppTheme.accent1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent2.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                color: AppTheme.primaryText,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item Claims',
                  style: GoogleFonts.archivo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText,
                  ),
                ),
                Text(
                  'Manage claims',
                  style: GoogleFonts.archivo(
                    fontSize: 12,
                    color: AppTheme.accent1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.accent2.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background,
              Color(0xFF0A0A0A),
              AppTheme.background,
            ],
          ),
        ),
        child: Obx(() {
          if (controller.claims.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.claims.length,
            itemBuilder: (context, index) {
              final claim = controller.claims[index];
              return _buildClaimCard(controller, claim);
            },
          );
        }),
      ),
    );
  }

  Widget _buildClaimCard(ItemClaimsController controller, ClaimModel claim) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accent2.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.surface.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accent2, AppTheme.accent1],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppTheme.primaryText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Claim from: ${claim.claimerId}',
                        style: GoogleFonts.archivo(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(claim.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          claim.status.toUpperCase(),
                          style: GoogleFonts.archivo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(claim.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Answers Section
            if (claim.answers.isNotEmpty) ...[
              Text(
                'Answers:',
                style: GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accent2.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildAnswers(claim.answers),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.approveClaim(claim),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primaryText,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Approve',
                          style: GoogleFonts.archivo(
                            color: AppTheme.primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.rejectClaim(claim),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cancel_rounded,
                          color: AppTheme.primaryText,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reject',
                          style: GoogleFonts.archivo(
                            color: AppTheme.primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnswers(List answers) {
    return answers
        .asMap()
        .entries
        .map((entry) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.accent1.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${entry.key + 1}',
                style: GoogleFonts.archivo(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.value.toString(),
              style: GoogleFonts.archivo(
                color: AppTheme.primaryText,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ))
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.error;
      case 'pending':
        return AppTheme.accent2;
      default:
        return AppTheme.accent1;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.accent2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppTheme.accent2.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.assignment_late_outlined,
                size: 60,
                color: AppTheme.accent1,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No claims yet',
              style: GoogleFonts.archivo(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Claims for this item will appear here\nonce users submit them',
              textAlign: TextAlign.center,
              style: GoogleFonts.archivo(
                fontSize: 16,
                color: AppTheme.accent1,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}