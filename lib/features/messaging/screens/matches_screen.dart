import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:harbour/core/constants/app_routes.dart';
import 'package:harbour/core/theme/app_theme.dart';
import 'package:harbour/features/auth/providers/auth_provider.dart' as app_auth;
import 'package:harbour/features/messaging/providers/messaging_provider.dart';
import 'package:harbour/models/match_model.dart';
import 'package:harbour/models/user_model.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Track last reload time to prevent too frequent reloads
  DateTime _lastReloadTime = DateTime.now().subtract(
    const Duration(minutes: 5),
  );
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Initial load only in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches(isInitialLoad: true);
    });
  }

  // Only reload when the tab is selected or page is revisited
  void reloadIfNeeded() {
    // Only reload if it's been at least 5 seconds since the last reload
    final now = DateTime.now();
    if (now.difference(_lastReloadTime).inSeconds >= 5) {
      _loadMatches();
    }
  }

  Future<void> _loadMatches({bool isInitialLoad = false}) async {
    // Prevent duplicate loads
    if (!isInitialLoad) {
      final now = DateTime.now();
      if (now.difference(_lastReloadTime).inSeconds < 5) {
        return;
      }
    }

    _lastReloadTime = DateTime.now();

    final authProvider = Provider.of<app_auth.AuthProvider>(
      context,
      listen: false,
    );
    final messagingProvider = Provider.of<MessagingProvider>(
      context,
      listen: false,
    );

    final String userId = authProvider.user?.uid ?? 'dev-user-id';
    await messagingProvider.loadMatches(userId);

    // Mark first load as complete
    if (_isFirstLoad) {
      setState(() {
        _isFirstLoad = false;
      });
    }
  }

  // Add a simple manual refresh action for the app bar
  void _refreshMatches() {
    _loadMatches(isInitialLoad: true); // Force refresh
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Request a reload when the screen is built (but with throttling)
    if (!_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        reloadIfNeeded();
      });
    }

    final messagingProvider = Provider.of<MessagingProvider>(context);
    final authProvider = Provider.of<app_auth.AuthProvider>(context);

    // Get userId - use a development ID if auth.user is null
    final String userId = authProvider.user?.uid ?? 'dev-user-id';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _refreshMatches,
            tooltip: 'Refresh matches',
          ),
        ],
      ),
      body: messagingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMatchesList(messagingProvider, userId),
    );
  }

  Widget _buildMatchesList(
    MessagingProvider messagingProvider,
    String currentUserId,
  ) {
    if (messagingProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading matches',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              messagingProvider.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadMatches, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (messagingProvider.matches.isEmpty) {
      return _buildEmptyState();
    }

    // Sort matches: new matches (no messages) first, then by last message time
    final sortedMatches = List<MatchModel>.from(messagingProvider.matches);
    sortedMatches.sort((a, b) {
      // First sort by message status
      if (a.messageCount == 0 && b.messageCount > 0) {
        return -1;
      } else if (a.messageCount > 0 && b.messageCount == 0) {
        return 1;
      }

      // Then sort by last message time (most recent first)
      if (a.lastMessageAt == null && b.lastMessageAt == null) {
        return a.createdAt.compareTo(b.createdAt);
      } else if (a.lastMessageAt == null) {
        return 1;
      } else if (b.lastMessageAt == null) {
        return -1;
      }

      return b.lastMessageAt!.compareTo(a.lastMessageAt!);
    });

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: sortedMatches.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        if (index < 0 || index >= sortedMatches.length) {
          return const SizedBox.shrink(); // Protect against out-of-bounds
        }

        final match = sortedMatches[index];
        return _buildMatchItem(context, match, currentUserId);
      },
    );
  }

  Widget _buildMatchItem(
    BuildContext context,
    MatchModel match,
    String currentUserId,
  ) {
    // Determine if this is the current user's turn
    final bool isCurrentUserTurn = match.isCurrentUserTurn;
    final bool isCurrentUserReceiver = !isCurrentUserTurn;
    final bool isYourTurn = isCurrentUserTurn;

    // Find the matched user
    final messagingProvider = Provider.of<MessagingProvider>(
      context,
      listen: false,
    );
    final UserModel? matchedUser = messagingProvider.getMatchedUser(match);

    if (matchedUser == null) {
      return const SizedBox.shrink(); // Skip if user not found
    }

    // Determine if there are messages in this conversation
    final bool hasMessages =
        match.messageCount > 0 && match.lastMessagePreview != null;
    final bool hasUnreadMessages = match.hasUnreadMessages;
    final bool isNewMatch = match.messageCount == 0 &&
        match.matchedAt != null &&
        DateTime.now().difference(match.matchedAt!).inDays < 1;

    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.conversation,
          arguments: {
            'matchId': match.id,
            'userId': currentUserId,
            'matchedUser': matchedUser,
          },
        );
      },
      leading: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.viewProfile, arguments: matchedUser);
        },
        child: CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.secondaryWarmBeige,
          backgroundImage: matchedUser.photoUrls.isNotEmpty
              ? NetworkImage(matchedUser.photoUrls.first)
              : null,
          child: matchedUser.photoUrls.isEmpty
              ? const Icon(
                  Icons.person,
                  color: AppTheme.primaryDeepBlue,
                  size: 36,
                )
              : null,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              matchedUser.name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (match.lastMessageAt != null)
            Text(
              _formatMessageTime(match.lastMessageAt!),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
            ),
        ],
      ),
      subtitle: hasMessages
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.lastMessagePreview ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: hasUnreadMessages && isCurrentUserReceiver
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: hasUnreadMessages && isCurrentUserReceiver
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          : Text(
              isNewMatch
                  ? 'New match! Say hello!'
                  : 'You matched with ${matchedUser.name}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryDeepBlue,
                    fontStyle: FontStyle.italic,
                  ),
            ),
      trailing: isYourTurn
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasUnreadMessages && isCurrentUserReceiver)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryDeepBlue,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Your turn',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            )
          : hasUnreadMessages && isCurrentUserReceiver
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryDeepBlue,
                  ),
                )
              : null,
    );
  }

  String _formatMessageTime(DateTime messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays > 7) {
      return DateFormat.MMMd().format(messageTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No matches yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'When you connect with someone, they\'ll appear here. Start discovering potential matches!',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to discovery screen
                Navigator.of(context).pushNamed(AppRoutes.discovery);
              },
              child: const Text('Discover Profiles'),
            ),
          ],
        ),
      ),
    );
  }
}
