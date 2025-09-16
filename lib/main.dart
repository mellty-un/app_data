import 'package:applikasi_identitas/pages/home_page.dart';
import 'package:applikasi_identitas/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://snrhktyailtpikdmkymr.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNucmhrdHlhaWx0cGlrZG1reW1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5OTAzOTQsImV4cCI6MjA3MzU2NjM5NH0.XyUAV8ePku4CeS0sqpaAQ4aLL20rn9ZDG7gBh5GryP4', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Data Siswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF2C3E50),
      ),
      home: const SplashScreen(), 
    );
  }
}
