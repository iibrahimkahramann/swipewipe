import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipewipe/config/functions/app_trancking.dart';
import 'package:swipewipe/config/router/router.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', ''),
        Locale('tr', ''),
        Locale('fr', ''),
        Locale('it', ''),
        Locale('pt', ''),
        Locale('es', ''),
        Locale('de', ''),
        Locale('ru', ''),
        Locale('ko', ''),
        Locale('ja', ''),
      ],
      path: 'assets/lang',
      fallbackLocale: const Locale('en', ''),
      useOnlyLangCode: true,
      child: ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final bool _appIsReady = true;

  @override
  void initState() {
    super.initState();
    Platform.isIOS ? appTracking() : nottrack();
  }

  @override
  Widget build(BuildContext context) {
    if (!_appIsReady) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Cartoon AI',
      debugShowCheckedModeBanner: false,
      theme: CustomTheme.themeData(context),
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
