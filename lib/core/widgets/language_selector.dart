import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsDialog;

  const LanguageSelector({
    Key? key,
    this.showAsDialog = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context);

    if (showAsDialog) {
      return IconButton(
        icon: const Icon(Icons.language),
        onPressed: () => _showLanguageDialog(context, localeProvider, l10n!),
      );
    }

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: l10n?.language,
      onSelected: (locale) => localeProvider.setLocale(locale),
      itemBuilder: (context) =>
          LocaleProvider.supportedLocales
              .map((locale) =>
              PopupMenuItem<Locale>(
                value: locale,
                child: Row(
                  children: [
                    Text(LocaleProvider.languageNames[locale.languageCode]!),
                    if (localeProvider.locale == locale) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check, size: 16),
                    ],
                  ],
                ),
              ))
              .toList(),
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider,
      AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(l10n.language),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: LocaleProvider.supportedLocales
                  .map((locale) =>
                  ListTile(
                    title: Text(
                        LocaleProvider.languageNames[locale.languageCode]!),
                    leading: Radio<Locale>(
                      value: locale,
                      groupValue: localeProvider.locale,
                      onChanged: (value) {
                        if (value != null) {
                          localeProvider.setLocale(value);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    onTap: () {
                      localeProvider.setLocale(locale);
                      Navigator.of(context).pop();
                    },
                  ))
                  .toList(),
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