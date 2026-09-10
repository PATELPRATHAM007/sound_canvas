import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../ads/banner_ad_widget.dart';
import '../ads/interstitial_ad_manager.dart';

class MessagesScreen extends StatefulWidget {
  final bool showBackButton;
  const MessagesScreen({super.key, this.showBackButton = true});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _clickCounter = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _onlineUsers = [
    {'name': 'Luna E.', 'avatar': '👩‍🎤', 'status': 'Online'},
    {'name': 'Alex V.', 'avatar': '🎧', 'status': 'Recording'},
    {'name': 'Elena R.', 'avatar': '🎨', 'status': 'Online'},
    {'name': 'Marcus K.', 'avatar': '💻', 'status': 'Streaming'},
    {'name': 'Sophia M.', 'avatar': '✨', 'status': 'Away'},
  ];

  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Luna Eclipse',
      'avatar': '👩‍🎤',
      'lastMessage': 'Hey! Check out the new synth track I just finished producing 🎶',
      'time': '10:42 AM',
      'unread': 2,
      'isOnline': true,
    },
    {
      'name': 'Elena Rostova',
      'avatar': '🎨',
      'lastMessage': 'The artwork for the album cover looks fantastic!',
      'time': '09:15 AM',
      'unread': 0,
      'isOnline': true,
    },
    {
      'name': 'Alex Vance',
      'avatar': '🎧',
      'lastMessage': 'Are we still collaborating on the Friday stream?',
      'time': 'Yesterday',
      'unread': 1,
      'isOnline': false,
    },
    {
      'name': 'TechPulse Community',
      'avatar': '💻',
      'lastMessage': 'New event: AI Music Creation Masterclass next week.',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': false,
    },
    {
      'name': 'Sophia Martinez',
      'avatar': '✨',
      'lastMessage': 'Loved your latest post on streetwear aesthetic!',
      'time': '2 days ago',
      'unread': 0,
      'isOnline': false,
    },
  ];

  void _handleActionWithInterstitial(VoidCallback action, String actionName) {
    _clickCounter++;
    debugPrint('[MessagesScreen] Action clicked ($actionName). Count: $_clickCounter/2');
    if (_clickCounter >= 2) {
      _clickCounter = 0;
      InterstitialAdManager.instance.showInterstitialWithFallback(
        onProceed: action,
        context: context,
      );
    } else {
      action();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((c) {
      return (c['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c['lastMessage'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
              child: Row(
                children: [
                  if (widget.showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  const Expanded(
                    child: Text(
                      'Direct Messages',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_square, color: Color(0xFF5B46F6)),
                    onPressed: () {
                      _handleActionWithInterstitial(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Start new conversation'),
                            backgroundColor: const Color(0xFF5B46F6),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }, 'New Chat Button');
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: GlassContainer(
                borderRadius: 22,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Search chats or creators...',
                    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Online Active Creators Horizon Bar
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _onlineUsers.length,
                itemBuilder: (context, index) {
                  final user = _onlineUsers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        _handleActionWithInterstitial(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening chat with ${user['name']}'),
                              backgroundColor: const Color(0xFF5B46F6),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        }, 'Click Online Creator ${user['name']}');
                      },
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: Text(user['avatar']!, style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00C853),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['name']!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Banner Ad Widget
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: BannerAdWidget(),
            ),

            const SizedBox(height: 12),

            // Chat Conversations List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _filteredConversations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final chat = _filteredConversations[index];
                  final unread = chat['unread'] as int;

                  return GestureDetector(
                    onTap: () {
                      _handleActionWithInterstitial(() {
                        setState(() {
                          chat['unread'] = 0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opened Chat with ${chat['name']}'),
                            backgroundColor: const Color(0xFF5B46F6),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }, 'Open Chat ${chat['name']}');
                    },
                    child: GlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Center(
                              child: Text(chat['avatar'] as String, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      chat['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      chat['time'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chat['lastMessage'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                                    color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Unread Badge
                          if (unread > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B46F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unread.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
