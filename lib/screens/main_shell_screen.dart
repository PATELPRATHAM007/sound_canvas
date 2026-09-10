import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_bottom_nav.dart';
import '../ads/interstitial_ad_manager.dart';
import 'discover_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'create_content_screen.dart';

import '../widgets/mini_player_bar.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentTabIndex = 0;
  int _clickCounter = 0;

  final List<Widget> _pages = const [
    DiscoverScreen(),
    SearchScreen(showBackButton: false),
    NotificationsScreen(showBackButton: false),
    ProfileScreen(showBackButton: false),
  ];

  void _handleActionWithInterstitial(VoidCallback action, String actionName) {
    _clickCounter++;
    debugPrint('[MainShellScreen] Action clicked ($actionName). Count: $_clickCounter/2');
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

  void _onTabSelected(int index) {
    _handleActionWithInterstitial(() {
      setState(() {
        _currentTabIndex = index;
      });
    }, 'Switch Tab $index');
  }

  void _openCreateContent() {
    _handleActionWithInterstitial(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateContentScreen()),
      );
    }, 'Floating Add Content Button');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Active Page Body
          IndexedStack(
            index: _currentTabIndex,
            children: _pages,
          ),

          // Floating Mini Player & Bottom Navigation Column
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayerBar(),
                FloatingBottomNav(
                  selectedIndex: _currentTabIndex,
                  onTabSelected: _onTabSelected,
                  onAddPressed: _openCreateContent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
