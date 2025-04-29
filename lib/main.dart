import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/search/controller/search_provider.dart';
import 'package:uuid/uuid.dart';
import 'core/config/app_config.dart/app_config.dart';
import 'core/config/routes.dart/routes.dart';
import 'core/config/themes.dart/theme.dart';
import 'core/di/injection_container.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/providers/localization/app_localizations.dart';
import 'core/providers/localization/language_provider.dart';
import 'core/utils/local_storage/local_storage_keys.dart';
import 'core/utils/local_storage/secure_storage.dart';
import 'core/utils/local_storage/shared_pref.dart';
import 'core/api/api_provider.dart';
import 'features/presentation/address/controller/address_provider.dart';
import 'features/presentation/auth/controller/auth_provider.dart';
import 'features/presentation/cart/controller/cart_provider.dart';
import 'features/presentation/category/controller/provider.dart';
import 'features/presentation/coupon/controller/coupon_provider.dart';
import 'features/presentation/main layout/controller/layout_provider.dart';
import 'features/presentation/order/controller/order_provider.dart';
import 'features/presentation/checkout/controller/payment_provider.dart';
import 'features/presentation/product details/controller/product_provider.dart';
import 'features/presentation/profile/controller/profile_provider.dart';
import 'features/presentation/review/controller/reviews_provider.dart';
import 'features/presentation/slider/controller/provider.dart';
import 'features/presentation/wishlist/controller/wishlist_provider.dart';
import 'firebase_options.dart';

Future<void> getInitData() async {
  AppStrings.token = await SecureStorage().get<String>(
    LocalStorageKey.userToken,
  );
  AppStrings.userId = await SecureStorage().get<String>(LocalStorageKey.userId);
  AppStrings.userEmail = await SecureStorage().get<String>(
    LocalStorageKey.userEmail,
  );
  AppStrings.userName = await SecureStorage().get<String>(
    LocalStorageKey.userName,
  );
  AppStrings.tempUserId = await SecureStorage().get<String>(
    LocalStorageKey.tempUserId,
  );
}

Future<void> checkAndGenerateTempUserId() async {
  if (AppStrings.tempUserId == null) {
    AppStrings.tempUserId = const Uuid().v4();
    await SecureStorage().save(
      LocalStorageKey.tempUserId,
      AppStrings.tempUserId,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  await setupDependencies();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Get saved locale from storage
  Locale locale = await sl<LanguageProvider>().getLocale();
  await getInitData();

  // Initialize API provider with the saved language
  sl<ApiProvider>().setLanguage(locale.languageCode);

  Future<String> getStartupScreen() async {
    await checkAndGenerateTempUserId();
    // Always return splash screen as the initial route
    return AppRoutes.splash;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => sl<HomeProvider>()),
        ChangeNotifierProvider(create: (_) => sl<LayoutProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ProductDetailsProvider>()),
        ChangeNotifierProvider(create: (_) => sl<LanguageProvider>()..setLocale(locale)),
        ChangeNotifierProvider(create: (_) => sl<CategoryProvider>()),
        ChangeNotifierProvider(create: (_) => sl<SliderProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ReviewProvider>()),
        ChangeNotifierProvider(create: (_) => sl<WishlistProvider>()),
        ChangeNotifierProvider(create: (_) => sl<CartProvider>()),
        ChangeNotifierProvider(create: (_) => sl<AddressProvider>()),
        ChangeNotifierProvider(create: (_) => sl<CouponProvider>()),
        ChangeNotifierProvider(create: (_) => sl<PaymentProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => sl<OrderProvider>()),
        ChangeNotifierProvider(create: (_) => sl<SearchProvider>()),
      ],
      child: MyApp(route: await getStartupScreen()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: AppConfig().appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          locale: languageProvider.locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'SA'),
            Locale('ru', 'RU'),
            Locale('de', 'DE'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode &&
                  supportedLocale.countryCode == locale?.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: route,
        );
      },
    );
  }
}
