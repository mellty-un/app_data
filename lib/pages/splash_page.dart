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

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background dengan custom painter
          Positioned.fill(
            child: CustomPaint(
              painter: SplashBackgroundPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background biru gradasi
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: [Color(0xFF0770D9), Color(0xFF005BBB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Wave putih di bawah
    final whitePaint = Paint()..color = Colors.white;

    Path path = Path();
    path.moveTo(0, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.60,
      size.width * 0.40, size.height * 0.70,
    );
    path.quadraticBezierTo(
      size.width * 0.55, size.height * 0.80,
      size.width * 0.70, size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.55,
      size.width, size.height * 0.65,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, whitePaint);

    // Gelembung kecil (sudah dinaikkan biar gak kepotong)
    canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.55), 18, whitePaint);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.63), 12, whitePaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.52), 10, whitePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
