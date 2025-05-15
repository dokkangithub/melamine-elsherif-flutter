import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../config/themes.dart/theme.dart';
import '../../providers/localization/app_localizations.dart';
import '../../providers/localization/language_provider.dart';
import '../../utils/extension/translate_extension.dart';

class LanguageDialog extends StatefulWidget {
  const LanguageDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LanguageDialog();
      },
    );
  }

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: 10,
                  intensity: 0.4,
                  surfaceIntensity: 0.3,
                  shape: NeumorphicShape.concave,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(24)),
                  lightSource: LightSource.topLeft,
                  color: Theme.of(context).cardColor,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with animation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'select_language'.tr(context),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // English option with USA flag
                      _buildLanguageOption(
                        context,
                        languageProvider,
                        languageCode: 'en',
                        countryCode: 'US',
                        languageName: 'English',
                        flagAsset: 'assets/flags/usa_flag.png',
                      ),

                      const SizedBox(height: 16),

                      // Arabic option with Egypt flag
                      _buildLanguageOption(
                        context,
                        languageProvider,
                        languageCode: 'ar',
                        countryCode: 'Eg',
                        languageName: 'العربية',
                        flagAsset: 'assets/flags/egypt_flag.png',
                      ),

                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          NeumorphicButton(
                            style: NeumorphicStyle(
                              depth: -3,
                              intensity: 0.7,
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                              color: Colors.grey.shade200,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text(
                              'cancel'.tr(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context,
      LanguageProvider provider, {
        required String languageCode,
        required String countryCode,
        required String languageName,
        required String flagAsset,
      }) {
    final isSelected = provider.locale.languageCode == languageCode;

    return GestureDetector(
      onTap: () async {
        // Visual confirmation of selection before dialog closes
        final isDirectionChange = provider.isDirectionChange(languageCode);

        // Start closing animation
        _controller.reverse().then((_) {
          Navigator.of(context).pop();
        });

        // Wait before changing language to allow animation to complete
        await Future.delayed(const Duration(milliseconds: 300));

        // Change the language
        await provider.changeLanguage(languageCode, countryCode);
      },
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: isSelected ? 4 : -3,
          intensity: 0.7,
          surfaceIntensity: 0.4,
          shape: isSelected ? NeumorphicShape.convex : NeumorphicShape.concave,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          lightSource: LightSource.topLeft,
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Theme.of(context).cardColor,
          border: isSelected
              ? NeumorphicBorder(color: AppTheme.primaryColor.withOpacity(0.3), width: 1)
              : const NeumorphicBorder.none(),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Country flag with 3D effect
              CustomImage(assetPath: flagAsset,height: 30,width: 30),
              const SizedBox(width: 16),

              // Language name
              Expanded(
                child: Text(
                  languageName,
                  style: context.titleLarge!.copyWith(fontWeight: isSelected?FontWeight.w800:FontWeight.normal),
                ),
              ),

              // Selection indicator
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24,
                )
            ],
          ),
        ),
      ),
    );
  }
}