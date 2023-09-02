import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api.dart';
import 'package:campus_flutter/navigation.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:campus_flutter/routes.dart';
import 'package:campus_flutter/theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'base/helpers/delayed_loading_indicator.dart';
import 'login2Component/login_view.dart';

main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  getIt.registerSingleton<ConnectivityResult>(await Connectivity().checkConnectivity());
  getIt.registerSingleton<CampusApi>(CampusApi(Dio()));

/*  if (kIsWeb) {
    getIt.registerSingleton<MainApi>(MainApi.webCache());
  } else {
    final directory = await getTemporaryDirectory();
    HiveCacheStore(directory.path).clean();
    getIt.registerSingleton<MainApi>(MainApi.mobileCache(await getTemporaryDirectory()));
  }*/
  //debugPaintSizeEnabled=true;
  runApp(const ProviderScope(child: CampusApp()));
}

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "TUM Campus App",
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
    return StreamBuilder(
        stream: getIt<CampusApi>().isAuthenticated,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            FlutterNativeSplash.remove();
            if (snapshot.data!) {
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
