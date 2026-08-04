import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Stashed registration state
  String? _contact;
  String? _code;
  String? _password;
  String? _firstName;
  String? _lastName;
  String? _gender;
  
  bool _isOtpEnabled = true;
  String _otpMethod = 'twilio'; // 'twilio' | 'smtp'

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get contact => _contact;
  String? get code => _code;
  String? get password => _password;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get gender => _gender;
  
  bool get isOtpEnabled => _isOtpEnabled;
  String get otpMethod => _otpMethod;

  bool get isAuthenticated => _token != null;
  bool get isOnboardingComplete {
    if (_user == null) return false;
    return _user!['username'] != null && _user!['firstName'] != null;
  }

  Future<void> _syncFCMToken() async {
    if (_token == null) return;
    try {
      final fcmToken = await NotificationService().getFCMToken();
      if (kDebugMode) {
        print('FCM Token: $fcmToken');
      }
      if (fcmToken != null) {
        await ApiService.updateFCMToken(_token!, fcmToken);
      }
    } catch (e) {
      debugPrint('Failed to sync FCM token: $e');
    }
  }

  // Load session from SharedPreferences
  Future<void> loadSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final userStr = prefs.getString('auth_user');
      if (userStr != null) {
        _user = jsonDecode(userStr);
      }
      if (_token != null) {
        _syncFCMToken();
      }
      
      // Fetch public settings for OTP requirement and method
      final settings = await ApiService.getPublicSettings();
      if (settings['settings'] != null) {
        final s = settings['settings'];
        if (s['registrationOtpEnabled'] != null) {
          _isOtpEnabled = s['registrationOtpEnabled'] as bool;
        }
        if (s['otpMethod'] != null) {
          _otpMethod = s['otpMethod'] as String;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send OTP — returns a record with success bool and whether OTP was mocked (skipped)
  Future<({bool success, bool mocked})> sendOtp(String contact, {String purpose = 'signup'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _contact = contact;
      final res = await ApiService.sendOtp(contact, purpose: purpose);
      if (res['error'] != null) {
        _errorMessage = res['error'];
        return (success: false, mocked: false);
      }
      final isMocked = res['mocked'] == true;
      return (success: true, mocked: isMocked);
    } catch (e) {
      _errorMessage = e.toString();
      return (success: false, mocked: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stash details
  void stashDetails({
    required String firstName,
    required String lastName,
    required String gender,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _gender = gender;
    notifyListeners();
  }

  void stashPasswordAndCode({required String password, required String code}) {
    _password = password;
    _code = code;
    notifyListeners();
  }

  // Fetch username suggestions
  Future<List<String>> getUsernameSuggestions(String base) async {
    try {
      final res = await ApiService.suggestUsernames(base);
      if (res['suggestions'] != null) {
        return List<String>.from(res['suggestions']);
      }
    } catch (_) {}
    return [];
  }

  // Complete Registration
  Future<bool> completeRegistration(String username) async {
    if (_contact == null ||
        _code == null ||
        _password == null ||
        _firstName == null ||
        _lastName == null ||
        _gender == null) {
      _errorMessage = "Incomplete registration details.";
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.register(
        contact: _contact!,
        code: _code!,
        password: _password!,
        firstName: _firstName!,
        lastName: _lastName!,
        username: username,
        gender: _gender!,
      );

      if (res['error'] != null) {
        _errorMessage = res['error'];
        return false;
      }

      _token = res['token'];
      _user = res['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('auth_user', jsonEncode(_user));
      _syncFCMToken();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String contact, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.login(contact: contact, password: password);
      if (res['error'] != null) {
        _errorMessage = res['error'];
        return false;
      }

      _token = res['token'];
      _user = res['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('auth_user', jsonEncode(_user));
      _syncFCMToken();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword(
    String contact,
    String code,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.resetPassword(
        contact: contact,
        code: code,
        newPassword: newPassword,
      );
      if (res['error'] != null) {
        _errorMessage = res['error'];
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final res = await ApiService.googleAuth(
        email: account.email,
        firstName: account.displayName?.split(' ').first ?? '',
        lastName: account.displayName?.split(' ').skip(1).join(' ') ?? '',
        idToken: auth.idToken ?? '',
      );

      if (res['error'] != null) {
        _errorMessage = res['error'];
        return false;
      }

      _token = res['token'];
      _user = res['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('auth_user', jsonEncode(_user));
      _syncFCMToken();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apple Sign In
  Future<bool> signInWithApple() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

      final res = await ApiService.appleAuth(
        email: credential.email,
        identityToken: credential.identityToken ?? '',
      );

      if (res['error'] != null) {
        _errorMessage = res['error'];
        return false;
      }

      _token = res['token'];
      _user = res['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('auth_user', jsonEncode(_user));
      _syncFCMToken();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Grant Permissions
  Future<bool> grantPermissions() async {
    if (_token == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.savePermissions(_token!);
      if (res['error'] != null) {
        _errorMessage = res['error'];
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Local User Object
  void updateUserLocally(Map<String, dynamic> updatedFields) async {
    if (_user == null) return;
    _user = {..._user!, ...updatedFields};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(_user));
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _user = null;
    _contact = null;
    _code = null;
    _password = null;
    _firstName = null;
    _lastName = null;
    _gender = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');

    final GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    notifyListeners();
  }

  Future<bool> blockUser(String targetUserId) async {
    if (_token == null) return false;
    try {
      await ApiService.blockUser(_token!, targetUserId);
      return true;
    } catch (e) {
      debugPrint("Error blocking user: $e");
      return false;
    }
  }
}
