import 'package:geolocator/geolocator.dart' show Geolocator, LocationPermission, Position, LocationAccuracy;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:treasurehunt/app/controllers/auth_controller.dart';
import 'package:treasurehunt/app/models/item_model.dart';
import 'package:treasurehunt/app/services/found_item_service.dart';
import 'package:treasurehunt/app/services/lost_item_service.dart';

class PostController extends GetxController {
  final LostItemService _lostItemService = LostItemService();
  final FoundItemService _foundItemService = FoundItemService();
  final AuthController _authController = Get.find();

  // Initialize Cloudinary
  final cloudinary = CloudinaryPublic('dbxdfhe6c', 'losthunt', cache: false);

  var isUploading = false.obs;
  var isGettingLocation = false.obs;
  var isUploadingImage = false.obs;

  // Form fields
  var title = ''.obs;
  var description = ''.obs;
  var imageUrl = ''.obs;
  var location = ''.obs;
  var status = 'found'.obs; // 'found' or 'lost'
  var mobileNumber = ''.obs; // Added mobile number field
  var tag = ''.obs; // Added tag field

  // Tag options for dropdown
  final List<String> tagOptions = [
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

  // New properties for enhanced features
  final selectedImage = Rx<File?>(null);
  var currentLocation = ''.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var formattedTime = ''.obs;
  var timestamp = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _updateTime();
    timestamp.value = DateTime.now();
  }

  void _updateTime() {
    final now = DateTime.now();
    formattedTime.value = DateFormat('HH:mm').format(now);
    timestamp.value = now;
  }

  // Mobile number validation
  bool isValidMobileNumber(String number) {
    // Remove any spaces, dashes, or other formatting
    String cleanNumber = number.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid length (10 digits for most countries)
    if (cleanNumber.length == 10) {
      return true;
    }

    // Check if it starts with country code (like +91 for India)
    if (cleanNumber.length == 12 && cleanNumber.startsWith('91')) {
      return true;
    }

    return false;
  }

  // Tag validation
  bool isValidTag(String selectedTag) {
    return tagOptions.contains(selectedTag);
  }

  // Set tag value
  void setTag(String selectedTag) {
    if (isValidTag(selectedTag)) {
      tag.value = selectedTag;
    }
  }

  // Image picker functionality
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        // Upload the image to Cloudinary
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Upload image to Cloudinary
  Future<void> _uploadImageToCloudinary() async {
    if (selectedImage.value == null) return;

    isUploadingImage.value = true;
    try {
      final String? userId = _authController.user.value?.id;
      if (userId == null) {
        Get.snackbar('Error', 'You must be logged in to upload images.');
        return;
      }

      // Create a unique public ID for the image
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String publicId = 'treasure_hunt/${userId}/${timestamp}';
      print('Uploading to Cloudinary with public ID: $publicId');

      // Upload image to Cloudinary
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          selectedImage.value!.path,
          publicId: publicId,
          folder: 'treasure_hunt',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Get the secure URL from response
      imageUrl.value = response.secureUrl;
      print('Image uploaded successfully: ${response.secureUrl}');
      Get.snackbar(
        'Success',
        'Image uploaded successfully!',
        duration: const Duration(seconds: 2),
      );
    } on CloudinaryException catch (e) {
      print('Cloudinary error: ${e.message}');
      String errorMessage;
      switch (e.message) {
        case 'Invalid upload preset':
          errorMessage = 'Upload configuration error. Please contact support.';
          break;
        case 'File size too large':
          errorMessage = 'Image file is too large. Please choose a smaller image.';
          break;
        default:
          errorMessage = 'Upload failed: ${e.message}';
      }

      Get.snackbar('Upload Error', errorMessage);
      imageUrl.value = '';
    } catch (e) {
      print('General error: $e');
      Get.snackbar('Error', 'Failed to upload image. Please try again.');
      imageUrl.value = '';
    } finally {
      isUploadingImage.value = false;
    }
  }

  // Method to delete image from Cloudinary (optional)
  Future<void> deleteImageFromCloudinary(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.contains('cloudinary')) {
        // Extract public ID from URL for deletion
        // This is optional - Cloudinary has generous storage limits
        print('Image deletion from Cloudinary would be implemented here');
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Geolocation functionality
  Future<void> getCurrentLocation() async {
    isGettingLocation.value = true;
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled.');
        isGettingLocation.value = false;
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permissions are denied');
          isGettingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Location permissions are permanently denied');
        isGettingLocation.value = false;
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      currentLocation.value = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location: $e');
      currentLocation.value = "Location unavailable";
    } finally {
      isGettingLocation.value = false;
    }
  }

  // Set manual location
  void setManualLocation(String manualLocation) {
    location.value = manualLocation;
  }

  // Use current GPS location as the location field
  void useCurrentLocationAsAddress() {
    if (currentLocation.value.isNotEmpty) {
      location.value = currentLocation.value;
    }
  }

  void uploadPost() async {
    // Validation checks
    if (title.value.isEmpty || description.value.isEmpty) {
      Get.snackbar('Error', 'Title and description cannot be empty');
      return;
    }

    // Validate mobile number
    if (mobileNumber.value.isEmpty) {
      Get.snackbar('Error', 'Mobile number is required');
      return;
    }

    if (!isValidMobileNumber(mobileNumber.value)) {
      Get.snackbar('Error', 'Please enter a valid mobile number');
      return;
    }

    // Validate tag selection
    if (tag.value.isEmpty) {
      Get.snackbar('Error', 'Please select a category for your item');
      return;
    }

    if (!isValidTag(tag.value)) {
      Get.snackbar('Error', 'Please select a valid category');
      return;
    }

    // Check if image is still uploading
    if (isUploadingImage.value) {
      Get.snackbar('Please wait', 'Image is still uploading...');
      return;
    }

    // Use current location if location field is empty and GPS location is available
    if (location.value.isEmpty && currentLocation.value.isNotEmpty) {
      location.value = currentLocation.value;
    }

    if (location.value.isEmpty) {
      Get.snackbar('Error', 'Location cannot be empty. Please add a location or use GPS.');
      return;
    }

    isUploading.value = true;
    try {
      final String? userId = _authController.user.value?.id;
      if (userId == null) {
        Get.snackbar('Error', 'You must be logged in to post an item.');
        return;
      }

      final item = ItemModel(
        id: '', // Firestore will generate this
        title: title.value,
        description: description.value,
        imageUrl: imageUrl.value, // This will now be the Cloudinary URL
        location: location.value,
        reportedBy: userId,
        status: status.value,
        createdAt: timestamp.value ?? DateTime.now(),
        mobileNumber: mobileNumber.value, // Added mobile number
        latitude: latitude.value != 0.0 ? latitude.value : null,
        longitude: longitude.value != 0.0 ? longitude.value : null,
        gpsLocation: currentLocation.value.isNotEmpty ? currentLocation.value : null,
      );

      if (status.value == 'lost') {
        await _lostItemService.postLostItem(item);
        Get.snackbar('Success', 'Lost item posted successfully!');
      } else {
        await _foundItemService.postFoundItem(item);
        Get.snackbar('Success', 'Found item posted successfully!');
      }

      // Navigate back after successful post
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload post. Please try again.');
      print("Upload error: $e");
    } finally {
      isUploading.value = false;
      _clearForm();
    }
  }

  void _clearForm() {
    title.value = '';
    description.value = '';
    imageUrl.value = '';
    location.value = '';
    status.value = 'found';
    mobileNumber.value = ''; // Added mobile number to clear form
    tag.value = ''; // Added tag to clear form
    selectedImage.value = null;
    currentLocation.value = '';
    latitude.value = 0.0;
    longitude.value = 0.0;
    timestamp.value = DateTime.now();
    _updateTime();
  }

  @override
  void onClose() {
    // Clean up any resources if needed
    super.onClose();
  }
}
