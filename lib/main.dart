import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://hesglasczqhzblhkrmyv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhlc2dsYXNjenFoemJsaGtybXl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxODczNjYsImV4cCI6MjA5Mzc2MzM2Nn0.3QqCstXvmim7wgyNoZmfCK1yqUG4Il5j1vs3aRgTheU',
  );

  runApp(
    const ProviderScope(
      child: FitnessAIApp(),
    ),
  );
}

class FitnessAIApp extends StatelessWidget {
  const FitnessAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'Fitness AI Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF2563EB),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      ),
      // Si no hay sesión, muestra el Login; si hay, el Onboarding.
      home: session == null ? const AuthScreen() : const OnboardingScreen(),
    );
  }
}
