// report_filters_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';

class ReportFiltersWidget extends StatelessWidget {
  final Function(String) onFilterSelected;

  const ReportFiltersWidget({
    super.key,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportFilters,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: l10n.thisWeek,
                    onPressed: () => onFilterSelected('week'),
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: l10n.thisMonth,
                    onPressed: () => onFilterSelected('month'),
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: l10n.thisYear,
                    onPressed: () => onFilterSelected('year'),
                    outlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}