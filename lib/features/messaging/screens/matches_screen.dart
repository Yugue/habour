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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  Future<void> _loadMatches() async {
    final authProvider = Provider.of<app_auth.AuthProvider>(
      context,
      listen: false,
    );
    final messagingProvider = Provider.of<MessagingProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      await messagingProvider.loadMatches(authProvider.user!.uid);
    } else {
      // In development mode, we can load matches with a fake user ID
      await messagingProvider.loadMatches('dev-user-id');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final messagingProvider = Provider.of<MessagingProvider>(context);
    final authProvider = Provider.of<app_auth.AuthProvider>(context);

    // Get userId - use a development ID if auth.user is null
    final String userId = authProvider.user?.uid ?? 'dev-user-id';

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body:
          messagingProvider.isLoading
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
        final match = sortedMatches[index];
        final matchedUser = messagingProvider.getMatchedUser(match);

        if (matchedUser == null) {
          return const SizedBox.shrink();
        }

        return _buildMatchListItem(match, matchedUser, currentUserId);
      },
    );
  }

  Widget _buildMatchListItem(
    MatchModel match,
    UserModel matchedUser,
    String currentUserId,
  ) {
    final bool hasMessages = match.messageCount > 0;
    final bool hasUnreadMessages = match.hasUnreadMessages;
    final bool isNewMatch = !hasMessages && match.matchedAt != null;

    // Determine if the current user is the receiver of the last message
    final bool isCurrentUserReceiver =
        hasMessages &&
            match.lastMessageAt != null &&
            (match.user1Id == currentUserId && match.user2LikedUser1) ||
        (match.user2Id == currentUserId && match.user1LikedUser2);

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
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.secondaryBeige,
        backgroundImage:
            matchedUser.photoUrls.isNotEmpty
                ? NetworkImage(matchedUser.photoUrls.first)
                : null,
        child:
            matchedUser.photoUrls.isEmpty
                ? const Icon(
                  Icons.person,
                  color: AppTheme.primaryBlue,
                  size: 28,
                )
                : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              matchedUser.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight:
                    hasUnreadMessages && isCurrentUserReceiver
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (match.lastMessageAt != null)
            Text(
              _formatMessageTime(match.lastMessageAt!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    hasUnreadMessages && isCurrentUserReceiver
                        ? AppTheme.primaryBlue
                        : AppTheme.textLight,
              ),
            ),
        ],
      ),
      subtitle:
          hasMessages
              ? Text(
                match.lastMessagePreview ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      hasUnreadMessages && isCurrentUserReceiver
                          ? FontWeight.bold
                          : FontWeight.normal,
                  color:
                      hasUnreadMessages && isCurrentUserReceiver
                          ? AppTheme.textDark
                          : AppTheme.textMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              : Text(
                isNewMatch
                    ? 'New match! Say hello!'
                    : 'You matched with ${matchedUser.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontStyle: FontStyle.italic,
                ),
              ),
      trailing:
          hasUnreadMessages && isCurrentUserReceiver
              ? Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue,
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
              color: AppTheme.textLight,
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
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textMedium),
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
