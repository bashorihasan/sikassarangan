import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sikassarangan/widgets/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF4A2C1D),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF4A2C1D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const AuthGate(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4A2C1D),
      body: SizedBox.expand(
        child: Image(
          image: AssetImage(
            'assets/splash_screen.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}