import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/locale/locale_cubit.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/di/service_locator.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  AppLogger.info('Initializing Firebase...', 'Main');
  await Firebase.initializeApp();
  AppLogger.success('Firebase initialized successfully', 'Main');

  // Initialize service locator (GetIt)
  AppLogger.info('Initializing service locator...', 'Main');
  await setupServiceLocator();

  // Wait for all async dependencies (AuthService, AuthRepository, AuthBloc) to be ready
  AppLogger.info('Waiting for async dependencies...', 'Main');
  await sl.allReady();
  AppLogger.success('Service locator initialized successfully', 'Main');

  runApp(BlocProvider(create: (_) => LocaleCubit(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp.router(
          title: 'ErgoLife',
          debugShowCheckedModeBanner: false,
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: ThemeMode.light,
          locale: locale,
          routerConfig: AppRouter.router,
          localizationsDelegates: const [
            // App Localizations (generated)
            AppLocalizations.delegate,

            // Global Material Localizations
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('vi'), // Vietnamese
          ],
        );
      },
    );
  }
}
