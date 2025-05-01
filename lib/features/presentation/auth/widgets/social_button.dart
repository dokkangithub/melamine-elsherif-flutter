import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, GoogleAuthProvider, UserCredential;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io' show Platform;

import '../../../../core/utils/constants/app_assets.dart';
import '../controller/auth_provider.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _socialButton(
          onPressed: () => _handleGoogleSignIn(context, authProvider),
          icon: AppIcons.google,
          color: Colors.red,
        ),
        _socialButton(
          onPressed: () => _handleFacebookSignIn(context, authProvider),
          icon: AppIcons.facebook,
          color: Colors.blue[800]!,
        ),
        if (Platform.isIOS)
          _socialButton(
            onPressed: () => _handleAppleSignIn(context, authProvider),
            icon: AppIcons.apple,
            color: Colors.black,
          ),
      ],
    );
  }

  Widget _socialButton({
    required VoidCallback onPressed,
    required String icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Image.asset(icon, height: 20, width: 20)),
      ),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context, AuthProvider authProvider) async {
    try {
      // Sign in with Firebase
      final userCredential = await signInWithGoogle();

      if (userCredential != null) {
        // Get the Firebase auth token
        final idToken = await userCredential.user?.getIdToken();

        if (idToken != null) {
          // Send token to your backend
          final success = await authProvider.completeSocialLogin('google', idToken);

          if (success) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(authProvider.errorMessage ?? 'Google sign-in failed'))
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in with Google: $e'.tr(context)))
      );
    }
  }

  Future<void> _handleFacebookSignIn(BuildContext context, AuthProvider authProvider) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Get the access token
        final String accessToken = result.accessToken!.tokenString ?? '';

        // Send token to your backend
        final bool success = await authProvider.completeSocialLogin('facebook', accessToken);

        if (success) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.errorMessage ?? 'Facebook sign-in failed'))
          );
        }
      } else {
        // Handle canceled or failed login
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('facebook_login_failed_or_canceled'.tr(context)))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in with Facebook: $e'))
      );
    }
  }

  /// Generates a secure random nonce for Apple Sign-in
  String _generateNonce() {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = List.generate(32, (_) => charset[DateTime.now().microsecondsSinceEpoch % charset.length]);
    return random.join('');
  }

  /// Converts nonce to a SHA256 hash
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _handleAppleSignIn(BuildContext context, AuthProvider authProvider) async {
    try {
      // Generate nonce and its SHA256 hash
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credentials for Apple Sign In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Get the authorization code or ID token
      final appleToken = credential.identityToken ?? '';

      // Send this token to your backend
      final bool success = await authProvider.completeSocialLogin('apple', appleToken);

      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage ?? 'Apple sign-in failed'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in with Apple: $e'.tr(context)))
      );
    }
  }
}