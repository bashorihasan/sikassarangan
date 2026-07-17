import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sikassarangan/config/firebase_options.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'providers/auth_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/transaksi_provider.dart';
import 'services/push_notification_service.dart';
import 'services/transaksi_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

// Navigator global agar push notification bisa navigasi tanpa BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Handler pesan FCM saat app di background/terminated. Wajib top-level.
// Notifikasi ditampilkan otomatis oleh OS; riwayat sudah tersimpan di server.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationService.instance.initialize(navigatorKey);
  runApp(const SiKasSaranganApp());
}

class SiKasSaranganApp extends StatelessWidget {
  const SiKasSaranganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider(TransaksiService())),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'siKasSarangan',
        theme: AppTheme.lightTheme,
        navigatorKey: navigatorKey,
        home: const SplashScreen(),
      ),
    );
  }
}
