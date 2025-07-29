import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';
import 'package:traiteur_management/providers/locale_provider.dart';
import 'package:traiteur_management/screens/admin/enhanced_admin_dashboard.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/employee/employee_dashboard.dart';

class TraiteurApp extends StatelessWidget {
  const TraiteurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Traiteur Management',
          theme: AppTheme.lightTheme,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,

          // Internationalization setup
          locale: localeProvider.locale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Locale resolution callback
          localeResolutionCallback: (locale, supportedLocales) {
            // If the device locale is supported, use it
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            // Fallback to the first supported locale (English)
            return supportedLocales.first;
          },

          // RTL support for Arabic
          builder: (context, child) {
            return Directionality(
              textDirection: localeProvider.textDirection,
              child: MediaQuery(
                // Ensure text scale factor is reasonable for all languages
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
                ),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize authentication
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize locale with system locale if available
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    // Run initialization tasks concurrently
    await Future.wait([
      authProvider.checkAuthState(),
      localeProvider.initializeWithSystemLocale(),
    ]);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while authentication is being processed
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        // Route to appropriate dashboard based on authentication and role
        if (authProvider.isAuthenticated) {
          final userRole = authProvider.currentUser?.role;

          switch (userRole) {
            case 'admin':
              return const EnhancedAdminDashboard();
            case 'employee':
              return const EmployeeDashboard();
            default:
            // Fallback for unknown roles
              return const EmployeeDashboard();
          }
        }

        // Not authenticated, show login screen
        return const LoginScreen();
      },
    );
  }
}

// Optional: Global error handler for localization issues
class LocalizationErrorHandler extends StatelessWidget {
  final Widget child;

  const LocalizationErrorHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          // Try to access localizations to ensure they're loaded
          AppLocalizations.of(context);
          return child;
        } catch (e) {
          // Fallback UI if localizations fail to load
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Localization Error',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load language resources: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Try to reload the app
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const TraiteurApp()),
                          );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}