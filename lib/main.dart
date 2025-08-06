import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/firebase_options.dart';
import 'package:traiteur_management/providers/cash_transaction_provider.dart';
import 'package:traiteur_management/providers/category_provider.dart';
import 'package:traiteur_management/providers/equipment_booking_provider.dart';
import 'package:traiteur_management/providers/locale_provider.dart';
import 'package:traiteur_management/providers/notification_provider.dart';
import 'package:traiteur_management/screens/auth/splash_screen.dart';
import 'package:traiteur_management/services/enhanced_notification_service.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/occasion_provider.dart';
import 'providers/employee_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCFekRvH0YL4hKxOwwsjTar4OeN6wWcMpE",
            authDomain: "traiteurmanagement-bdd43.firebaseapp.com",
            projectId: "traiteurmanagement-bdd43",
            storageBucket: "traiteurmanagement-bdd43.firebasestorage.app",
            messagingSenderId: "707485444506",
            appId: "1:707485444506:web:9555a169f1e780bd6c3223",
            measurementId: "G-PN0W8T0FGJ"
        ),
      );
    }
    else{
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  // Run the app with error handling
  runApp(
    MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => OccasionProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => EquipmentBookingProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // Provider<CashTransactionProvider>(create: (_) => CashTransactionProvider()),
        ChangeNotifierProvider(create: (_) => CashTransactionProvider()),
      ],

      child: const AppWrapper(),
    ),
  );
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _hasError = false;
  String? _errorMessage;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();

    // Initialize error handling after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupErrorHandling();
      _initializeApp();
    });
  }

  void _setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');

      // Schedule the state update for next frame
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = details.exception.toString();
          });
        }
      });
    };
  }

  Future<void> _initializeApp() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

      await Future.wait([
        authProvider.checkAuthState(),
        localeProvider.initializeWithSystemLocale(),
      ]);

      // Initialize locale first
      await localeProvider.initializeWithSystemLocale();

      // Then check auth state
      await authProvider.checkAuthState();

      if (authProvider.isAuthenticated) {
        await notificationProvider.initialize(authProvider.currentUser!.id);
        final notificationService = EnhancedNotificationService();
        await notificationService.saveUserToken(authProvider.currentUser!.id);
        await notificationService.initialize();
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Error during app initialization: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(
          error: _errorMessage ?? 'An unexpected error occurred',
          onRetry: () {
            setState(() {
              _hasError = false;
              _errorMessage = null;
              _isInitializing = true;
            });
            _initializeApp();
          },
        ),
      );
    }

    // if (_isInitializing) {
    //   return const MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: Scaffold(
    //       body: Center(
    //         child: SplashScreen(),
    //       ),
    //     ),
    //   );
    // }

    return const TraiteurApp();
  }
}

/// Error screen for critical app failures
class ErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Application Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'The application encountered an error and needs to restart.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Retry'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Close the app (Android)
                        // For iOS, you typically don't close apps programmatically
                        // SystemNavigator.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Exit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'If this problem persists, please contact support.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Development helper - shows provider states in debug mode
class ProviderDebugInfo extends StatelessWidget {
  const ProviderDebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Provider States:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Consumer<AuthProvider>(
              builder: (context, auth, child) => Text(
                'Auth: ${auth.isAuthenticated ? "✓" : "✗"} ${auth.currentUser?.role ?? "none"}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            Consumer<NotificationProvider>(
              builder: (context, notifications, child) => Text(
                'Notifications: ${notifications.unreadCount} unread',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            Consumer<StockProvider>(
              builder: (context, stock, child) => Text(
                'Stock: ${stock.equipment.length} items',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            Consumer<OccasionProvider>(
              builder: (context, occasions, child) => Text(
                'Occasions: ${occasions.occasions.length} events',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}