import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:harbour/core/theme/app_theme.dart';
import 'package:harbour/core/constants/app_routes.dart';
import 'package:harbour/features/messaging/providers/messaging_provider.dart';
import 'package:harbour/models/message_model.dart';
import 'package:harbour/models/user_model.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  late String _matchId;
  late String _currentUserId;
  late UserModel _matchedUser;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If we already initialized, don't do it again
    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _matchId = args['matchId'] as String;
      _currentUserId = args['userId'] as String;
      _matchedUser = args['matchedUser'] as UserModel;

      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectConversation();
      });
    } else {
      // Handle missing arguments
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading conversation'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }

  void _onTextChanged() {
    setState(() {
      _isComposing = _messageController.text.isNotEmpty;
    });
  }

  Future<void> _selectConversation() async {
    final messagingProvider = Provider.of<MessagingProvider>(
      context,
      listen: false,
    );
    await messagingProvider.selectConversation(_matchId, _currentUserId);

    if (messagingProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messagingProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messagingProvider = Provider.of<MessagingProvider>(
      context,
      listen: false,
    );
    final messageText = _messageController.text.trim();
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    // Try to send the message
    await messagingProvider.sendMessage(messageText);

    if (messagingProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messagingProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Safely scroll to bottom after sending a message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          try {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } catch (e) {
            print('Error scrolling to bottom after send: $e');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagingProvider = Provider.of<MessagingProvider>(context);
    final messages = messagingProvider.currentConversation;

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.viewProfile, arguments: _matchedUser);
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.secondaryWarmBeige,
                backgroundImage:
                    _matchedUser.photoUrls.isNotEmpty
                        ? NetworkImage(_matchedUser.photoUrls.first)
                        : null,
                child:
                    _matchedUser.photoUrls.isEmpty
                        ? const Icon(
                          Icons.person,
                          color: AppTheme.primaryDeepBlue,
                          size: 16,
                        )
                        : null,
              ),
              const SizedBox(width: 8),
              Text(_matchedUser.name),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleConversationAction(value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'hide',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, size: 18),
                        SizedBox(width: 8),
                        Text('Hide'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'unmatch',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove, size: 18),
                        SizedBox(width: 8),
                        Text('Unmatch'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag, size: 18),
                        SizedBox(width: 8),
                        Text('Report'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child:
                messagingProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                    ? _buildEmptyConversation()
                    : _buildMessagesList(messages, _currentUserId),
          ),

          // Message input
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<MessageModel> messages, String currentUserId) {
    if (messages.isEmpty) {
      return _buildEmptyConversation();
    }

    // Sort messages by time (oldest first)
    final sortedMessages = List<MessageModel>.from(messages);
    sortedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Group messages by date
    final Map<String, List<MessageModel>> groupedMessages = {};
    for (final message in sortedMessages) {
      final dateString = DateFormat('yyyy-MM-dd').format(message.timestamp);
      if (!groupedMessages.containsKey(dateString)) {
        groupedMessages[dateString] = [];
      }
      groupedMessages[dateString]!.add(message);
    }

    // Build list items with date headers
    final List<Widget> listItems = [];
    groupedMessages.forEach((dateString, dateMessages) {
      // Add date header
      listItems.add(_buildDateHeader(DateTime.parse(dateString)));

      // Add messages for this date
      for (int i = 0; i < dateMessages.length; i++) {
        final message = dateMessages[i];
        final bool isCurrentUser = message.senderId == currentUserId;
        final bool showAvatar =
            i == 0 || dateMessages[i - 1].senderId != message.senderId;

        listItems.add(_buildMessageItem(message, isCurrentUser, showAvatar));
      }
    });

    // Safely scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        try {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } catch (e) {
          print('Error scrolling to bottom: $e');
        }
      }
    });

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: listItems,
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == DateTime(now.year, now.month, now.day)) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat.MMMd().format(date);
    }

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.secondaryWarmBeige,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          dateText,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildMessageItem(
    MessageModel message,
    bool isCurrentUser,
    bool showAvatar,
  ) {
    final time = DateFormat.jm().format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for other user
          if (!isCurrentUser && showAvatar)
            GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.viewProfile, arguments: _matchedUser);
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.secondaryWarmBeige,
                backgroundImage:
                    _matchedUser.photoUrls.isNotEmpty
                        ? NetworkImage(_matchedUser.photoUrls.first)
                        : null,
                child:
                    _matchedUser.photoUrls.isEmpty
                        ? const Icon(
                          Icons.person,
                          color: AppTheme.primaryDeepBlue,
                          size: 16,
                        )
                        : null,
              ),
            )
          else if (!isCurrentUser && !showAvatar)
            const SizedBox(width: 32), // Space for avatar alignment

          if (!isCurrentUser) const SizedBox(width: 8),

          // Message bubble
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentUser ? AppTheme.primaryDeepBlue : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isCurrentUser ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          isCurrentUser
                              ? Colors.white.withOpacity(0.7)
                              : AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isCurrentUser) const SizedBox(width: 8),

          // Read status for current user
          if (isCurrentUser)
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 16,
              color: message.isRead ? AppTheme.accentOlive : AppTheme.textTertiary,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyConversation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.viewProfile, arguments: _matchedUser);
            },
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.secondaryWarmBeige,
              backgroundImage:
                  _matchedUser.photoUrls.isNotEmpty
                      ? NetworkImage(_matchedUser.photoUrls.first)
                      : null,
              child:
                  _matchedUser.photoUrls.isEmpty
                      ? const Icon(
                        Icons.person,
                        color: AppTheme.primaryDeepBlue,
                        size: 48,
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You matched with ${_matchedUser.name}!',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation to get to know each other better.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: AppTheme.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppTheme.backgroundLight,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _isComposing ? _sendMessage() : null,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isComposing ? AppTheme.primaryDeepBlue : AppTheme.textTertiary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: Colors.white,
              onPressed: _isComposing ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  // Handle conversation actions (hide, unmatch, report)
  void _handleConversationAction(String action) {
    switch (action) {
      case 'hide':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversation with ${_matchedUser.name} hidden'),
          ),
        );
        break;
      case 'unmatch':
        _showUnmatchDialog();
        break;
      case 'report':
        _showReportDialog();
        break;
    }
  }

  // Show confirmation dialog for unmatching
  void _showUnmatchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unmatch'),
            content: Text(
              'Are you sure you want to unmatch with ${_matchedUser.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Implement unmatching logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unmatched with ${_matchedUser.name}'),
                    ),
                  );
                  // Return to matches screen after unmatching
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Unmatch',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Show report dialog
  void _showReportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why are you reporting ${_matchedUser.name}?'),
                const SizedBox(height: 16),
                _buildReportOption('Inappropriate photos'),
                _buildReportOption('Spam/Scammer'),
                _buildReportOption('Offensive behavior'),
                _buildReportOption('Fake profile'),
                _buildReportOption('Other'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Widget _buildReportOption(String reason) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Report submitted: $reason')));
        // Return to matches screen after reporting
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.flag_outlined, size: 18),
            const SizedBox(width: 12),
            Text(reason),
          ],
        ),
      ),
    );
  }
}
