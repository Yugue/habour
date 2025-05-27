import 'package:flutter/material.dart';
import 'package:harbour/core/theme/app_theme.dart';
import 'package:harbour/models/user_model.dart';

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel userProfile =
        ModalRoute.of(context)!.settings.arguments as UserModel;

    return Scaffold(
      appBar: AppBar(title: Text(userProfile.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  _buildProfileImage(context, userProfile),
                  const SizedBox(height: 16),
                  Text(
                    userProfile.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_calculateAge(userProfile.birthDate)} years old',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (userProfile.hometown != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        userProfile.hometown!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bio section if available
            if (userProfile.bio != null && userProfile.bio!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  userProfile.bio!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

            // Prompt responses
            _buildSectionHeader(context, 'About Me'),
            _buildPromptResponses(context, userProfile),

            // Roots section
            if (_hasRootsInfo(userProfile)) ...[
              _buildSectionHeader(context, 'Roots'),
              _buildRootsSection(context, userProfile),
            ],

            // Home & Future section
            if (_hasHomeFutureInfo(userProfile)) ...[
              _buildSectionHeader(context, 'Home & Future'),
              _buildHomeFutureSection(context, userProfile),
            ],

            // Values section
            if (_hasValuesInfo(userProfile)) ...[
              _buildSectionHeader(context, 'Values'),
              _buildValuesSection(context, userProfile),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, UserModel userProfile) {
    final bool hasProfileImage = userProfile.photoUrls.isNotEmpty;

    return CircleAvatar(
      radius: 64,
      backgroundColor: AppTheme.secondaryBeige,
      backgroundImage:
          hasProfileImage ? NetworkImage(userProfile.photoUrls.first) : null,
      child:
          !hasProfileImage
              ? const Icon(Icons.person, size: 64, color: AppTheme.primaryBlue)
              : null,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildPromptResponses(BuildContext context, UserModel userProfile) {
    if (userProfile.promptResponses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Text('No prompts answered yet.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          userProfile.promptResponses.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  bool _hasRootsInfo(UserModel userProfile) {
    return userProfile.hometown != null ||
        userProfile.faithTradition != null ||
        userProfile.nonNegotiableValue != null;
  }

  Widget _buildRootsSection(BuildContext context, UserModel userProfile) {
    return Column(
      children: [
        if (userProfile.hometown != null)
          _buildInfoItem(context, 'Hometown', userProfile.hometown!),
        if (userProfile.faithTradition != null)
          _buildInfoItem(
            context,
            'Faith Tradition',
            userProfile.faithTradition!,
          ),
        if (userProfile.nonNegotiableValue != null)
          _buildInfoItem(
            context,
            'Non-negotiable Value',
            userProfile.nonNegotiableValue!,
          ),
      ],
    );
  }

  bool _hasHomeFutureInfo(UserModel userProfile) {
    return userProfile.kidsPreference != null ||
        userProfile.relocationPreference != null ||
        userProfile.lifestylePreference != null ||
        userProfile.faithLevel != null;
  }

  Widget _buildHomeFutureSection(BuildContext context, UserModel userProfile) {
    return Column(
      children: [
        if (userProfile.kidsPreference != null)
          _buildInfoItem(context, 'Kids', userProfile.kidsPreference!),
        if (userProfile.relocationPreference != null)
          _buildInfoItem(
            context,
            'Relocation',
            userProfile.relocationPreference!,
          ),
        if (userProfile.lifestylePreference != null)
          _buildInfoItem(
            context,
            'Lifestyle',
            userProfile.lifestylePreference!,
          ),
        if (userProfile.faithLevel != null)
          _buildInfoItem(context, 'Faith Level', userProfile.faithLevel!),
      ],
    );
  }

  bool _hasValuesInfo(UserModel userProfile) {
    return userProfile.politicalAlignment != null ||
        userProfile.traditionalRoles != null;
  }

  Widget _buildValuesSection(BuildContext context, UserModel userProfile) {
    return Column(
      children: [
        if (userProfile.politicalAlignment != null)
          _buildInfoItem(
            context,
            'Political Views',
            userProfile.politicalAlignment!,
          ),
        if (userProfile.traditionalRoles != null)
          _buildInfoItem(
            context,
            'Traditional Roles',
            userProfile.traditionalRoles! ? 'Preferred' : 'Not important',
          ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textMedium,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
