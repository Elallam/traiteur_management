import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/utils/validators.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'package:traiteur_management/core/widgets/language_selector.dart'; // Import the language selector widget

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final appLocalizations = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? appLocalizations.loginFailedMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final appLocalizations = AppLocalizations.of(context)!;
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.pleaseEnterEmailFirst),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.resetPassword(_emailController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? appLocalizations.passwordResetEmailSent
                : authProvider.errorMessage ?? appLocalizations.failedToSendResetEmail,
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _navigateToSignUp() {
    // Navigate to sign up screen
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return LoadingOverlay(
              isLoading: authProvider.isLoading,
              loadingMessage: appLocalizations.signingIn,
              child: Stack( // Use Stack to position the language selector
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),

                          // Logo Section
                          _buildLogoSection(appLocalizations),

                          const SizedBox(height: 48),

                          // Welcome Text
                          _buildWelcomeText(appLocalizations),

                          const SizedBox(height: 32),

                          // Email Field
                          CustomTextField(
                            label: appLocalizations.emailAddress,
                            hint: appLocalizations.enterYourEmail,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: Validators.email,
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          CustomTextField(
                            label: appLocalizations.passwordText,
                            hint: appLocalizations.enterYourPassword,
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline,
                            validator: Validators.password,
                          ),

                          const SizedBox(height: 16),

                          // Remember Me and Forgot Password
                          _buildRememberAndForgot(appLocalizations),

                          const SizedBox(height: 32),

                          // Login Button
                          CustomButton(
                            text: appLocalizations.signIn,
                            onPressed: _handleLogin,
                            isLoading: authProvider.isLoading,
                          ),

                          const SizedBox(height: 24),

                          // Error Message
                          if (authProvider.errorMessage != null)
                            _buildErrorMessage(authProvider.errorMessage!),

                          const SizedBox(height: 48),

                          // Footer
                          _buildFooter(appLocalizations),
                        ],
                      ),
                    ),
                  ),
                  Positioned( // Position the language selector
                    top: 16,
                    right: 16,
                    child: LanguageSelector(
                      showAsDialog: true, // You can choose how you want it to display
                      iconColor: AppColors.primary,
                      iconSize: 28,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoSection(AppLocalizations appLocalizations) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 50,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          appLocalizations.loginScreenTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(AppLocalizations appLocalizations) {
    return Column(
      children: [
        Text(
          appLocalizations.welcomeBack,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          appLocalizations.signInToManage,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRememberAndForgot(AppLocalizations appLocalizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me Checkbox
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (bool? value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              appLocalizations.rememberMe,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),

        // Forgot Password Button
        TextButton(
          onPressed: _handleForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            appLocalizations.forgotPasswordQuestion,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations appLocalizations) {
    return Column(
      children: [
        // Divider with OR text
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: AppColors.greyLight,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                appLocalizations.orText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                color: AppColors.greyLight,
                thickness: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sign Up Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appLocalizations.dontHaveAccount,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: _navigateToSignUp,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                appLocalizations.signUp,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // App Version or Company Info
        Text(
          appLocalizations.copyrightText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          appLocalizations.versionText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
