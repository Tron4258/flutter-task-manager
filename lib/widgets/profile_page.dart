import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/cloudinary_config.dart';
import '../utils/cloudinary_helper.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  // Update Cloudinary configuration with proper credentials
  final cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        final profile = UserProfile.fromMap(doc.data()!);
        _nameController.text = profile.displayName;
        _bioController.text = profile.bio ?? '';
        _phoneController.text = profile.phoneNumber ?? '';
      } else {
        _nameController.text = user.displayName ?? '';
        _bioController.text = '';
        _phoneController.text = '';
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = UserProfile(
          uid: user.uid,
          displayName: _nameController.text.trim(),
          email: user.email!,
          bio: _bioController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(profile.toMap());

        await user.updateDisplayName(_nameController.text.trim());

        // Pop the modal first
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() => _isEditing = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImage() async {
    try {
      print('📸 Starting image upload process...');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) {
        print('❌ No image selected');
        return;
      }

      setState(() => _isUploadingImage = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        print('☁️ Uploading to Cloudinary...');
        print('Cloud name: ${CloudinaryConfig.cloudName}');
        print('Upload preset: ${CloudinaryConfig.uploadPreset}');

        late final CloudinaryResponse response;
        
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          response = await cloudinary.uploadFile(
            CloudinaryFile.fromBytesData(
              bytes,
              identifier: 'profile_${user.uid}',
            ),
          );
        } else {
          response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              image.path,
              identifier: 'profile_${user.uid}',
            ),
          );
        }

        print('✅ Upload successful: ${response.secureUrl}');

        final optimizedUrl = CloudinaryHelper.optimizeUrl(response.secureUrl);
        
        // Update Firebase user
        await user.updatePhotoURL(optimizedUrl);
        
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'photoUrl': optimizedUrl});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {});
      } catch (uploadError) {
        print('❌ Upload error details:');
        print(uploadError.toString());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isLoading
                ? null
                : () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text('Please log in'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(CloudinaryHelper.optimizeUrl(user.photoURL!))
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.displayName?.substring(0, 1).toUpperCase() ??
                                      '?',
                                  style: TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: _isUploadingImage ? null : _uploadImage,
                          ),
                        ),
                        if (_isUploadingImage)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      enabled: _isEditing,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Email'),
                      subtitle: Text(user.email ?? 'No email'),
                      leading: Icon(Icons.email),
                    ),
                    if (_isLoading)
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 