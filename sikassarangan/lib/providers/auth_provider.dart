import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import '../services/auth_api_service.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    AuthApiService? authApi,
  })  : _authService = authService ?? AuthService(),
        _authApi = authApi ?? AuthApiService() {
    _authSub = _authService.authStateChanges().listen(_onAuthStateChanged);
  }

  final AuthService _authService;
  final AuthApiService _authApi;

  late final StreamSubscription<User?> _authSub;
  StreamSubscription<String>? _tokenRefreshSub;

  AppUser? _appUser;
  bool _isBusy = false;
  bool _isSyncing = false;
  String _errorMessage = '';

  AppUser? get appUser => _appUser;
  bool get isBusy => _isBusy;
  bool get isSyncing => _isSyncing;
  String get errorMessage => _errorMessage;
  bool get isSignedIn => _authService.currentUser != null;

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _appUser = null;
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
      notifyListeners();
      return;
    }
    await _syncBackend();
  }

  Future<void> _syncBackend() async {
    _isSyncing = true;
    notifyListeners();
    try {
      _appUser = await _authApi.syncUser();
      await _registerFcm();
    } catch (error) {
      // Login tetap dianggap berhasil; sinkronisasi bisa dicoba lagi nanti.
      _errorMessage = 'Gagal sinkronisasi profil: $error';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _registerFcm() async {
    try {
      final push = PushNotificationService.instance;
      await push.requestPermission();
      final token = await push.getToken();
      if (token != null && token.isNotEmpty) {
        await _authApi.updateFcmToken(token);
      }
      _tokenRefreshSub ??= push.onTokenRefresh.listen((refreshed) async {
        try {
          await _authApi.updateFcmToken(refreshed);
        } catch (_) {
          // Abaikan; akan dicoba lagi saat refresh berikutnya.
        }
      });
    } catch (_) {
      // FCM bersifat opsional — jangan gagalkan proses login.
    }
  }

  Future<bool> signInWithEmail(String email, String password) {
    return _run(() =>
        _authService.signInWithEmail(email: email, password: password));
  }

  Future<bool> registerWithEmail(String name, String email, String password) {
    return _run(() => _authService.registerWithEmail(
          name: name,
          email: email,
          password: password,
        ));
  }

  Future<bool> signInWithGoogle() {
    return _run(() => _authService.signInWithGoogle());
  }

  Future<bool> _run(Future<Object?> Function() action) async {
    _isBusy = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = _mapFirebaseError(error);
      return false;
    } on GoogleSignInException catch (error) {
      // Batal oleh user bukan error yang perlu ditampilkan.
      _errorMessage = error.code == GoogleSignInExceptionCode.canceled
          ? ''
          : 'Google Sign-In gagal: ${error.description ?? error.code.name}';
      return false;
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: $error';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'network-request-failed':
        return 'Gagal terhubung ke jaringan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return error.message ?? 'Autentikasi gagal (${error.code}).';
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    _tokenRefreshSub?.cancel();
    super.dispose();
  }
}
