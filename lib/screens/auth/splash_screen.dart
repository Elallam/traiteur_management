import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';

import '../../generated/l10n/app_localizations.dart'; // Import the generated localization file

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 60,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 32),

            // App Name
            Text(
              appLocalizations.appTitle.split(' ')[0], // Assuming "Traiteur" is the first word
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              appLocalizations.appTitle.split(' ').sublist(1).join(' '), // Assuming "Management" is the second word
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.white.withOpacity(0.9),
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const LoadingWidget(
              color: AppColors.white,
              size: 40,
            ),

            const SizedBox(height: 16),

            Text(
              appLocalizations.loadingMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),

            const Spacer(),

            // Version or tagline
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                appLocalizations.professionalCateringManagement,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
