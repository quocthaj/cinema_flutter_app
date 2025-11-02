import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

/// 📸 Service quản lý avatar của user
class AvatarService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  /// Chọn ảnh từ gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      rethrow;
    }
  }

  /// Chọn ảnh từ camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      print('❌ Error picking image from camera: $e');
      rethrow;
    }
  }

  /// Crop ảnh thành hình tròn
  Future<File?> cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cắt ảnh đại diện',
            toolbarColor: const Color(0xFF9B3232),
            toolbarWidgetColor: Colors.white,
            statusBarColor: const Color(0xFF9B3232),
            backgroundColor: Colors.black,
            dimmedLayerColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFF9B3232),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            showCropGrid: true,
            cropFrameColor: const Color(0xFF9B3232),
            cropGridColor: Colors.white70,
            cropGridRowCount: 3,
            cropGridColumnCount: 3,
          ),
          IOSUiSettings(
            title: 'Cắt ảnh đại diện',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            aspectRatioPickerButtonHidden: true,
            doneButtonTitle: 'Xong',
            cancelButtonTitle: 'Hủy',
          ),
        ],
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      print('❌ Error cropping image: $e');
      return imageFile; // Trả về ảnh gốc nếu crop fail
    }
  }

  /// Upload avatar lên Firebase Storage và update Firestore
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Xóa avatar cũ nếu có (tránh rác trên Storage)
      await _deleteOldAvatar(user.uid);

      // Upload ảnh mới
      final String fileName = 'avatar_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('avatars/$fileName');
      
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      
      // Lấy download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore user document
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth profile
      await user.updatePhotoURL(downloadUrl);

      print('✅ Avatar uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Xóa avatar cũ khỏi Storage
  Future<void> _deleteOldAvatar(String userId) async {
    try {
      // Lấy photoUrl cũ từ Firestore
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      final data = docSnapshot.data();
      
      if (data != null && data['photoUrl'] != null) {
        final String oldPhotoUrl = data['photoUrl'];
        
        // Chỉ xóa nếu là Firebase Storage URL (không phải Google OAuth avatar)
        if (oldPhotoUrl.contains('firebasestorage.googleapis.com')) {
          try {
            final ref = _storage.refFromURL(oldPhotoUrl);
            await ref.delete();
            print('🗑️ Old avatar deleted from Storage');
          } catch (e) {
            print('⚠️ Could not delete old avatar (might not exist): $e');
          }
        }
      }
    } catch (e) {
      print('⚠️ Error deleting old avatar: $e');
      // Không throw error - việc xóa ảnh cũ thất bại không nên block upload ảnh mới
    }
  }

  /// Xóa avatar hiện tại (set về default)
  Future<void> deleteAvatar() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Xóa file trên Storage
      await _deleteOldAvatar(user.uid);

      // Update Firestore (set null)
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth profile
      await user.updatePhotoURL(null);

      print('✅ Avatar deleted successfully');
    } catch (e) {
      print('❌ Error deleting avatar: $e');
      rethrow;
    }
  }

  /// Helper: Show bottom sheet để chọn nguồn ảnh
  Future<File?> showImageSourcePicker(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Chọn ảnh từ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Gallery button
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: const Text('Thư viện ảnh'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await pickImageFromGallery();
                    if (file != null && context.mounted) {
                      final croppedFile = await cropImage(file);
                      if (croppedFile != null && context.mounted) {
                        Navigator.pop(context, croppedFile);
                      }
                    }
                  },
                ),

                // Camera button
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.green),
                  ),
                  title: const Text('Chụp ảnh'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await pickImageFromCamera();
                    if (file != null && context.mounted) {
                      final croppedFile = await cropImage(file);
                      if (croppedFile != null && context.mounted) {
                        Navigator.pop(context, croppedFile);
                      }
                    }
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
