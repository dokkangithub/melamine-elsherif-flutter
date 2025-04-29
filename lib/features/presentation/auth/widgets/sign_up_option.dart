import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import '../../../../core/config/routes.dart/routes.dart';

class SignUpOption extends StatelessWidget {
  const SignUpOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'don\'t_have_an_account?'.tr(context),
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
