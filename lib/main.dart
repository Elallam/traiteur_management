import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/firebase_options.dart';
import 'package:traiteur_management/providers/equipment_booking_provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/occasion_provider.dart';
import 'providers/employee_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await FirebaseAppCheck.instance.activate(
  //   webProvider: ReCaptchaV3Provider('recaptcha-site-key'),
  //   androidProvider: AndroidProvider.debug,
  //   appleProvider: AppleProvider.appAttest,
  // );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => OccasionProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => EquipmentBookingProvider()),
      ],
      child: const TraiteurApp(),
    ),
  );
}