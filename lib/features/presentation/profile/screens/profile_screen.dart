import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/text_style_extension.dart';
import '../../auth/controller/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../controller/profile_provider.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.getUserProfile();
      profileProvider.getProfileCounters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final counters = profileProvider.profileCounters;
    final isLoggedIn = AppStrings.token != null;
    final isLoadingCounters =
        profileProvider.countersState == LoadingState.loading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
              // User Header
              Container(
                alignment: Alignment.center,
                color: Colors.white,

                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child:
                            profileProvider.profileImageUrl != null
                                ? CustomImage(
                                  imageUrl: profileProvider.profileImageUrl!,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.userName ?? 'Guest User',
                            style: context.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.userEmail ?? '',
                            style: context.bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Edit Button
                    CustomButton(
                      onPressed: () {
                        AppRoutes.navigateTo(
                          context,
                          AppRoutes.editProfileScreen,
                        );
                      },
                      isOutlined: true,
                      child: Text(
                        'Edit',
                        style: context.titleSmall.copyWith(
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats Section
              if (isLoggedIn && !isLoadingCounters && counters != null)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        context,
                        counters.orderCount.toString(),
                        'orders'.tr(context),
                        AppSvgs.profile_bag,
                      ),
                      _buildStatItem(
                        context,
                        counters.wishlistItemCount.toString(),
                        'saved'.tr(context),
                        AppSvgs.profile_fav,
                      ),
                      _buildStatItem(
                        context,
                        '${counters.cartItemCount + counters.wishlistItemCount * 5}',
                        'points'.tr(context),
                        AppSvgs.profile_coin,
                      ),
                      _buildStatItem(
                        context,
                        '${counters.orderCount }',
                        'reviews'.tr(context),
                        AppSvgs.profile_star,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // Quick Access Section
              Container(
                color: Colors.white,
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildQuickAccessItem(
                        context,
                        AppSvgs.profile_bag,
                        'my_orders'.tr(context),
                        () => AppRoutes.navigateTo(
                          context,
                          AppRoutes.allOrdersListScreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickAccessItem(
                        context,
                        AppSvgs.profile_location,
                        'shipping_address'.tr(context),
                        () => AppRoutes.navigateTo(
                          context,
                          AppRoutes.addressListScreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Menu Items
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: AppSvgs.profile_person,
                      title: 'personal_information'.tr(context),
                      onTap: () {
                        AppRoutes.navigateTo(
                          context,
                          AppRoutes.editProfileScreen,
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: AppSvgs.profile_notifications,
                      title: 'notifications'.tr(context),
                      onTap: () {
                        // Navigate to notifications
                      },
                    ),
                    ProfileMenuItem(
                      icon: AppSvgs.profile_privacy,
                      title: 'privacy_security'.tr(context),
                      onTap: () {
                        // Navigate to privacy
                      },
                    ),
                    ProfileMenuItem(
                      icon: AppSvgs.profile_language,
                      title: 'language_region'.tr(context),
                      onTap: () {
                        // Show language selection
                      },
                    ),
                    ProfileMenuItem(
                      icon: AppSvgs.profile_help,
                      title: 'help_support'.tr(context),
                      onTap: () {
                        // Navigate to help
                      },
                    ),
                    ProfileMenuItem(
                      icon: AppSvgs.profile_about_us,
                      title: 'about_us'.tr(context),
                      onTap: () {
                        // Navigate to about
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sign Out Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: CustomButton(
                  onPressed: () {
                    _showLogoutConfirmation(context);
                  },
                  isOutlined: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: AppTheme.primaryColor),
                      SizedBox(width: 6),
                      Text('sign_out'.tr(context),
                        style: context.titleMedium.copyWith(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    String icon,
  ) {
    return Column(
      children: [
        CustomImage(assetPath: icon),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: context.bodySmall.copyWith(color: Colors.grey[600])),
      ],
    );
  }



  Widget _buildQuickAccessItem(
    BuildContext context,
    String icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: AppTheme.primaryColor.withValues(alpha: 0.1)),
        child: Row(
          children: [
            CustomImage(assetPath: icon),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: context.bodyMedium.copyWith(fontWeight: FontWeight.w800))),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final navigatorContext = context;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
        title: Text('logout'.tr(navigatorContext),),
        content: Text('confirm_logout'.tr(navigatorContext)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr(navigatorContext),style: context.titleSmall.copyWith(color: AppTheme.darkDividerColor),),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await navigatorContext.read<AuthProvider>().logout();
              AppStrings.userId = null;
              AppStrings.token = null;

              if (navigatorContext.mounted) {
                Navigator.of(navigatorContext).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: Text(
              'logout'.tr(navigatorContext),
              style: context.titleSmall.copyWith(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }



}
