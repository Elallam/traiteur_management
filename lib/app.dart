import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';
import 'package:traiteur_management/providers/locale_provider.dart';
import 'package:traiteur_management/providers/notification_provider.dart';
import 'package:traiteur_management/screens/admin/enhanced_admin_dashboard.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
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
          locale: localeProvider.locale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            return supportedLocales.first;
          },
          builder: (context, child) {
            return Directionality(
                textDirection: localeProvider.textDirection,
                child: MediaQuery(
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Starting app initialization...');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

      // Initialize auth and locale concurrently
      await Future.wait([
        _initializeAuth(authProvider),
        localeProvider.initializeWithSystemLocale(),
      ], eagerError: true);

      debugPrint('Auth state: ${authProvider.isAuthenticated}');

      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        try {
          await notificationProvider.initialize(authProvider.currentUser!.id);
          debugPrint('Notifications initialized');
        } catch (e) {
          debugPrint('Notification init error: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e, stack) {
      debugPrint('Initialization error: $e');
      debugPrint('Stack trace: $stack');

      if (mounted) {
        setState(() {
          _isInitialized = true; // Still set to true to show error UI
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _initializeAuth(AuthProvider authProvider) async {
    try {
      await authProvider.checkAuthState();
    } catch (e, stack) {
      debugPrint('Auth initialization error: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        final userRole = authProvider.currentUser?.role?.toLowerCase();
        debugPrint('User role: $userRole');

        switch (userRole) {
          case 'admin':
            return const EnhancedAdminDashboard();
          case 'employee':
            return const EmployeeDashboard();
          default:
            debugPrint('Unknown role: $userRole - defaulting to login');
            return const LoginScreen();
        }
      },
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Initialization Error',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _errorMessage ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isInitialized = false;
                  _errorMessage = null;
                });
                _initializeApp();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}