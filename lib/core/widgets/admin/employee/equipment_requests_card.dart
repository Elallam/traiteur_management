// lib/core/widgets/dashboard/overview/equipment_requests_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../models/equipment_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../../screens/admin/equipment_approval_screen.dart';

class EquipmentRequestsCard extends StatefulWidget {
  const EquipmentRequestsCard({super.key});

  @override
  State<EquipmentRequestsCard> createState() => _EquipmentRequestsCardState();
}

class _EquipmentRequestsCardState extends State<EquipmentRequestsCard> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Get grouped pending checkout requests
      final groupedRequests = await _firestoreService.getGroupedCheckoutRequests('pending_approval');

      // Convert to list format for easier display
      final requestsList = groupedRequests.entries.map((entry) {
        final requests = entry.value;
        final firstRequest = requests.first;
        final totalQuantity = requests.fold<int>(0, (sum, req) => sum + req.quantity);

        return {
          'requestId': entry.key,
          'employeeName': firstRequest.employeeName,
          'employeeId': firstRequest.employeeId,
          'requestDate': firstRequest.requestDate,
          'occasionId': firstRequest.occasionId,
          'notes': firstRequest.notes,
          'itemCount': requests.length,
          'totalQuantity': totalQuantity,
          'requests': requests,
          'status': firstRequest.status,
        };
      }).toList();

      // Sort by request date (newest first)
      requestsList.sort((a, b) => (b['requestDate'] as DateTime?)?.compareTo(a['requestDate'] as DateTime? ?? DateTime.now()) ?? 0);

      if (mounted) {
        setState(() {
          _pendingRequests = requestsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Error loading pending requests: $e');
    }
  }

  void _navigateToApprovalScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EquipmentApprovalScreen(),
      ),
    ).then((_) {
      // Refresh the requests when returning from approval screen
      _loadPendingRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.pending_actions,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.equipmentRequests,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        l10n.pendingApproval,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_pendingRequests.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _pendingRequests.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Content
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_pendingRequests.isEmpty)
              _buildEmptyState(l10n)
            else
              _buildRequestsList(l10n),

            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToApprovalScreen,
                icon: const Icon(Icons.approval),
                label: Text(
                  _pendingRequests.isNotEmpty
                      ? l10n.reviewRequests
                      : l10n.viewAllRequests,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppColors.success.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noPendingRequests,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.allRequestsProcessed,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(AppLocalizations l10n) {
    // Show up to 3 most recent requests
    final displayRequests = _pendingRequests.take(3).toList();

    return Column(
      children: [
        ...displayRequests.map((request) => _buildRequestItem(request, l10n)),
        if (_pendingRequests.length > 3) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Text(
              l10n.andMoreRequests(_pendingRequests.length - 3),
              style: TextStyle(
                color: AppColors.info,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee and time
          Row(
            children: [
              Expanded(
                child: Text(
                  request['employeeName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (request['requestDate'] != null)
                Text(
                  _getTimeAgo(request['requestDate'], l10n),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Equipment summary
          Row(
            children: [
              Icon(
                Icons.inventory,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.requestSummary(request['itemCount'], request['totalQuantity']),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          // Show first few equipment items
          const SizedBox(height: 6),
          ...((request['requests'] as List<EquipmentCheckout>).take(2).map((equipment) =>
              Padding(
                padding: const EdgeInsets.only(left: 22, bottom: 2),
                child: Text(
                  '• ${equipment.equipmentName ?? 'Unknown'} × ${equipment.quantity}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          )),

          if ((request['requests'] as List<EquipmentCheckout>).length > 2)
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Text(
                '• ${l10n.andMoreItems((request['requests'] as List<EquipmentCheckout>).length - 2)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.info,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.minutesAgo(difference.inMinutes);
    } else {
      return l10n.justNow;
    }
  }
}