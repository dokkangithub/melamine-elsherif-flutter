import 'package:melamine_elsherif/core/utils/local_storage/secure_storage.dart';
import 'package:flutter/material.dart';
import '../../utils/local_storage/local_storage_keys.dart';
import 'language_model.dart';
import '../../di/injection_container.dart';
import '../../api/api_provider.dart';
import '../../../features/presentation/home/controller/home_provider.dart';
import '../../../features/presentation/category/controller/provider.dart';
import 'package:provider/provider.dart';

class LanguageProvider extends ChangeNotifier {
  // Changed from final to late to allow updating
  late Locale _locale;

  // Initialize with default locale
  LanguageProvider() {
    _locale = const Locale('en', 'US');
  }

  final List<LanguageModel> languages = [
    LanguageModel(
      code: 'en',
      name: 'English',
      languageCode: 'en',
      countryCode: 'US',
    ),
    LanguageModel(
      code: 'ar',
      name: 'العربية',
      languageCode: 'ar',
      countryCode: 'Eg',
    ),
    // LanguageModel(
    //   code: 'ru',
    //   name: 'Русский',
    //   languageCode: 'ru',
    //   countryCode: 'RU',
    // ),
    // LanguageModel(
    //   code: 'de',
    //   name: 'Deutsch',
    //   languageCode: 'de',
    //   countryCode: 'DE',
    // ),
  ];

  Locale get locale => _locale;

  Future<Locale> getLocale() async {
    String? languageCode = await SecureStorage().get(
      LocalStorageKey.languageCode,
    );
    String? countryCode = await SecureStorage().get(
      LocalStorageKey.countryCode,
    );

    // Provide default values if null is returned
    languageCode ??= 'en'; // Default to English
    countryCode ??= 'US'; // Default to US

    return Locale(languageCode, countryCode);
  }

  Future<bool> setLocale(Locale tempLocale) async {
    await SecureStorage().save(
      LocalStorageKey.languageCode,
      tempLocale.languageCode,
    );
    await SecureStorage().save(
      LocalStorageKey.countryCode,
      tempLocale.countryCode,
    );

    // Update ApiProvider with new language
    sl<ApiProvider>().setLanguage(tempLocale.languageCode);

    // Update the _locale field with the new locale
    _locale = tempLocale;
    notifyListeners(); // Notify UI to rebuild with the new locale
    return true;
  }

  // This method changes the language and refreshes all data
  Future<void> changeLanguage(String languageCode, String countryCode, {BuildContext? context}) async {
    debugPrint('Changing language to: $languageCode');
    
    // Create the new locale
    Locale tempLocale = Locale(languageCode, countryCode);
    
    // Save to storage first
    await SecureStorage().save(
      LocalStorageKey.languageCode,
      languageCode,
    );
    await SecureStorage().save(
      LocalStorageKey.countryCode,
      countryCode,
    );

    // Update ApiProvider with new language
    sl<ApiProvider>().setLanguage(languageCode);
    
    // Update the locale
    _locale = tempLocale;
    
    // Force UI rebuild
    notifyListeners();
    
    // Trigger data refresh directly (without relying on context)
    try {
      // Get singleton instances from service locator and refresh them
      final homeProvider = sl<HomeProvider>();
      homeProvider.refreshAfterLanguageChange(); // Use the new method for complete refresh
      
      final categoryProvider = sl<CategoryProvider>();
      categoryProvider.refreshAfterLanguageChange(); // Use the new method for complete refresh
    } catch (e) {
      debugPrint('Error refreshing data providers: $e');
    }
  }

  // Helper method to determine if a language change will affect RTL/LTR layout
  bool isDirectionChange(String newLanguageCode) {
    bool currentIsRTL = _locale.languageCode == 'ar';
    bool newIsRTL = newLanguageCode == 'ar';
    return currentIsRTL != newIsRTL;
  }
}
