import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/transaksi_provider.dart';
import 'screens/home_screen.dart';
import 'services/transaksi_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const SiKasSaranganApp());
}

class SiKasSaranganApp extends StatelessWidget {
  const SiKasSaranganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransaksiProvider(TransaksiService())..loadDashboard(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'siKasSarangan',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
