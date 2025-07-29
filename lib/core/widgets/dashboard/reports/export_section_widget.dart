import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';
import '../../custom_button.dart';
import '../common/section_header.dart';

/// Export section widget for reports dashboard
/// Provides PDF and Excel export functionality
class ExportSectionWidget extends StatelessWidget {
  final VoidCallback? onExportPDF;
  final VoidCallback? onExportExcel;

  const ExportSectionWidget({
    super.key,
    this.onExportPDF,
    this.onExportExcel,
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
            SectionHeader(title: l10n.exportReports),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: l10n.exportPdf,
                    onPressed: onExportPDF ?? _defaultExportPDF,
                    icon: Icons.picture_as_pdf,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: l10n.exportExcel,
                    onPressed: onExportExcel ?? _defaultExportExcel,
                    icon: Icons.table_chart,
                    outlined: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildExportInfo(l10n),
          ],
        ),
      ),
    );
  }

  /// Builds export information text
  Widget _buildExportInfo(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.exportInfo ?? 'Reports include data from the selected time period',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Default PDF export handler
  void _defaultExportPDF() {
    // Default implementation - can be overridden
    debugPrint('PDF Export clicked');
  }

  /// Default Excel export handler
  void _defaultExportExcel() {
    // Default implementation - can be overridden
    debugPrint('Excel Export clicked');
  }
}