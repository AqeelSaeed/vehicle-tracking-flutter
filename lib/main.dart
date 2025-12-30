import 'package:android_vehicle_tracking/authentication/forgot_password_screen.dart';
import 'package:android_vehicle_tracking/authentication/login_screen.dart';
import 'package:android_vehicle_tracking/splash_screen.dart';
import 'package:android_vehicle_tracking/supbase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'authentication/signup_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: SupbaseOptions.supabaseUrl,
    anonKey: SupbaseOptions.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot_password';
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.login: (context) => const LoginScreen(),
  AppRoutes.signup: (context) => const SignUpScreen(),
  AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // apply the defined routes here
      routes: appRoutes,
      home: const SplashScreen(),
    );
  }
}
