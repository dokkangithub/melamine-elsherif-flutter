import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/text_style_extension.dart';
import '../../../../core/providers/localization/language_provider.dart';
import '../../auth/controller/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../club_point/controller/club_point_provider.dart';
import '../controller/profile_provider.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/language_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isDialOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDial() {
    setState(() {
      _isDialOpen = !_isDialOpen;
      if (_isDialOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final clubPointProvider = Provider.of<ClubPointProvider>(context);
    final counters = profileProvider.profileCounters;
    final isLoggedIn = AppStrings.token != null;
    final isLoadingCounters =
        profileProvider.countersState == LoadingState.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _buildSpeedDial(),
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                                : isLoggedIn
                                  ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                  :  const CustomImage(
                                    assetPath: AppImages.appLogo,
                                    fit: BoxFit.cover,
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
                    // Edit Button - only show for logged in users
                    if (isLoggedIn)
                      CustomButton(
                        onPressed: () {
                          AppRoutes.navigateTo(
                            context,
                            AppRoutes.editProfileScreen,
                          );
                        },
                        isOutlined: true,
                        child: Text(
                          'edit'.tr(context),
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
                        clubPointProvider.clubPointsState == LoadingState.loaded
                            ? clubPointProvider.totalPoints
                            : '0',
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
            if (isLoggedIn && !isLoadingCounters && counters != null)
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
                    AppStrings.token == null
                        ? const SizedBox.shrink()
                        : ProfileMenuItem(
                      icon: AppSvgs.profile_coin,
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
                        // Show language selection
                        LanguageSelector.show(context);
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
              ),

              const SizedBox(height: 20),

              // Auth Button (Sign Out or Sign In)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: CustomButton(
                  onPressed: () {
                    if (isLoggedIn) {
                      _showLogoutConfirmation(context);
                    } else {
                      // Navigate to login screen
                      AppRoutes.navigateTo(context, AppRoutes.login);
                    }
                  },
                  isOutlined: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLoggedIn ? Icons.logout : Icons.login,
                        color: AppTheme.primaryColor
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isLoggedIn ? 'sign_out'.tr(context) : 'sign_in'.tr(context),
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
            Expanded(child: Text(label, style: context.titleMedium.copyWith(fontWeight: FontWeight.w700))),
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
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
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

  Widget _buildSpeedDial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // YouTube
        if (_isDialOpen) _buildSpeedDialChild(
          icon: Icons.play_arrow,
          backgroundColor: Colors.red,
          onTap: () {
            _launchYouTube();
            _toggleDial();
          },
          position: 4,
        ),
        
        // Phone Call
        if (_isDialOpen) _buildSpeedDialChild(
          icon: Icons.call,
          backgroundColor: Colors.green,
          onTap: () {
            _makePhoneCall();
            _toggleDial();
          },
          position: 3,
        ),
        
        // WhatsApp
        if (_isDialOpen) _buildSpeedDialChild(
          icon: Icons.chat,
          backgroundColor: Colors.green.shade700,
          onTap: () {
            _openWhatsApp();
            _toggleDial();
          },
          position: 2,
        ),
        
        // Facebook
        if (_isDialOpen) _buildSpeedDialChild(
          icon: Icons.facebook,
          backgroundColor: Colors.blue,
          onTap: () {
            _openFacebook();
            _toggleDial();
          },
          position: 1,
        ),
        
        // Main FAB
        GestureDetector(
          onTap: _toggleDial,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedRotation(
              turns: _isDialOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedDialChild({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
    required int position,
  }) {
    final positionAnimation = Tween<double>(
      begin: 0,
      end: position * 60.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          bottom: positionAnimation.value,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
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
    final phoneNumber = '201064440808'; // Adding Egypt country code
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
