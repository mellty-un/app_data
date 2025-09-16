import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkSupabaseConnection();
  }

Future<void> checkSupabaseConnection() async {
  try {
    final data = await Supabase.instance.client
        .from('wilayah')
        .select()
        .limit(1)
        .maybeSingle(); 

    if (data != null) {
      print("✅ Berhasil terhubung ke Supabase!");
    } else {
      print("Terhubung, tapi tabel kosong");
    }
  } catch (e) {
    print("❌ Terjadi error saat cek koneksi: $e");
  }

  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1F80E2),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: const Center(
          child: Image(
            image: AssetImage("assets/images/logo.png"),
            width: 400,
            height: 200,
          ),
        ),
      ),
    );
  }
}
