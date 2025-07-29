import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melamine_elsherif/core/services/widget_service.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/core/utils/helpers/ui_helper.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/search/controller/search_provider.dart';
import 'package:melamine_elsherif/features/presentation/set%20products/controller/set_product_provider.dart';
import 'package:uuid/uuid.dart';
import 'core/config/app_config.dart/app_config.dart';
import 'core/config/routes.dart/routes.dart';
import 'core/config/themes.dart/theme.dart';
import 'core/di/injection_container.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/providers/localization/app_localizations.dart';
import 'core/providers/localization/language_provider.dart';
import 'core/services/notification/notification_manager.dart';
import 'core/services/notification/notification_router.dart';
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
import 'features/presentation/wallet/controller/wallet_provider.dart';
import 'features/presentation/club_point/controller/club_point_provider.dart';
import 'firebase_options.dart';

// Global navigation key and notification manager
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late NotificationManager notificationManager;

Future<void> getInitData() async {
  debugPrint("Getting initial data...");
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
  debugPrint("Initial data loaded");
}

Future<void> checkAndGenerateTempUserId() async {
  if (AppStrings.tempUserId == null) {
    AppStrings.tempUserId = const Uuid().v4();
    await SecureStorage().save(
      LocalStorageKey.tempUserId,
      AppStrings.tempUserId,
    );
    debugPrint("Generated new temp user ID: ${AppStrings.tempUserId}");
  } else {
    debugPrint("Using existing temp user ID: ${AppStrings.tempUserId}");
  }
}

Future<void> getAndPrintFcmToken() async {
  try {
    debugPrint("Getting FCM token...");
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission on iOS and Android 13+
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      if (token != null) {
        debugPrint('✅ FCM Token: $token');
      } else {
        debugPrint('⚠️ Failed to get FCM token');
      }
    } else {
      debugPrint('❌ Notifications permission not granted');
    }
  } catch (e) {
    debugPrint('❗ Error getting FCM token: $e');
  }
}

Future<void> initializeNotifications() async {
  try {
    debugPrint("Initializing notifications...");

    final notificationRouter = NotificationRouter(
      navigatorKey: navigatorKey,
    );

    notificationManager = NotificationManager(router: notificationRouter);
    await notificationManager.initialize();

    // Subscribe to topics
    await FirebaseMessaging.instance.subscribeToTopic("all_devices");

    debugPrint("Notifications initialized successfully");
  } catch (e) {
    debugPrint("Error initializing notifications: $e");
  }
}

Future<void> main() async {
  try {
    debugPrint("=== APP STARTUP ===");
    WidgetsFlutterBinding.ensureInitialized();

    // Set system UI overlay style
    UIHelper.setTransparentStatusBar();

    // Initialize core services
    await SharedPrefs.init();
    await setupDependencies();

    // Initialize Firebase
    debugPrint("Initializing Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Get FCM token early
    await getAndPrintFcmToken();

    // Initialize notifications (this must be done after Firebase init)
    await initializeNotifications();

    // Initialize widget service
    await WidgetService().initialize();
    await WidgetService().registerInteractivity();

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

    debugPrint("Starting app...");
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
          ChangeNotifierProvider(create: (_) => sl<WalletProvider>()),
          ChangeNotifierProvider(create: (_) => sl<ClubPointProvider>()),
          ChangeNotifierProvider(create: (_) => sl<SetProductsProvider>()),
        ],
        child: MyApp(route: await getStartupScreen()),
      ),
    );
  } catch (e) {
    debugPrint("Error during app startup: $e");
    // You might want to show an error screen here
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to start app'),
              const SizedBox(height: 8),
              Text('Error: $e'),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        debugPrint('Building MyApp with locale: ${languageProvider.locale.languageCode}');

        return UIHelper.wrapWithStatusBarConfig(
          MaterialApp(
            title: AppConfig().appName,
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(languageProvider.locale.languageCode),
            themeMode: ThemeMode.light,
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'EG'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              debugPrint('Resolving locale: ${locale?.languageCode}');

              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  debugPrint('Resolved to supported locale: ${supportedLocale.languageCode}');
                  return supportedLocale;
                }
              }
              debugPrint('No matching locale, using default: ${supportedLocales.first.languageCode}');
              return supportedLocales.first;
            },
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: route,
          ),
        );
      },
    );
  }
}