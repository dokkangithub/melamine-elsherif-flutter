import 'package:melamine_elsherif/core/utils/local_storage/secure_storage.dart';
import 'package:flutter/material.dart';
import '../../utils/local_storage/local_storage_keys.dart';
import 'language_model.dart';
import '../../di/injection_container.dart';
import '../../api/api_provider.dart';

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

  Future<void> changeLanguage(String languageCode, String countryCode) async {
    Locale tempLocale = Locale(languageCode, countryCode);
    await setLocale(tempLocale);

    // No need to call notifyListeners() here as it's already called in setLocale
  }

  // Helper method to determine if a language change will affect RTL/LTR layout
  bool isDirectionChange(String newLanguageCode) {
    bool currentIsRTL = _locale.languageCode == 'ar';
    bool newIsRTL = newLanguageCode == 'ar';
    return currentIsRTL != newIsRTL;
  }
}
