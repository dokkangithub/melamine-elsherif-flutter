import 'package:flutter/material.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/extension/translate_extension.dart';

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'dont_have_account'.tr(context),
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            AppRoutes.navigateTo(context, AppRoutes.signUp);
          },
          child: Text(
            'sign_up'.tr(context),
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
