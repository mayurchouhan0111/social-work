import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../app_theme.dart';
import '../../../controllers/post_controller.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Dark background
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 768) {
            return _buildWebLayout(controller, constraints, formKey);
          } else {
            return _buildMobileLayout(controller, formKey);
          }
        },
      ),
    );
  }

  Widget _buildWebLayout(PostController controller, BoxConstraints constraints, GlobalKey<FormState> formKey) {
    return Column(
      children: [
        // Web Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 1200 ? 80 : 40,
            vertical: 32,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // Dark card
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Post an Item",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Help others find their lost items or report what you've found",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 1200 ? 80 : 40,
              vertical: 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _buildForm(controller, formKey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(PostController controller, GlobalKey<FormState> formKey) {
    return Column(
      children: [
        // Mobile Header
        AppBar(
          title: Text(
            "Post Item",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildForm(controller, formKey),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(PostController controller, GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Upload Section
          _buildImageUploadSection(controller),
          const SizedBox(height: 32),

          // Form Fields
          _buildFormFields(controller),
          const SizedBox(height: 40),

          // Submit Button
          _buildSubmitButton(controller, formKey),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(PostController controller) {
    return Obx(() => GestureDetector(
    onTap: controller.isUploadingImage.value ? null : () => _showImagePicker(controller),
    child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: controller.isUploadingImage.value
            ? _buildUploadingState()
            : controller.selectedImage.value != null
            ? _buildSelectedImage(controller)
            : buildUploadPrompt(),
      ),
    ));
  }

  Widget _buildUploadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
        ),
        const SizedBox(height: 16),
        Text(
          "Uploading image...",
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedImage(PostController controller) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: kIsWeb
              ? Image.network(
                  controller.selectedImage.value!.path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 240,
                )
              : Image.file(
                  File(controller.selectedImage.value!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 240,
                ),
        ),

        // Success indicator
        if (controller.imageUrl.value.isNotEmpty)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_done, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "Uploaded",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Remove button
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () {
              controller.selectedImage.value = null;
              controller.imageUrl.value = '';
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: FaIcon(
            FontAwesomeIcons.cloudArrowUp,
            size: 32,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Add a photo",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap to upload an image of your item",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  void _showImagePicker(PostController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A), // Dark background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Choose Photo Source",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImagePickerOption(
                    icon: FontAwesomeIcons.camera,
                    label: "Camera",
                    onTap: () {
                      Get.back();
                      controller.pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImagePickerOption(
                    icon: FontAwesomeIcons.images,
                    label: "Gallery",
                    onTap: () {
                      Get.back();
                      controller.pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            FaIcon(
              icon,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(PostController controller) {
    return Column(
      children: [
        // Title Field (Full Width)
        _buildInputField(
          label: "Item Title",
          hint: "What did you lose/find? (e.g., iPhone 14, Blue Wallet)",
          icon: FontAwesomeIcons.tag,
          onChanged: (value) => controller.title.value = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Contact Number and Tag Row
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                label: "Contact Number",
                hint: "Your phone number",
                icon: FontAwesomeIcons.phone,
                keyboardType: TextInputType.phone,
                onChanged: (value) => controller.mobileNumber.value = value,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildTagDropdown(controller),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Description Field (Full Width)
        _buildInputField(
          label: "Description",
          hint: "Provide detailed information about the item (color, brand, distinctive features, etc.)",
          icon: FontAwesomeIcons.alignLeft,
          maxLines: 4,
          onChanged: (value) => controller.description.value = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Location and Status Row
        Row(
          children: [
            Expanded(child: _buildLocationSection(controller)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatusSelection(controller)),
          ],
        ),
        const SizedBox(height: 24),
        _buildQuestionsSection(controller),
      ],
    );
  }

  Widget _buildTagDropdown(PostController controller) {
    final List<String> tags = [
      'Electronics',
      'Personal Items',
      'Documents',
      'Clothing',
      'Sports',
      'Academic',
      'Jewelry',
      'Keys',
      'Bags',
      'Other'
    ];

    return Obx(() => Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: controller.tag.value.isEmpty ? null : controller.tag.value,
        decoration: InputDecoration(
          labelText: "Category",
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: FaIcon(
              FontAwesomeIcons.layerGroup,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          labelStyle: GoogleFonts.inter(
            color: AppTheme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
        ),
        dropdownColor: const Color(0xFF1A1A1A),
        style: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white,
        ),
        items: tags.map((String tag) {
          return DropdownMenuItem<String>(
            value: tag,
            child: Text(tag),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            controller.tag.value = newValue;
          }
        },
      ),
    ));
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: FaIcon(
              icon,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          labelStyle: GoogleFonts.inter(
            color: AppTheme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF9E9E9E),
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection(PostController controller) {
    return Obx(() => GestureDetector(
      onTap: () => controller.getCurrentLocation(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.locationDot,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  "Location",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            controller.isGettingLocation.value
                ? Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Getting location...",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            )
                : Text(
              controller.currentLocation.value.isEmpty
                  ? "Tap to get current location"
                  : controller.currentLocation.value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: controller.currentLocation.value.isEmpty
                    ? const Color(0xFF9E9E9E)
                    : Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatusSelection(PostController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Status",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.status.value = "lost",
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.status.value == "lost"
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: controller.status.value == "lost"
                            ? Colors.orange
                            : const Color(0xFF2A2A2A),
                      ),
                    ),
                    child: Column(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.triangleExclamation,
                          size: 16,
                          color: controller.status.value == "lost"
                              ? Colors.orange
                              : const Color(0xFF9E9E9E),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Lost",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: controller.status.value == "lost"
                                ? Colors.orange
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.status.value = "found",
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.status.value == "found"
                          ? Colors.green.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: controller.status.value == "found"
                            ? Colors.green
                            : const Color(0xFF2A2A2A),
                      ),
                    ),
                    child: Column(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleCheck,
                          size: 16,
                          color: controller.status.value == "found"
                              ? Colors.green
                              : const Color(0xFF9E9E9E),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Found",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: controller.status.value == "found"
                                ? Colors.green
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildQuestionsSection(PostController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verification Questions",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Add some questions to verify the owner of the item.",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.questions.length,
          itemBuilder: (context, index) {
            return _buildQuestionField(controller, index);
          },
        )),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => controller.addQuestion(),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text("Add Question", style: GoogleFonts.inter(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionField(PostController controller, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextFormField(
            initialValue: controller.questions[index]['question'],
            onChanged: (value) => controller.updateQuestion(index, value),
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Question ${index + 1}",
              labelStyle: GoogleFonts.inter(color: AppTheme.primaryColor),
              hintText: "e.g., What color is the item?",
              hintStyle: GoogleFonts.inter(color: const Color(0xFF9E9E9E)),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: controller.questions[index]['answer'],
            onChanged: (value) => controller.updateAnswer(index, value),
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Answer ${index + 1}",
              labelStyle: GoogleFonts.inter(color: AppTheme.primaryColor),
              hintText: "e.g., Blue",
              hintStyle: GoogleFonts.inter(color: const Color(0xFF9E9E9E)),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 8),
          if (controller.questions.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => controller.removeQuestion(index),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(PostController controller, GlobalKey<FormState> formKey) {
    return Obx(() => GestureDetector(
      onTap: controller.isUploading.value || controller.isUploadingImage.value
          ? null
          : () {
        if (formKey.currentState!.validate()) {
          // Validation check
          if (controller.imageUrl.value.isEmpty) {
            Get.snackbar(
              'Error',
              'Please fill out all required fields and upload an image.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return; // Stop the function here
          }
          controller.uploadPost();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: controller.isUploading.value || controller.isUploadingImage.value
              ? null
              : LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.accentColor],
          ),
          color: controller.isUploading.value || controller.isUploadingImage.value
              ? const Color(0xFF2A2A2A)
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: controller.isUploading.value || controller.isUploadingImage.value
              ? []
              : [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: controller.isUploading.value || controller.isUploadingImage.value
              ? [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              controller.isUploadingImage.value ? "Uploading image..." : "Posting...",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ]
              : [
            const FaIcon(
              FontAwesomeIcons.paperPlane,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              "Post Item",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: FaIcon(
            FontAwesomeIcons.cloudArrowUp,
            size: 32,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Add a photo",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap to upload an image of your item",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}