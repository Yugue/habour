import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:harbour/core/theme/app_theme.dart';
import 'package:harbour/features/auth/providers/auth_provider.dart' as app_auth;
import 'package:harbour/features/profile/providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedGender;
  String? _interestedIn;

  // Roots section
  final _hometownController = TextEditingController();
  final _faithTraditionController = TextEditingController();
  final _nonNegotiableValueController = TextEditingController();

  // Home & Future section
  String? _kidsPreference;
  String? _relocationPreference;
  String? _lifestylePreference;
  String? _faithLevel;

  // Values section
  String? _politicalAlignment;
  bool? _traditionalRoles;

  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _kidsOptions = [
    'Want kids',
    'Don\'t want kids',
    'Open to kids',
  ];
  final List<String> _relocationOptions = [
    'Happy to relocate',
    'Staying put',
    'Open to relocating',
  ];
  final List<String> _lifestyleOptions = ['Urban', 'Suburban', 'Rural'];
  final List<String> _faithLevelOptions = [
    'Very important',
    'Somewhat important',
    'Not important',
  ];
  final List<String> _politicalOptions = [
    'Conservative',
    'Moderate',
    'Libertarian',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final userProfile = profileProvider.userProfile;

    if (userProfile != null) {
      setState(() {
        _nameController.text = userProfile.name;
        _bioController.text = userProfile.bio ?? '';
        _birthDate = userProfile.birthDate;
        _selectedGender = userProfile.gender;
        _interestedIn = userProfile.interestedIn;

        // Roots section
        _hometownController.text = userProfile.hometown ?? '';
        _faithTraditionController.text = userProfile.faithTradition ?? '';
        _nonNegotiableValueController.text =
            userProfile.nonNegotiableValue ?? '';

        // Home & Future section
        _kidsPreference = userProfile.kidsPreference;
        _relocationPreference = userProfile.relocationPreference;
        _lifestylePreference = userProfile.lifestylePreference;
        _faithLevel = userProfile.faithLevel;

        // Values section
        _politicalAlignment = userProfile.politicalAlignment;
        _traditionalRoles = userProfile.traditionalRoles;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _hometownController.dispose();
    _faithTraditionController.dispose();
    _nonNegotiableValueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 21)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryDeepBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      await profileProvider.uploadProfileImage(File(image.path));

      if (profileProvider.error != null) {
        _showErrorSnackBar(profileProvider.error!);
      } else {
        _showSuccessSnackBar('Profile photo uploaded successfully');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_birthDate == null) {
        _showErrorSnackBar('Please select your birth date');
        return;
      }

      if (_selectedGender == null) {
        _showErrorSnackBar('Please select your gender');
        return;
      }

      if (_interestedIn == null) {
        _showErrorSnackBar('Please select who you\'re interested in');
        return;
      }

      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<app_auth.AuthProvider>(
        context,
        listen: false,
      );

      if (profileProvider.userProfile == null || authProvider.user == null) {
        _showErrorSnackBar('Unable to save profile. Please try again later.');
        return;
      }

      final updatedProfile = profileProvider.userProfile!.copyWith(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        birthDate: _birthDate!,
        gender: _selectedGender!,
        interestedIn: _interestedIn!,
        hometown:
            _hometownController.text.trim().isNotEmpty
                ? _hometownController.text.trim()
                : null,
        faithTradition:
            _faithTraditionController.text.trim().isNotEmpty
                ? _faithTraditionController.text.trim()
                : null,
        nonNegotiableValue:
            _nonNegotiableValueController.text.trim().isNotEmpty
                ? _nonNegotiableValueController.text.trim()
                : null,
        kidsPreference: _kidsPreference,
        relocationPreference: _relocationPreference,
        lifestylePreference: _lifestylePreference,
        faithLevel: _faithLevel,
        politicalAlignment: _politicalAlignment,
        traditionalRoles: _traditionalRoles,
        isProfileComplete: true,
      );

      await profileProvider.updateUserProfile(updatedProfile);

      if (profileProvider.error != null && mounted) {
        _showErrorSnackBar(profileProvider.error!);
      } else if (mounted) {
        _showSuccessSnackBar('Profile updated successfully');
        Navigator.of(context).pop();
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userProfile = profileProvider.userProfile;

    if (userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body:
          profileProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Photos
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 64,
                                    backgroundColor: AppTheme.secondaryWarmBeige,
                                    backgroundImage:
                                        userProfile.photoUrls.isNotEmpty
                                            ? NetworkImage(
                                              userProfile.photoUrls.first,
                                            )
                                            : null,
                                    child:
                                        userProfile.photoUrls.isEmpty
                                            ? const Icon(
                                              Icons.person,
                                              size: 64,
                                              color: AppTheme.primaryDeepBlue,
                                            )
                                            : null,
                                  ),
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme.primaryDeepBlue,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to change photo',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Basic Info
                      _buildSectionTitle('Basic Information'),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          hintText: 'Tell others about yourself',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Birth date picker
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Birth Date',
                          ),
                          child: Text(
                            _birthDate != null
                                ? DateFormat('MMMM d, yyyy').format(_birthDate!)
                                : 'Select Date',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Gender selection
                      _buildDropdownField(
                        title: 'I am',
                        value: _selectedGender,
                        items: _genderOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Interested in selection
                      _buildDropdownField(
                        title: 'Interested in',
                        value: _interestedIn,
                        items: _genderOptions,
                        onChanged: (value) {
                          setState(() {
                            _interestedIn = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Roots Section
                      _buildSectionTitle('Roots'),
                      TextFormField(
                        controller: _hometownController,
                        decoration: const InputDecoration(
                          labelText: 'Hometown / Upbringing',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _faithTraditionController,
                        decoration: const InputDecoration(
                          labelText: 'Faith / Family Traditions',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nonNegotiableValueController,
                        decoration: const InputDecoration(
                          labelText: 'One value I\'ll never compromise on',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Home & Future Section
                      _buildSectionTitle('Home & Future'),
                      _buildDropdownField(
                        title: 'Kids',
                        value: _kidsPreference,
                        items: _kidsOptions,
                        onChanged: (value) {
                          setState(() {
                            _kidsPreference = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        title: 'Relocation',
                        value: _relocationPreference,
                        items: _relocationOptions,
                        onChanged: (value) {
                          setState(() {
                            _relocationPreference = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        title: 'Lifestyle',
                        value: _lifestylePreference,
                        items: _lifestyleOptions,
                        onChanged: (value) {
                          setState(() {
                            _lifestylePreference = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        title: 'Faith Level',
                        value: _faithLevel,
                        items: _faithLevelOptions,
                        onChanged: (value) {
                          setState(() {
                            _faithLevel = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Values Section
                      _buildSectionTitle('Values'),
                      _buildDropdownField(
                        title: 'Political Views',
                        value: _politicalAlignment,
                        items: _politicalOptions,
                        onChanged: (value) {
                          setState(() {
                            _politicalAlignment = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Traditional roles
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Traditional Roles',
                        ),
                        child: Column(
                          children: [
                            RadioListTile<bool>(
                              title: const Text(
                                'I prefer traditional gender roles',
                              ),
                              value: true,
                              groupValue: _traditionalRoles,
                              onChanged: (value) {
                                setState(() {
                                  _traditionalRoles = value;
                                });
                              },
                            ),
                            RadioListTile<bool>(
                              title: const Text(
                                'Traditional roles are not important to me',
                              ),
                              value: false,
                              groupValue: _traditionalRoles,
                              onChanged: (value) {
                                setState(() {
                                  _traditionalRoles = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      Center(
                        child: ElevatedButton(
                          onPressed:
                              profileProvider.isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 12,
                            ),
                          ),
                          child:
                              profileProvider.isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Save Profile'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryDeepBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: title),
      value: value,
      items:
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
    );
  }
}
