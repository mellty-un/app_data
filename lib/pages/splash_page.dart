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

  Future.delayed(const Duration(seconds: 10), () {
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
        color: const Color.fromARGB(255, 58, 118, 167), 
        child: const Center(
          child: Image(
            image: AssetImage("assets/images/logo.png"),
            width: 130,
            height: 200,
          ),
        ),
      ),
    ); 
  }
}
