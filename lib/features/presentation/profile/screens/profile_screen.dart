import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/language_switcher.dart';
import 'package:melamine_elsherif/features/presentation/wallet/controller/wallet_provider.dart';
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

    // For non-logged-in users, create a completely different layout
    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header section
                _shouldAnimate
                    ? FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: _buildGuestUserHeader(context),
                      )
                    : _buildGuestUserHeader(context),

                // Menu items
                const SizedBox(height: 30),
                _shouldAnimate
                    ? FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 500),
                        child: _buildGuestMenuItems(context),
                      )
                    : _buildGuestMenuItems(context),

                // Social media icons
                const SizedBox(height: 60),
                _shouldAnimate
                    ? FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 500),
                        child: _buildSocialMediaRow(context),
                      )
                    : _buildSocialMediaRow(context),

                // Footer text
                const SizedBox(height: 40),
                _shouldAnimate
                    ? FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        duration: const Duration(milliseconds: 400),
                        child: _buildFooterText(context),
                      )
                    : _buildFooterText(context),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      );
    }

    // Layout for logged-in users to match the design
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info
              _shouldAnimate
                  ? FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: _buildLoggedInUserHeader(context, profileProvider),
                    )
                  : _buildLoggedInUserHeader(context, profileProvider),

              // User dashboard (orders, wallet, address, saved items)
              _shouldAnimate
                  ? FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 500),
                      child: _buildUserDashboard(context),
                    )
                  : _buildUserDashboard(context),

              // Section divider
              const Divider(height: 16, thickness: 8, color: Color(0xFFF5F5F5)),

              // Account tools section
              _shouldAnimate
                  ? FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 500),
                      child: _buildAccountToolsSection(context),
                    )
                  : _buildAccountToolsSection(context),

              // Section divider
              const Divider(height: 16, thickness: 8, color: Color(0xFFF5F5F5)),

              // Contact & Social section
              _shouldAnimate
                  ? FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 500),
                      child: _buildContactSocialSection(context),
                    )
                  : _buildContactSocialSection(context),

              // Logout button
              _shouldAnimate
                  ? FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 500),
                      child: _buildSignOutButton(context),
                    )
                  : _buildSignOutButton(context),
            ],
          ),
        ),
      ),
    );
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

  // Guest user header that exactly matches the image
  Widget _buildGuestUserHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Language switcher (EN | AR) on top right
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LanguageSwitcher(),
            SizedBox(width: 20),
          ],
        ),

        // Welcome text section
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                'welcome_to_melamen_el_sherief'.tr(context),
                textAlign: TextAlign.center,
                style: context.displayLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'discover_elegance_and_durability_designed_for_modern_living'.tr(context),
                textAlign: TextAlign.center,
                style: context.headlineSmall.copyWith(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        // Sign In button
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: CustomButton(
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.login);
            },
            fullWidth: true,
            child: Text(
              textAlign: TextAlign.center,
              'sign_in'.tr(context),
              style: context.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Create Account text button
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            AppRoutes.navigateTo(context, AppRoutes.signUp);
          },
          child: Text(
            'create_account'.tr(context),
            style: context.headlineSmall.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Access your orders text
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'access_your_orders_wishlist_and_personalized_offers'.tr(context),
            textAlign: TextAlign.center,
            style: context.bodyLarge.copyWith(
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  // Logged in user header that matches the image
  Widget _buildLoggedInUserHeader(BuildContext context, ProfileProvider profileProvider) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Background cover image
          Positioned.fill(
            child: SvgPicture.asset(
              AppSvgs.profile_cover,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Backdrop filter for visual effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Container(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),

          // Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 40),

                // User image and info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
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

                    const SizedBox(width: 16),

                    // User info with email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.userName ?? '',
                            style: context.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.userEmail ?? '',
                            style: context.titleMedium.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit button
                    InkWell(
                      onTap: () {
                        AppRoutes.navigateTo(
                          context,
                          AppRoutes.editProfileScreen,
                        );
                      },
                      child: const CustomImage(
                        assetPath: AppSvgs.edit_profile,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Guest menu items to exactly match the image
  Widget _buildGuestMenuItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Help & Support
          _buildMenuItemExact(
            context: context,
            title: 'help_support'.tr(context),
            icon: Icons.chevron_right,
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

          // About Us
          _buildMenuItemExact(
            context: context,
            title: 'about_us'.tr(context),
            icon: Icons.chevron_right,
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

          // Contact Us
          _buildMenuItemExact(
            context: context,
            title: 'contact_us'.tr(context),
            icon: Icons.chevron_right,
            onTap: () async {
              final Uri url = Uri.parse('tel:01064440808');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('could_not_make_call'.tr(context))),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Menu item widget that exactly matches the design in the image
  Widget _buildMenuItemExact({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: context.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  icon,
                  color: Colors.black87,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }


  // Sign out button - extracted from original code
  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: CustomButton(
          onPressed: () {
            _showLogoutConfirmation(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'logout'.tr(context).toUpperCase(),
                textAlign: TextAlign.center,
                style: context.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
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

  // Social media row that matches the image
  Widget _buildSocialMediaRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 28,
      children: [
        _buildSocialIcon(
          icon: AppSvgs.whatsapp,  // Using chat icon for WhatsApp since Icons.whatsapp doesn't exist
          onTap: _openWhatsApp,
        ),
        _buildSocialIcon(
          icon: AppSvgs.call,
          onTap: _makePhoneCall,
        ),
        _buildSocialIcon(
          icon: AppSvgs.facebook,
          onTap: _openFacebook,
        ),
        _buildSocialIcon(
          icon: AppSvgs.youtube,
          onTap: _launchYouTube,
        ),
      ],
    );
  }

  // Individual social icon
  Widget _buildSocialIcon({
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: CustomImage(
       assetPath:  icon,
      ),
    );
  }

  // Footer text that matches the design
  Widget _buildFooterText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        'elegance_efficiency_and_performance_designed_for_you'.tr(context),
        textAlign: TextAlign.center,
        style: context.titleMedium.copyWith(
          color: Colors.black54,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }

  // Build user dashboard items (orders, wallet, address, saved items)
  Widget _buildUserDashboard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // My Orders
          _buildDashboardItem(
            context: context,
            icon: AppSvgs.profile_bag,
            title: 'my_orders'.tr(context),
            subtitle: '${Provider.of<ProfileProvider>(context,listen: false).profileCounters!.orderCount}  ${'active_orders'.tr(context)}',
            onTap: () {
              AppRoutes.navigateTo(
                context,
                AppRoutes.allOrdersListScreen,
              );
            },
          ),

          const SizedBox(height: 24),

          // My Wallet
          _buildDashboardItem(
            context: context,
            icon: AppSvgs.profile_wellat,
            title: 'my_wallet'.tr(context),
            subtitle: '',
            onTap: () {
              AppRoutes.navigateTo(
                context,
                AppRoutes.walletScreen,
              );
            },
          ),

          const SizedBox(height: 24),

          // Shipping Address
          _buildDashboardItem(
            context: context,
            icon: AppSvgs.profile_location,
            title: 'shipping_address'.tr(context),
            subtitle: ''.tr(context),
            onTap: () {
              AppRoutes.navigateTo(
                context,
                AppRoutes.addressListScreen,
              );
            },
          ),

          const SizedBox(height: 24),

          // Saved Items
          _buildDashboardItem(
            context: context,
            icon: AppSvgs.profile_fav,
            title: 'saved_items'.tr(context),
            subtitle: '${Provider.of<ProfileProvider>(context,listen: false).profileCounters!.wishlistItemCount}  ${'items'.tr(context)}',
            onTap: () {
              AppRoutes.navigateTo(
                context,
                AppRoutes.wishListScreen,
              );
            },
          ),
        ],
      ),
    );
  }

  // Dashboard item widget
  Widget _buildDashboardItem({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          // Icon
          SvgPicture.asset(
            icon,
            width: 26,
            height: 26,
            color: const Color(0xFF223843),
          ),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.bodyMedium.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Account tools section header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        title,
        style: context.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Account tools section
  Widget _buildAccountToolsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(context, 'account_tools'.tr(context)),

        // Divider
        const Divider(height: 1),

        // Change Language
        _buildToolItem(
          context: context,
          icon: AppSvgs.profile_language,
          title: 'change_language'.tr(context),
          onTap: () {
            LanguageDialog.show(context);
          },
        ),

        // Help & Support
        _buildToolItem(
          context: context,
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

        // About Us
        _buildToolItem(
          context: context,
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

        // Visit Website
        _buildToolItem(
          context: context,
          icon: AppSvgs.profile_privacy,
          title: 'visit_website'.tr(context),
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
      ],
    );
  }

  // Tool item widget
  Widget _buildToolItem({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon
                SvgPicture.asset(
                  icon,
                  width: 22,
                  height: 22,
                  color: const Color(0xFF223843),
                ),

                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Chevron
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black45,
                  size: 22,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  // Contact & Social section
  Widget _buildContactSocialSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(context, 'contact_social'.tr(context)),

        // Social buttons in a grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // WhatsApp
              Expanded(
                child: _buildContactButton(
                  context: context,
                  icon: AppSvgs.whatsapp,
                  title: 'whatsapp'.tr(context),
                  onTap: _openWhatsApp,
                ),
              ),

              const SizedBox(width: 16),

              // Call Us
              Expanded(
                child: _buildContactButton(
                  context: context,
                  icon: AppSvgs.call,
                  title: 'call_us'.tr(context),
                  onTap: _makePhoneCall,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Facebook
              Expanded(
                child: _buildContactButton(
                  context: context,
                  icon: AppSvgs.facebook,
                  title: 'facebook'.tr(context),
                  onTap: _openFacebook,
                ),
              ),

              const SizedBox(width: 16),

              // YouTube
              Expanded(
                child: _buildContactButton(
                  context: context,
                  icon: AppSvgs.youtube,
                  title: 'youtube'.tr(context),
                  onTap: _launchYouTube,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Contact button widget
  Widget _buildContactButton({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              color: const Color(0xFF223843),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: context.titleSmall.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
