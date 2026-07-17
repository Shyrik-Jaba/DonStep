import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donstep/config/theme.dart';
import 'package:donstep/providers/auth_provider.dart';
import 'package:donstep/providers/workout_provider.dart';
import 'package:donstep/screens/home_screen.dart';
import 'package:donstep/screens/auth/login_screen.dart';
import 'package:donstep/screens/auth/register_screen.dart';

class DonStepApp extends StatelessWidget {
  const DonStepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'DonStep',
        theme: DonStepTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (_, auth, __) {
            if (auth.loading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!auth.isLoggedIn) {
              return const LoginScreen();
            }
            return const HomeScreen();
          },
        ),
        routes: {
          '/register': (_) => const RegisterScreen(),
        },
      ),
    );
  }
}
