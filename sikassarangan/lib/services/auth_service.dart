import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Membungkus Firebase Authentication + Google Sign-In (google_sign_in v7).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // google_sign_in v7 wajib initialize() sekali sebelum authenticate().
  Future<void>? _googleInitialization;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> idToken({bool forceRefresh = false}) {
    final user = _auth.currentUser;
    if (user == null) {
      return Future<String?>.value(null);
    }
    return user.getIdToken(forceRefresh);
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      await credential.user?.updateDisplayName(trimmed);
      // reload + refresh token agar klaim `name` ikut di ID token berikutnya,
      // sehingga backend menyimpan nama yang benar saat sync-user.
      await credential.user?.reload();
      await credential.user?.getIdToken(true);
    }

    return credential;
  }

  Future<void> _ensureGoogleInitialized() {
    // `.then((_) {})` menormalkan hasil jadi Future<void> apa pun tipe kembalian
    // initialize() pada versi plugin yang dipakai.
    return _googleInitialization ??= _googleSignIn
        .initialize(serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'])
        .then((_) {});
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    // Melempar GoogleSignInException (code canceled) kalau user membatalkan.
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      // v7: disconnect() mencabut sesi Google agar login berikutnya menampilkan
      // pemilih akun. FirebaseAuth.signOut() di bawah yang mengakhiri sesi app.
      await _googleSignIn.disconnect();
    } catch (_) {
      // Abaikan (mis. user login via email/password, bukan Google).
    }
    await _auth.signOut();
  }
}
