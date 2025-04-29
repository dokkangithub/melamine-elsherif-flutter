import 'package:flutter/material.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/extension/translate_extension.dart';

class LoginPrompt extends StatelessWidget {
  const LoginPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'already_have_account'.tr(context),
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            AppRoutes.navigateTo(context, AppRoutes.login);
          },
          child: Text(
            'login'.tr(context),
            style: TextStyle(
              color: Colors.indigo[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
