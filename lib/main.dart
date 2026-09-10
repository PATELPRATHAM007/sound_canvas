import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ads/ad_manager.dart';
import 'screens/main_shell_screen.dart';

import 'services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection ServiceLocator
  ServiceLocator.init();

  // Initialize Unity LevelPlay Mediation SDK safely at startup
  try {
    await AdManager.instance.initialize(enableTestMode: true);
  } catch (e) {
    debugPrint('[main] AdManager init warning: $e');
  }

  runApp(const SoundCanvasApp());
}

class SoundCanvasApp extends StatelessWidget {
  const SoundCanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundCanvas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B46F6),
          surface: const Color(0xFFD9E2F7),
        ),
        scaffoldBackgroundColor: const Color(0xFFD9E2F7),
      ),
      home: const MainShellScreen(),
    );
  }
}

// Alias for backward compatibility
typedef DiscoverApp = SoundCanvasApp;
