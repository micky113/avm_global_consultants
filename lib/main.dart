import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:avm_global_web/firebase_options.dart';
import 'package:avm_global_web/routes/app_route_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AVMGlobalApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class AVMGlobalApp extends StatelessWidget {
  const AVMGlobalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AVM Global Consultants | Overseas Recruitment & Careers Abroad',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      routerConfig: MyAppRouter.router,
    );
  }
}


