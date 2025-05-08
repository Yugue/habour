import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harbour/core/constants/app_routes.dart';
import 'package:harbour/core/theme/app_theme.dart';
import 'package:harbour/features/auth/providers/auth_provider.dart' as app_auth;
import 'package:harbour/features/discovery/providers/discovery_provider.dart';
import 'package:harbour/models/user_model.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiscoveryProfiles();
    });
  }

  Future<void> _loadDiscoveryProfiles() async {
    final discoveryProvider = Provider.of<DiscoveryProvider>(
      context,
      listen: false,
    );
    await discoveryProvider.loadDiscoveryProfiles();

    if (discoveryProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(discoveryProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final discoveryProvider = Provider.of<DiscoveryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.filterPreferences);
            },
          ),
        ],
      ),
      body:
          discoveryProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDiscoveryContent(discoveryProvider),
    );
  }

  Widget _buildDiscoveryContent(DiscoveryProvider discoveryProvider) {
    if (discoveryProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading profiles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              discoveryProvider.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDiscoveryProfiles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (discoveryProvider.discoveryProfiles.isEmpty) {
      return _buildEmptyState();
    }

    final currentProfile = discoveryProvider.currentProfile;
    if (currentProfile == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Profile card
        Expanded(child: _buildProfileCard(currentProfile)),

        // Action buttons
        _buildActionButtons(discoveryProvider),
      ],
    );
  }

  Widget _buildProfileCard(UserModel profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image and basic info
          _buildProfileHeader(profile),
          const SizedBox(height: 16),

          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Text(profile.bio!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
          ],

          // Prompt responses (Hinge-style)
          ...profile.promptResponses.entries.map((entry) {
            return _buildPromptCard(entry.key, entry.value);
          }),

          // Roots section
          if (_hasRootsInfo(profile)) ...[
            _buildSectionTitle('Roots'),
            _buildRootsSection(profile),
          ],

          // Home & Future section
          if (_hasHomeFutureInfo(profile)) ...[
            _buildSectionTitle('Home & Future'),
            _buildHomeFutureSection(profile),
          ],

          // Values section
          if (_hasValuesInfo(profile)) ...[
            _buildSectionTitle('Values'),
            _buildValuesSection(profile),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel profile) {
    return Stack(
      children: [
        // Profile photo
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.secondaryBeige,
            image:
                profile.photoUrls.isNotEmpty
                    ? DecorationImage(
                      image: NetworkImage(profile.photoUrls.first),
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child:
              profile.photoUrls.isEmpty
                  ? const Icon(
                    Icons.person,
                    size: 120,
                    color: AppTheme.primaryBlue,
                  )
                  : null,
        ),

        // Gradient overlay and profile info
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.name}, ${profile.age}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (profile.hometown != null)
                  Text(
                    'From ${profile.hometown}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                if (profile.faithTradition != null)
                  Text(
                    profile.faithTradition!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptCard(String prompt, String response) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prompt,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(response, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  bool _hasRootsInfo(UserModel profile) {
    return profile.hometown != null ||
        profile.faithTradition != null ||
        profile.nonNegotiableValue != null;
  }

  Widget _buildRootsSection(UserModel profile) {
    return Column(
      children: [
        if (profile.hometown != null)
          _buildInfoItem('Hometown', profile.hometown!),
        if (profile.faithTradition != null)
          _buildInfoItem('Faith Tradition', profile.faithTradition!),
        if (profile.nonNegotiableValue != null)
          _buildInfoItem('Non-negotiable Value', profile.nonNegotiableValue!),
      ],
    );
  }

  bool _hasHomeFutureInfo(UserModel profile) {
    return profile.kidsPreference != null ||
        profile.relocationPreference != null ||
        profile.lifestylePreference != null ||
        profile.faithLevel != null;
  }

  Widget _buildHomeFutureSection(UserModel profile) {
    return Column(
      children: [
        if (profile.kidsPreference != null)
          _buildInfoItem('Kids', profile.kidsPreference!),
        if (profile.relocationPreference != null)
          _buildInfoItem('Relocation', profile.relocationPreference!),
        if (profile.lifestylePreference != null)
          _buildInfoItem('Lifestyle', profile.lifestylePreference!),
        if (profile.faithLevel != null)
          _buildInfoItem('Faith Level', profile.faithLevel!),
      ],
    );
  }

  bool _hasValuesInfo(UserModel profile) {
    return profile.politicalAlignment != null ||
        profile.traditionalRoles != null;
  }

  Widget _buildValuesSection(UserModel profile) {
    return Column(
      children: [
        if (profile.politicalAlignment != null)
          _buildInfoItem('Political Views', profile.politicalAlignment!),
        if (profile.traditionalRoles != null)
          _buildInfoItem(
            'Traditional Roles',
            profile.traditionalRoles! ? 'Important' : 'Not important',
          ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DiscoveryProvider discoveryProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip button
          ElevatedButton(
            onPressed: () {
              discoveryProvider.skipCurrentProfile();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.textLight,
              elevation: 4,
            ),
            child: const Icon(Icons.close, size: 32),
          ),

          // Like button
          ElevatedButton(
            onPressed: () {
              discoveryProvider.likeCurrentProfile();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            child: const Icon(Icons.favorite, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: AppTheme.textLight),
            const SizedBox(height: 16),
            Text(
              'No more profiles',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any more profiles matching your preferences. Try adjusting your filters or check back later.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.filterPreferences);
              },
              child: const Text('Adjust Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
