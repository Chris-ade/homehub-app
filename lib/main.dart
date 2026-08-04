import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/api_client.dart';
import 'providers/app_theme_provider.dart';
import 'providers/property_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Single shared API client. UserProvider registers itself as the auth
  // token source on it, so any provider making authed calls (e.g. bookmarks,
  // chat) gets bearer tokens + automatic 401 refresh for free.
  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppThemeProvider()),
        // UserProvider before PropertyProvider so authProvider is registered first.
        ChangeNotifierProvider(create: (_) => UserProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => PropertyProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const HomeHubApp(),
    ),
  );
}

class HomeHubApp extends StatelessWidget {
  const HomeHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppThemeProvider>();

    return MaterialApp(
      title: 'HomeHub',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
