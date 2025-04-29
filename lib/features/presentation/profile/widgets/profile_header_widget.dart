import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../controller/profile_provider.dart';
import '../screens/edit_profile_screen.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AppStrings.token != null;
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              color: AppTheme.accentColor.withValues(alpha: 0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: profileProvider.profileImageUrl != null
                  ? CustomImage(
                imageUrl:  profileProvider.profileImageUrl!,
                fit: BoxFit.cover,
              )
                  : const Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.userName ?? 'guest_user'.tr(context),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            AppStrings.userEmail ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          if (isLoggedIn)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              child: Text(
                'edit_profile'.tr(context),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}