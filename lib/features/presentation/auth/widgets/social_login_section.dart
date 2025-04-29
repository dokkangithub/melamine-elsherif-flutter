import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'social_button.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // OR Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or'.tr(context),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
          ],
        ),
        const SizedBox(height: 24),

        // Social Login Buttons
        SocialButton(),
      ],
    );
  }
}
