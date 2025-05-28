import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'onboarding.dart';
import 'HomeScreen.dart';
import 'siglogscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'settings_page.dart';
import 'package:provider/provider.dart';
import 'theme_controller.dart';
import 'tips.dart';
import 'developers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.currentTheme,
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/home': (context) => HomeScreen(),
        '/siglogpage': (context) => const LoginScreen(),
        '/loginpage': (context) => const LoginPage(),
        '/signuppage': (context) => const SignupPage(),
        '/settings': (context) => const SettingsPage(),
        '/tips': (context) => const TipsScreen(),
        '/developers': (context) => const DevelopersPage(),
      },
    );
  }
}
