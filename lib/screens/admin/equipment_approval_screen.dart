// lib/screens/admin/equipment_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_widget.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/equipment_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';

class EquipmentApprovalScreen extends StatefulWidget {
  const EquipmentApprovalScreen({super.key});

  @override
  State<EquipmentApprovalScreen> createState() => _EquipmentApprovalScreenState();
}

class _EquipmentApprovalScreenState extends State<EquipmentApprovalScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  late TabController _tabController;
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _approvedRequests = [];
  List<Map<String, dynamic>> _rejectedRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCheckoutRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCheckoutRequests() async {
    setState(() => _isLoading = true);
    try {
      // Load requests by status
      final pending = await _firestoreService.getCheckoutRequestsByStatus('pending_approval');
      final approved = await _firestoreService.getCheckoutRequestsByStatus('checked_out');
      final rejected = await _firestoreService.getCheckoutRequestsByStatus('rejected');

      // Group by requestId for better organization
      final groupedPending = await _firestoreService.getGroupedCheckoutRequests('pending_approval');
      final groupedApproved = await _firestoreService.getGroupedCheckoutRequests('checked_out');
      final groupedRejected = await _firestoreService.getGroupedCheckoutRequests('rejected');

      setState(() {
        _pendingRequests = _convertGroupedRequestsToList(groupedPending);
        _approvedRequests = _convertGroupedRequestsToList(groupedApproved);
        _rejectedRequests = _convertGroupedRequestsToList(groupedRejected);
      });
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _convertGroupedRequestsToList(Map<String, List<EquipmentCheckout>> grouped) {
    return grouped.entries.map((entry) {
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
        'approvedBy': firstRequest.approvedBy,
        'approvalDate': firstRequest.approvalDate,
        'rejectionReason': firstRequest.rejectionReason,
      };
    }).toList()..sort((a, b) => (b['requestDate'] as DateTime?)?.compareTo(a['requestDate'] as DateTime? ?? DateTime.now()) ?? 0);
  }

  Future<void> _approveRequest(String requestId, List<EquipmentCheckout> requests) async {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    try {
      // Show confirmation dialog
      bool confirmed = await _showConfirmationDialog(
        'Approve Request',
        'Are you sure you want to approve this equipment checkout request?',
        'Approve',
        Colors.green,
      );

      if (!confirmed) return;

      // Approve all requests in the group
      final requestIds = requests.map((r) => r.id).toList();
      await _firestoreService.batchApproveCheckoutRequests(
        requestIds,
        currentUser.id,
        currentUser.fullName,
      );

      // Send notification to employee
      await _sendApprovalNotification(requests.first.employeeId, requests.first.employeeName, requestId, true);

      // Reload data
      await _loadCheckoutRequests();

      _showSuccessSnackBar('Request approved successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to approve request: $e');
    }
  }

  Future<void> _rejectRequest(String requestId, List<EquipmentCheckout> requests) async {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    // Show rejection reason dialog
    final rejectionReason = await _showRejectionDialog();
    if (rejectionReason == null || rejectionReason.isEmpty) return;

    try {
      // Reject all requests in the group
      final requestIds = requests.map((r) => r.id).toList();
      await _firestoreService.batchRejectCheckoutRequests(
        requestIds,
        currentUser.id,
        currentUser.fullName,
        rejectionReason,
      );

      // Send notification to employee
      await _sendApprovalNotification(requests.first.employeeId, requests.first.employeeName, requestId, false, rejectionReason);

      // Reload data
      await _loadCheckoutRequests();

      _showSuccessSnackBar('Request rejected successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to reject request: $e');
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content, String actionText, Color actionColor) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: actionColor),
            child: Text(actionText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<String?> _showRejectionDialog() async {
    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejecting this request:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendApprovalNotification(String employeeId, String employeeName, String requestId, bool approved, [String? rejectionReason]) async {
    try {
      final notification = {
        'userId': employeeId,
        'title': approved ? 'Equipment Request Approved' : 'Equipment Request Rejected',
        'message': approved
            ? 'Your equipment checkout request has been approved and the items are now checked out to you.'
            : 'Your equipment checkout request has been rejected. Reason: ${rejectionReason ?? 'No reason provided'}',
        'type': approved ? 'equipment_request_approved' : 'equipment_request_rejected',
        'priority': 'high',
        'isRead': false,
        'createdAt': DateTime.now(),
        'data': {
          'requestId': requestId,
          'approved': approved,
          'rejectionReason': rejectionReason,
        },
      };

      await _notificationService.sendNotification(notification);
    } catch (e) {
      // Don't throw error for notification failure
      print('Failed to send notification: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Approval'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Pending',
              icon: _pendingRequests.isNotEmpty
                  ? Badge(
                label: Text('${_pendingRequests.length}'),
                child: const Icon(Icons.pending_actions),
              )
                  : const Icon(Icons.pending_actions),
            ),
            Tab(
              text: 'Approved',
              icon: Icon(Icons.check_circle),
            ),
            Tab(
              text: 'Rejected',
              icon: Icon(Icons.cancel),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList(_pendingRequests, 'pending'),
          _buildRequestsList(_approvedRequests, 'approved'),
          _buildRequestsList(_rejectedRequests, 'rejected'),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<Map<String, dynamic>> requests, String type) {
    if (requests.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadCheckoutRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(requests[index], type);
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    IconData icon;
    Color color;

    switch (type) {
      case 'pending':
        message = 'No pending requests';
        icon = Icons.pending_actions;
        color = AppColors.warning;
        break;
      case 'approved':
        message = 'No approved requests';
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case 'rejected':
        message = 'No rejected requests';
        icon = Icons.cancel;
        color = AppColors.error;
        break;
      default:
        message = 'No requests';
        icon = Icons.inbox;
        color = AppColors.textSecondary;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> requestData, String type) {
    final requests = requestData['requests'] as List<EquipmentCheckout>;
    final firstRequest = requests.first;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(type),
                  child: Icon(
                    _getStatusIcon(type),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        requestData['employeeName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Request #${requestData['requestId'].substring(0, 8)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (requestData['requestDate'] != null)
                  Text(
                    DateFormat('MMM dd, HH:mm').format(requestData['requestDate']),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Equipment summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${requestData['itemCount']} equipment types',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text(
                    '${requestData['totalQuantity']} total items',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Equipment list
            ...requests.map((request) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${request.equipmentName ?? 'Unknown Equipment'} × ${request.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),

            // Notes
            if (requestData['notes'] != null && (requestData['notes'] as String).isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      requestData['notes'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],

            // Status-specific information
            if (type != 'pending') ...[
              const SizedBox(height: 12),
              _buildStatusInfo(requestData, type),
            ],

            // Action buttons for pending requests
            if (type == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRequest(requestData['requestId'], requests),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(requestData['requestId'], requests),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(Map<String, dynamic> requestData, String type) {
    Color statusColor = _getStatusColor(type);
    String statusText = type.capitalize();

    if (type == 'approved') {
      statusText = 'Approved & Checked Out';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getStatusIcon(type), size: 16, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (requestData['approvedBy'] != null && requestData['approvalDate'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'By ${requestData['approvedBy']} on ${DateFormat('MMM dd, yyyy HH:mm').format(requestData['approvalDate'])}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (type == 'rejected' && requestData['rejectionReason'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${requestData['rejectionReason']}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String type) {
    switch (type) {
      case 'pending':
        return Icons.pending_actions;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}