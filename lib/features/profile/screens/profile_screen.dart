import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harbour/core/constants/app_routes.dart';
import 'package:harbour/core/theme/app_theme.dart';
import 'package:harbour/features/auth/providers/auth_provider.dart' as app_auth;
import 'package:harbour/features/profile/providers/profile_provider.dart';
import 'package:harbour/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<app_auth.AuthProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    // In development mode, we can load a profile even if auth.user is null
    if (authProvider.user != null) {
      await profileProvider.loadUserProfile(authProvider.user!.uid);
    } else {
      // Load with a fake user ID for development
      await profileProvider.loadUserProfile('dev-user-id');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final profileProvider = Provider.of<ProfileProvider>(context);
    final authProvider = Provider.of<app_auth.AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
          ),
        ],
      ),
      body:
          profileProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildProfileContent(
                context,
                profileProvider.userProfile,
                authProvider,
              ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserModel? userProfile,
    app_auth.AuthProvider authProvider,
  ) {
    if (userProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Unable to load profile'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                _buildProfileImage(userProfile),
                const SizedBox(height: 16),
                Text(
                  userProfile.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${userProfile.age} years old',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.editProfile);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Prompt responses
          _buildSectionHeader(context, 'About Me'),
          _buildPromptResponses(context, userProfile),

          // Roots section
          _buildSectionHeader(context, 'Roots'),
          _buildRootsSection(context, userProfile),

          // Home & Future section
          _buildSectionHeader(context, 'Home & Future'),
          _buildHomeFutureSection(context, userProfile),

          // Political views - conservative dating app specific
          _buildSectionHeader(context, 'Values'),
          _buildValuesSection(context, userProfile),

          const SizedBox(height: 48),

          // Sign out button
          Center(
            child: OutlinedButton(
              onPressed: () async {
                await authProvider.signOut();
              },
              child: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserModel userProfile) {
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
      return _buildEmptyState(
        'Tell others about yourself by adding some prompts.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          userProfile.promptResponses.entries.map((entry) {
            return _buildPromptResponse(context, entry.key, entry.value);
          }).toList(),
    );
  }

  Widget _buildPromptResponse(
    BuildContext context,
    String prompt,
    String response,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prompt,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(response, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRootsSection(BuildContext context, UserModel userProfile) {
    final bool hasRootsInfo =
        userProfile.hometown != null ||
        userProfile.faithTradition != null ||
        userProfile.nonNegotiableValue != null;

    if (!hasRootsInfo) {
      return _buildEmptyState(
        'Add information about your roots and background.',
      );
    }

    return Column(
      children: [
        _buildInfoItem(
          context,
          'Hometown',
          userProfile.hometown ?? 'Not specified',
        ),
        _buildInfoItem(
          context,
          'Faith Tradition',
          userProfile.faithTradition ?? 'Not specified',
        ),
        _buildInfoItem(
          context,
          'Non-negotiable Value',
          userProfile.nonNegotiableValue ?? 'Not specified',
        ),
      ],
    );
  }

  Widget _buildHomeFutureSection(BuildContext context, UserModel userProfile) {
    final bool hasHomeFutureInfo =
        userProfile.kidsPreference != null ||
        userProfile.relocationPreference != null ||
        userProfile.lifestylePreference != null ||
        userProfile.faithLevel != null;

    if (!hasHomeFutureInfo) {
      return _buildEmptyState(
        'Add information about your future plans and preferences.',
      );
    }

    return Column(
      children: [
        _buildInfoItem(
          context,
          'Kids',
          userProfile.kidsPreference ?? 'Not specified',
        ),
        _buildInfoItem(
          context,
          'Relocation',
          userProfile.relocationPreference ?? 'Not specified',
        ),
        _buildInfoItem(
          context,
          'Lifestyle',
          userProfile.lifestylePreference ?? 'Not specified',
        ),
        _buildInfoItem(
          context,
          'Faith Level',
          userProfile.faithLevel ?? 'Not specified',
        ),
      ],
    );
  }

  Widget _buildValuesSection(BuildContext context, UserModel userProfile) {
    final bool hasValuesInfo =
        userProfile.politicalAlignment != null ||
        userProfile.traditionalRoles != null;

    if (!hasValuesInfo) {
      return _buildEmptyState('Add information about your values and beliefs.');
    }

    return Column(
      children: [
        _buildInfoItem(
          context,
          'Political Views',
          userProfile.politicalAlignment ?? 'Not specified',
        ),
        _buildInfoItem(
          context,
          'Traditional Roles',
          userProfile.traditionalRoles == null
              ? 'Not specified'
              : userProfile.traditionalRoles!
              ? 'Preferred'
              : 'Not important',
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

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Column(
          children: [
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.editProfile);
              },
              child: const Text('Complete Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
