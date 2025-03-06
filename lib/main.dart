import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api.dart';
import 'package:campus_flutter/base/services/push_service.dart';
import 'package:campus_flutter/navigation.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:campus_flutter/theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stash/stash_api.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import 'base/helpers/delayed_loading_indicator.dart';
import 'firebase_options.dart';
import 'login2Component/login_view.dart';
import 'package:stash_hive/stash_hive.dart';

main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  getIt.registerSingleton<ConnectivityResult>(await Connectivity().checkConnectivity());
  getIt.registerSingleton<CampusApi>(CampusApi(Dio()));
  final pushService = PushService();
  pushService.initialize();
  getIt.registerSingleton<PushService>(pushService);
  WidgetsFlutterBinding.ensureInitialized();
  final store = await newHiveDefaultCacheStore(path: "${(await getTemporaryDirectory()).path}\\cache");
  final cache = await store.cache<Map>(name: "cache", maxEntries: 60);
  //cache.on<CacheEntryCreatedEvent<Map<String, dynamic>>>().listen(
  //        (event) => print('Key "${event.entry.key}" added to the cache'));
  getIt.registerSingleton<Cache<Map>>(cache);

  //debugPaintSizeEnabled=true;
  runApp(const ProviderScope(child: CampusApp()));
}

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "AppUS",
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: lightTheme(context),
        darkTheme: darkTheme(context),
        home: const AuthenticationRouter());
  }
}

class AuthenticationRouter extends StatefulWidget {
  const AuthenticationRouter({super.key});

  @override
  State<StatefulWidget> createState() => _AuthenticationRouterState();
}

class _AuthenticationRouterState extends State<AuthenticationRouter> {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = Localizations.localeOf(context).languageCode;
    
    return ValueListenableBuilder(
        valueListenable: getIt<CampusApi>().isAuthenticated,
        builder: (context, isAuthenticated, child) {
          if (isAuthenticated != null) {
            FlutterNativeSplash.remove();
            if (isAuthenticated) {
              return const Navigation();
            } else {
              return const LoginView();
            }
          } else {
            return const DelayedLoadingIndicator(name: "Login");
          }
        });
  }
}
