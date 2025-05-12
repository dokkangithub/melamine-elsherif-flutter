import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/widgets/cutsom_toast.dart';
import '../controller/auth_provider.dart';


class SocialLoginWidget extends StatelessWidget {
   const SocialLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: AppSvgs.google,
          onTap: () {
            onPressedGoogleLogin(context);
          },
        ),
        // const SizedBox(width: 16),
        // _buildSocialButton(
        //   icon: AppSvgs.facebook,
        //   onTap: () {
        //     // Handle Facebook login
        //   },
        // ),
        const SizedBox(width: 16),
        _buildSocialButton(
          icon: AppSvgs.apple,
          onTap: () {
            onPressedAppleLogin(context);
          },
        ),
      ],
    );
  }


   Future<void> onPressedGoogleLogin(context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      GoogleSignInAuthentication googleSignInAuthentication =
      await googleUser.authentication;
      String? accessToken = googleSignInAuthentication.accessToken;

      var loginResponse = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).completeSocialLogin(
        provider: "google",
        socialProvider: "google",
        name: googleUser.displayName ?? "",
        email: googleUser.email,
        secret_token: googleUser.id,
        access_token: accessToken,
      );
      if (loginResponse == true) {
        AppRoutes.navigateTo(context, AppRoutes.mainLayoutScreen);
        CustomToast.showToast(
          message: 'login_successfully'.tr(context),
          type: ToastType.success,
        );
      }

      // Disconnect after completion
      await googleSignIn.disconnect();


    } on Exception catch (e) {


      // Show error message to user
      CustomToast.showToast(
          message: 'Failed to sign in with Google: ${e.toString()}',
          type: ToastType.success
      );
    }
  }


   String _generateNonce([int length = 32]) {
     const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
     final random = Random.secure();
     return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
   }

   String _sha256ofString(String input) {
     final bytes = utf8.encode(input);
     final digest = sha256.convert(bytes);
     return digest.toString();
   }

   Future<void> onPressedAppleLogin(BuildContext context) async {
     try {
       final rawNonce = _generateNonce();
       final nonce = _sha256ofString(rawNonce);

       final appleCredential = await SignInWithApple.getAppleIDCredential(
         scopes: [
           AppleIDAuthorizationScopes.email,
           AppleIDAuthorizationScopes.fullName,
         ],
         nonce: nonce,
       );

       final name = [
         appleCredential.givenName,
         appleCredential.familyName
       ].where((e) => e != null && e.isNotEmpty).join(" ");

       final loginResponse = await Provider.of<AuthProvider>(
         context,
         listen: false,
       ).completeSocialLogin(
         provider: "apple",
         socialProvider: "apple",
         name: name,
         email: appleCredential.email ?? "",
         secret_token: appleCredential.userIdentifier,
         access_token: appleCredential.identityToken,
       );

       if (loginResponse == true) {
         AppRoutes.navigateTo(context, AppRoutes.mainLayoutScreen);
         CustomToast.showToast(
           message: 'login_successfully'.tr(context),
           type: ToastType.success,
         );
       }

     } catch (e) {
       CustomToast.showToast(
         message: 'Failed to sign in with Apple: ${e.toString()}',
         type: ToastType.error,
       );
     }
   }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(child: SvgPicture.asset(icon, width: 24, height: 24)),
      ),
    );
  }

}
