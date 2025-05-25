import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/text_style_extension.dart';
import '../../auth/controller/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../club_point/controller/club_point_provider.dart';
import '../controller/profile_provider.dart';
import '../widgets/profile_menu_item.dart';
import '../../../../core/utils/widgets/premium_language_dialog.dart';
import 'package:radial_button/widget/circle_floating_button.dart';
import 'package:quickalert/quickalert.dart';

class ProfileScreen extends StatefulWidget {
  final bool isActive;
  const ProfileScreen({super.key, this.isActive = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    _shouldAnimate = widget.isActive;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.getUserProfile();
      profileProvider.getProfileCounters();

      // Load club points data
      if (AppStrings.token != null) {
        context.read<ClubPointProvider>().fetchClubPoints();
      }
    });
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        _shouldAnimate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final clubPointProvider = Provider.of<ClubPointProvider>(context);
    final counters = profileProvider.profileCounters;
    final isLoggedIn = AppStrings.token != null;
    final isLoadingCounters =
        profileProvider.countersState == LoadingState.loading;

    // Get the text direction to adjust the FAB position accordingly
    final TextDirection textDirection = Directionality.of(context);
    final FloatingActionButtonLocation fabLocation = textDirection == TextDirection.rtl
        ? FloatingActionButtonLocation.startFloat  // For RTL (Arabic)
        : FloatingActionButtonLocation.endFloat;   // For LTR (English)

    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: _buildFloatingActionButton(context),
        floatingActionButtonLocation: fabLocation,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Different UI based on login status
                _shouldAnimate
                    ? FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: isLoggedIn
                      ? _buildLoggedInUserHeader(context, profileProvider)
                      : _buildGuestUserHeader(context),
                )
                    : isLoggedIn
                    ? _buildLoggedInUserHeader(context, profileProvider)
                    : _buildGuestUserHeader(context),


                // // Stats Section - only for logged in users
                // if (isLoggedIn && !isLoadingCounters && counters != null)
                //   _shouldAnimate
                //     ? FadeInUp(
                //         delay: const Duration(milliseconds: 200),
                //         duration: const Duration(milliseconds: 400),
                //         child: _buildStatsSection(context, counters, clubPointProvider),
                //       )
                //     : _buildStatsSection(context, counters, clubPointProvider),
                //
                // const SizedBox(height: 10),

                // Quick Access Section - only for logged in users
                if (isLoggedIn && !isLoadingCounters && counters != null)
                  _shouldAnimate
                      ? FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 400),
                    child: _buildQuickAccessSection(context),
                  )
                      : _buildQuickAccessSection(context),

                const SizedBox(height: 10),

                // Menu Items - different for guest vs logged in
                _shouldAnimate
                    ? FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 500),
                  child: isLoggedIn
                      ? _buildLoggedInMenuItems(context)
                      : _buildGuestMenuItems(context),
                )
                    : isLoggedIn
                    ? _buildLoggedInMenuItems(context)
                    : _buildGuestMenuItems(context),

                const SizedBox(height: 20),

                // Auth Button (Sign Out or Sign In)
                _shouldAnimate
                    ? ZoomIn(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 300),
                  child: isLoggedIn
                      ? _buildSignOutButton(context)
                      : _buildSignInButton(context),
                )
                    : isLoggedIn
                    ? _buildSignOutButton(context)
                    : _buildSignInButton(context),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ));
  }

  // Build the stats section with counters
  Widget _buildStatsSection(BuildContext context, profileCounters, ClubPointProvider clubPointProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            profileCounters.orderCount.toString(),
            'orders'.tr(context),
            AppSvgs.profile_bag,
          ),
          _buildStatItem(
            context,
            profileCounters.wishlistItemCount.toString(),
            'saved'.tr(context),
            AppSvgs.profile_fav,
          ),
          _buildStatItem(
            context,
            clubPointProvider.clubPointsState == LoadingState.loaded
                ? clubPointProvider.totalPoints
                : '0',
            'points'.tr(context),
            AppSvgs.profile_coin,
          ),
          _buildStatItem(
            context,
            '${profileCounters.orderCount}',
            'reviews'.tr(context),
            AppSvgs.profile_star,
          ),
        ],
      ),
    );
  }

  // Build quick access section
  Widget _buildQuickAccessSection(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
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
          const SizedBox(width: 10),
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
    );
  }

  // Guest user header with more attractive design
  Widget _buildGuestUserHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.9),
            AppTheme.primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo with animated container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const CustomImage(
              assetPath: AppImages.appLogo,
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 16),

          // Welcome text
          Text(
            'welcome_to_elsherif'.tr(context),
            style: context.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            'sign_in_to_explore'.tr(context),
            textAlign: TextAlign.center,
            style: context.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),

          // Sign in button in header
          ElevatedButton(
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'sign_in'.tr(context),
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logged in user header - extracted from original code
  Widget _buildLoggedInUserHeader(BuildContext context, ProfileProvider profileProvider) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: profileProvider.profileImageUrl != null
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
          const SizedBox(height: 10),
          // User Info
          Text(
            AppStrings.userName ?? '',
            style: context.headlineSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.userEmail ?? '',
            style: context.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          // Edit Button
          CustomButton(
            onPressed: () {
              AppRoutes.navigateTo(
                context,
                AppRoutes.editProfileScreen,
              );
            },
            isOutlined: true,
            borderRadius: 25,
            child: Text(
              'edit_profile_1'.tr(context),
              style: context.titleSmall.copyWith(
                color: AppTheme.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Guest menu items with better styling
  Widget _buildGuestMenuItems(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGuestMenuItem(
            context,
            AppSvgs.profile_language,
            'language_region'.tr(context),
            'personalize_experience'.tr(context),
                () {
              LanguageDialog.show(context);
            },
          ),
          const Divider(height: 1, indent: 70),
          _buildGuestMenuItem(
            context,
            AppSvgs.profile_help,
            'help_support'.tr(context),
            'get_assistance'.tr(context),
                () async {
              final Uri url = Uri.parse('https://melaminefront.dokkan.design/pages/contact-us');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('could_not_launch_website'.tr(context)))
                  );
                }
              }
            },
          ),
          const Divider(height: 1, indent: 70),
          _buildGuestMenuItem(
            context,
            AppSvgs.profile_about_us,
            'about_us'.tr(context),
            'learn_about_elsherif'.tr(context),
                () async {
              final Uri url = Uri.parse('https://melaminefront.dokkan.design/pages/about-us');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('could_not_launch_website'.tr(context)))
                  );
                }
              }
            },
          ),
          const Divider(height: 1, indent: 70),
          _buildGuestMenuItem(
            context,
            AppSvgs.profile_privacy,
            'our_website'.tr(context),
            'browse_products'.tr(context),
                () async {
              final Uri url = Uri.parse('https://melaminefront.dokkan.design/');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('could_not_launch_website'.tr(context)))
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Enhanced menu item for guest users
  Widget _buildGuestMenuItem(
      BuildContext context,
      String icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomImage(
                    assetPath: icon,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: Directionality.of(context) == TextDirection.rtl ? 3.14159 : 0,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menu items for logged in users - extracted from original code
  Widget _buildLoggedInMenuItems(BuildContext context) {
    return Container(
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
          AppStrings.token == null
              ? const SizedBox.shrink()
              : ProfileMenuItem(
            icon: AppSvgs.profile_wellat,
            title: 'my_wallet'.tr(context),
            onTap: () {
              AppRoutes.navigateTo(
                context,
                AppRoutes.walletScreen,
              );
            },
          ),
          ProfileMenuItem(
            icon: AppSvgs.profile_privacy,
            title: 'our_website'.tr(context),
            onTap: () async {
              final Uri url = Uri.parse('https://melaminefront.dokkan.design/');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('could_not_launch_website'.tr(context)))
                  );
                }
              }
            },
          ),
          ProfileMenuItem(
            icon: AppSvgs.profile_language,
            title: 'language_region'.tr(context),
            onTap: () {
              LanguageDialog.show(context);
            },
          ),
          ProfileMenuItem(
            icon: AppSvgs.profile_help,
            title: 'help_support'.tr(context),
            onTap: () async {
              final Uri url = Uri.parse('https://melaminefront.dokkan.design/pages/contact-us');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('could_not_launch_website'.tr(context)))
                  );
                }
              }
            },
          ),
          ProfileMenuItem(
            icon: AppSvgs.profile_about_us,
            title: 'about_us'.tr(context),
            onTap: () async {
              final Uri url = Uri.parse('https://melaminefront.dokkan.design/pages/about-us');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('could_not_launch_website'.tr(context)))
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Sign in button with enhanced styling
  Widget _buildSignInButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Benefits message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'account_benefits'.tr(context),
                    style: context.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sign in button
          CustomButton(
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.login);
            },
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            borderRadius: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'sign_in'.tr(context),
                  style: context.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Create account text button
          TextButton(
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.signUp);
            },
            child: Text(
              'create_account'.tr(context),
              style: context.titleSmall.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sign out button - extracted from original code
  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
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
            const Icon(
                Icons.logout,
                color: AppTheme.primaryColor
            ),
            const SizedBox(width: 6),
            Text(
              'sign_out'.tr(context),
              style: context.titleMedium.copyWith(color: AppTheme.primaryColor),
            ),
          ],
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
            Expanded(child: Text(label, style: context.titleMedium.copyWith(fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final navigatorContext = context;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'logout'.tr(navigatorContext),
      text: 'confirm_logout'.tr(navigatorContext),
      confirmBtnText: 'logout'.tr(navigatorContext),
      cancelBtnText: 'cancel'.tr(navigatorContext),
      confirmBtnTextStyle: context.bodySmall.copyWith(color: AppTheme.white),
      cancelBtnTextStyle: context.bodyMedium.copyWith(color: AppTheme.primaryColor),
      confirmBtnColor: AppTheme.primaryColor,
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Close the dialog
        await navigatorContext.read<AuthProvider>().logout();
        AppStrings.userId = null;
        AppStrings.token = null;

        if (navigatorContext.mounted) {
          Navigator.of(navigatorContext).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        }
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    // Create items list for social media actions
    var socialMediaItems = [
      FloatingActionButton(
        heroTag: "youtube",
        backgroundColor: Colors.red,
        onPressed: _launchYouTube,
        child: const Icon(Icons.play_arrow),
      ),
      FloatingActionButton(
        heroTag: "phone",
        backgroundColor: Colors.green,
        onPressed: _makePhoneCall,
        child: const Icon(Icons.call),
      ),
      FloatingActionButton(
        heroTag: "whatsapp",
        backgroundColor: Colors.green.shade700,
        onPressed: _openWhatsApp,
        child: const Icon(Icons.chat),
      ),
      FloatingActionButton(
        heroTag: "facebook",
        backgroundColor: Colors.blue,
        onPressed: _openFacebook,
        child: const Icon(Icons.facebook),
      ),
    ];

    return CircleFloatingButton.floatingActionButton(
      items: socialMediaItems,
      color: AppTheme.primaryColor,
      icon: Icons.add,
      duration: const Duration(milliseconds: 500),
      curveAnim: Curves.easeOutBack,
      useOpacity: true,
    );
  }

  Future<void> _launchYouTube() async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=aQSHPRcZdrA');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('could_not_launch_website'.tr(context))),
        );
      }
    }
  }

  Future<void> _openFacebook() async {
    final Uri url = Uri.parse('https://www.facebook.com/alsherifmelamine/about/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('could_not_launch_website'.tr(context))),
        );
      }
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri url = Uri.parse('tel:01064440808');
    if (!await launchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('could_not_make_call'.tr(context))),
        );
      }
    }
  }

  Future<void> _openWhatsApp() async {
    const phoneNumber = '201064440808'; // Adding Egypt country code
    final url = Uri.parse('https://wa.me/$phoneNumber');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('could_not_open_whatsapp'.tr(context))),
        );
      }
    }
  }
}
