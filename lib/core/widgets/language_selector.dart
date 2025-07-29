import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsDialog;
  final bool showFlag;
  final bool showText;
  final bool compact;
  final Color? iconColor;
  final double? iconSize;

  const LanguageSelector({
    Key? key,
    this.showAsDialog = false,
    this.showFlag = true,
    this.showText = true,
    this.compact = false,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context);

    if (showAsDialog) {
      return _buildDialogButton(context, localeProvider, l10n!);
    }

    if (compact) {
      return _buildCompactSelector(context, localeProvider, l10n!);
    }

    return _buildPopupMenuButton(context, localeProvider, l10n!);
  }

  Widget _buildDialogButton(BuildContext context, LocaleProvider localeProvider, AppLocalizations l10n) {
    return IconButton(
      icon: Icon(
        Icons.language,
        color: iconColor,
        size: iconSize,
      ),
      tooltip: l10n.language,
      onPressed: () => _showLanguageDialog(context, localeProvider, l10n),
    );
  }

  Widget _buildCompactSelector(BuildContext context, LocaleProvider localeProvider, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: localeProvider.locale,
          isDense: true,
          onChanged: (locale) {
            if (locale != null) {
              localeProvider.setLocale(locale);
            }
          },
          items: LocaleProvider.supportedLocales.map((locale) {
            final languageCode = locale.languageCode;
            final flag = LocaleProvider.languageFlags[languageCode] ?? '';
            final name = LocaleProvider.languageNames[languageCode] ?? '';

            return DropdownMenuItem<Locale>(
              value: locale,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showFlag) ...[
                    Text(flag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                  ],
                  if (showText)
                    Text(
                      name,
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPopupMenuButton(BuildContext context, LocaleProvider localeProvider, AppLocalizations l10n) {
    return PopupMenuButton<Locale>(
      icon: Icon(
        Icons.language,
        color: iconColor,
        size: iconSize,
      ),
      tooltip: l10n.language,
      onSelected: (locale) => localeProvider.setLocale(locale),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      offset: const Offset(0, 50),
      itemBuilder: (context) => LocaleProvider.supportedLocales.map((locale) {
        final languageCode = locale.languageCode;
        final flag = LocaleProvider.languageFlags[languageCode] ?? '';
        final name = LocaleProvider.languageNames[languageCode] ?? '';
        final isSelected = localeProvider.locale == locale;

        return PopupMenuItem<Locale>(
          value: locale,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                if (showFlag) ...[
                  Text(flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.language, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(l10n.language),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocaleProvider.supportedLocales.map((locale) {
            final languageCode = locale.languageCode;
            final flag = LocaleProvider.languageFlags[languageCode] ?? '';
            final name = LocaleProvider.languageNames[languageCode] ?? '';
            final isSelected = localeProvider.locale == locale;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
              ),
              child: ListTile(
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Text(flag, style: const TextStyle(fontSize: 20)),
                title: Text(
                  name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                    : null,
                onTap: () {
                  localeProvider.setLocale(locale);
                  Navigator.of(context).pop();
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}

// Alternative horizontal language selector for settings pages
class HorizontalLanguageSelector extends StatelessWidget {
  const HorizontalLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.language,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: LocaleProvider.supportedLocales.map((locale) {
                final languageCode = locale.languageCode;
                final flag = LocaleProvider.languageFlags[languageCode] ?? '';
                final name = LocaleProvider.languageNames[languageCode] ?? '';
                final isSelected = localeProvider.locale == locale;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => localeProvider.setLocale(locale),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick language toggle button (cycles through languages)
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: IconButton(
        onPressed: () => localeProvider.toggleLanguage(),
        icon: Text(
          localeProvider.currentLanguageFlag,
          style: const TextStyle(fontSize: 20),
        ),
        tooltip: localeProvider.currentLanguageName,
      ),
    );
  }
}