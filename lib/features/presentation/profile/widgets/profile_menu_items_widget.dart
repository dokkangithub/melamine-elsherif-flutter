import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/providers/localization/language_provider.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/local_storage/local_storage_keys.dart';
import 'package:melamine_elsherif/core/utils/local_storage/secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../address/screens/address_list_screen.dart';
import '../../auth/controller/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../home/controller/home_provider.dart';
import '../../category/controller/provider.dart';
import '../../slider/controller/provider.dart';

class ProfileMenuItemsWidget extends StatelessWidget {
  const ProfileMenuItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AppStrings.token != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          AppStrings.token == null
              ? SizedBox.shrink()
              : _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'addresses'.tr(context),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressListScreen(),
                    ),
                  );
                },
                trailing: const Icon(Icons.chevron_right),
              ),
          _buildMenuItem(
            icon: Icons.language,
            title: 'language'.tr(context),
            onTap: () {
              _showLanguageSelectionDialog(context);
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          _buildMenuItem(
            icon: Icons.star_border,
            title: 'rate_app'.tr(context),
            onTap: () {
              // Open app store/play store
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'get_help'.tr(context),
            onTap: () {
              // Navigate to help
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'terms_conditions'.tr(context),
            onTap: () {
              // Navigate to terms
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          _buildMenuItem(
            icon: Icons.public,
            title: 'our_website'.tr(context),
            onTap: () async {
              final Uri url = Uri.parse('https://homelyhubmarket.com');
              if (!await launchUrl(url)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('could_not_launch_website'.tr(context)),
                  ),
                );
              }
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          if (isLoggedIn)
            _buildMenuItem(
              icon: Icons.logout,
              title: 'logout'.tr(context),
              onTap: () {
                _showLogoutConfirmation(context);
              },
              trailing: const Icon(Icons.chevron_right),
              textColor: Colors.red,
              iconColor: Colors.red,
            )
          else
            _buildMenuItem(
              icon: Icons.login,
              title: 'login'.tr(context),
              onTap: () {
                AppRoutes.navigateTo(context, AppRoutes.login);
              },
              trailing: const Icon(Icons.chevron_right),
              textColor: AppTheme.primaryColor,
              iconColor: AppTheme.primaryColor,
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'select_language'.tr(context),
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  languageProvider.languages.map((language) {
                    bool isSelected =
                        languageProvider.locale.languageCode ==
                        language.languageCode;

                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? Colors.green : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        color:
                            isSelected ? Colors.green.withOpacity(0.1) : null,
                      ),
                      child: ListTile(
                        title: Text(
                          language.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        leading: _getCountryFlag(language.languageCode),
                        trailing:
                            isSelected
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                                : null,
                        onTap: () async {
                          if (!isSelected) {
                            await languageProvider.changeLanguage(
                              language.languageCode,
                              language.countryCode,
                            );

                            Navigator.pop(context);

                            if (context.mounted) {
                              // First reload data providers to fetch data with new language
                              final homeProvider = Provider.of<HomeProvider>(
                                context,
                                listen: false,
                              );
                              final categoryProvider =
                                  Provider.of<CategoryProvider>(
                                    context,
                                    listen: false,
                                  );
                              final sliderProvider =
                                  Provider.of<SliderProvider>(
                                    context,
                                    listen: false,
                                  );

                              // Reload all data
                              homeProvider.refreshHomeData();
                              categoryProvider.getCategories(needRefresh: true);
                              sliderProvider.getSliders(refresh: true);

                              // Then navigate to home
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.mainLayoutScreen,
                                (route) => false,
                              );
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'cancel'.tr(context),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
            title: Text('logout'.tr(navigatorContext)),
            content: Text('confirm_logout'.tr(navigatorContext)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('cancel'.tr(navigatorContext)),
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
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _getCountryFlag(String languageCode) {
    // Map language codes to their corresponding flag emojis
    Map<String, String> flags = {
      'en': '🇺🇸', // USA flag for English
      'ar': '🇪🇬', // Egypt flag for Arabic
      'ru': '🇷🇺', // Russia flag for Russian
      'de': '🇩🇪', // Germany flag for German
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(flags[languageCode] ?? '', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
