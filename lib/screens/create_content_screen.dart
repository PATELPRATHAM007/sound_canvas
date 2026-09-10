import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../ads/banner_ad_widget.dart';
import '../ads/interstitial_ad_manager.dart';

class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = 'Music';
  String _privacyLevel = 'Public';
  bool _isUploading = false;
  int _clickCounter = 0;

  final List<String> _categories = ['Music', 'Podcast', 'Art', 'Fashion', 'Tech'];
  final List<String> _tags = ['#Original', '#2026Vibes', '#NewRelease', '#AudioProduction'];

  void _handleActionWithInterstitial(VoidCallback action, String actionName) {
    _clickCounter++;
    debugPrint('[CreateContentScreen] Action clicked ($actionName). Count: $_clickCounter/2');
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

  void _publishContent() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title for your post'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    _handleActionWithInterstitial(() {
      setState(() => _isUploading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${_titleController.text}" published successfully! 🚀'),
            backgroundColor: const Color(0xFF5B46F6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        Navigator.pop(context);
      });
    }, 'Publish Content Button');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Create New Post',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media Upload Dropzone
                    GlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B46F6).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_rounded,
                                color: Color(0xFF5B46F6),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tap to upload Audio, Video or Art',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Supports MP3, WAV, MP4, PNG (Max 100MB)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title Input
                    const Text(
                      'Post Title',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Midnight Waves Synth Remix',
                          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description Input
                    const Text(
                      'Description & Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _descController,
                        maxLines: 3,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Add details about your creation...',
                          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Category Selection
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(cat),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          selectedColor: const Color(0xFF5B46F6),
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF5B46F6) : Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Privacy Settings
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
                              SizedBox(width: 8),
                              Text('Privacy:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          DropdownButton<String>(
                            value: _privacyLevel,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF5B46F6)),
                            items: ['Public', 'Followers Only', 'Private']
                                .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _privacyLevel = val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tags Section
                    const Text(
                      'Suggested Tags',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                          backgroundColor: Colors.white.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Banner Ad
                    const BannerAdWidget(),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B46F6),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: _isUploading ? null : _publishContent,
                        child: _isUploading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Publish Creation',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
