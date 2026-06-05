import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/home_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AVMGlobalApp());
}

class AVMGlobalApp extends StatelessWidget {
  const AVMGlobalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVM Global Consultants | Overseas Recruitment & Careers Abroad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0A192F), // Deep Navy
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A192F),
          primary: const Color(0xFF0A192F),
          secondary: const Color(0xFFD4AF37), // Gold
          surface: Colors.white,
          background: const Color(0xFFF8FAFC),
        ),
        fontFamily: 'Roboto', // Default sans-serif fallback
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0A192F)),
          displayMedium: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0A192F)),
          displaySmall: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
          bodyLarge: TextStyle(color: Color(0xFF334155), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFF475569), fontSize: 14),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A192F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}
