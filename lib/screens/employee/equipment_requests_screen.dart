// lib/screens/employee/equipment_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/equipment_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class EquipmentRequestsScreen extends StatefulWidget {
  const EquipmentRequestsScreen({super.key});

  @override
  State<EquipmentRequestsScreen> createState() => _EquipmentRequestsScreenState();
}

class _EquipmentRequestsScreenState extends State<EquipmentRequestsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();

  late TabController _tabController;
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _approvedRequests = [];
  List<Map<String, dynamic>> _rejectedRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEmployeeRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployeeRequests() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      // Load requests by status for current employee
      final pending = await _firestoreService.getEmployeeCheckoutRequestsByStatus(
          currentUser.id,
          'pending_approval'
      );
      final approved = await _firestoreService.getEmployeeCheckoutRequestsByStatus(
          currentUser.id,
          'checked_out'
      );
      final rejected = await _firestoreService.getEmployeeCheckoutRequestsByStatus(
          currentUser.id,
          'rejected'
      );

      // Group by requestId
      final groupedPending = _groupRequestsByRequestId(pending);
      final groupedApproved = _groupRequestsByRequestId(approved);
      final groupedRejected = _groupRequestsByRequestId(rejected);

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

  Map<String, List<EquipmentCheckout>> _groupRequestsByRequestId(List<EquipmentCheckout> requests) {
    Map<String, List<EquipmentCheckout>> grouped = {};
    for (EquipmentCheckout request in requests) {
      String requestId = request.requestId ?? request.id;
      if (!grouped.containsKey(requestId)) {
        grouped[requestId] = [];
      }
      grouped[requestId]!.add(request);
    }
    return grouped;
  }

  List<Map<String, dynamic>> _convertGroupedRequestsToList(Map<String, List<EquipmentCheckout>> grouped) {
    return grouped.entries.map((entry) {
      final requests = entry.value;
      final firstRequest = requests.first;
      final totalQuantity = requests.fold<int>(0, (sum, req) => sum + req.quantity);

      return {
        'requestId': entry.key,
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Equipment Requests'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadEmployeeRequests,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
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
                child: const Icon(Icons.schedule),
              )
                  : const Icon(Icons.schedule),
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
      onRefresh: _loadEmployeeRequests,
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
        message = 'No pending requests\nYour submitted requests will appear here';
        icon = Icons.schedule;
        color = AppColors.warning;
        break;
      case 'approved':
        message = 'No approved requests\nApproved requests will be shown here';
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case 'rejected':
        message = 'No rejected requests\nRejected requests will appear here';
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
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> requestData, String type) {
    final requests = requestData['requests'] as List<EquipmentCheckout>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(type),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(type),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
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

            // Request ID
            Text(
              'Request #${requestData['requestId'].substring(0, 8)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

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

            // Status message for pending
            if (type == 'pending') ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your request is pending admin approval. You will be notified once it\'s reviewed.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Time tracking
            const SizedBox(height: 12),
            _buildTimeTracking(requestData, type),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(Map<String, dynamic> requestData, String type) {
    Color statusColor = _getStatusColor(type);

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
                _getStatusText(type),
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
              type == 'approved'
                  ? 'Approved by ${requestData['approvedBy']} on ${DateFormat('MMM dd, yyyy HH:mm').format(requestData['approvalDate'])}'
                  : 'Rejected by ${requestData['approvedBy']} on ${DateFormat('MMM dd, yyyy HH:mm').format(requestData['approvalDate'])}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (type == 'rejected' && requestData['rejectionReason'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rejection Reason:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    requestData['rejectionReason'],
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          if (type == 'approved') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Equipment has been checked out to you. Please return when finished.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeTracking(Map<String, dynamic> requestData, String type) {
    final requestDate = requestData['requestDate'] as DateTime?;
    if (requestDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final timeSinceRequest = now.difference(requestDate);

    String timeText;
    if (timeSinceRequest.inDays > 0) {
      timeText = '${timeSinceRequest.inDays} day${timeSinceRequest.inDays > 1 ? 's' : ''} ago';
    } else if (timeSinceRequest.inHours > 0) {
      timeText = '${timeSinceRequest.inHours} hour${timeSinceRequest.inHours > 1 ? 's' : ''} ago';
    } else if (timeSinceRequest.inMinutes > 0) {
      timeText = '${timeSinceRequest.inMinutes} minute${timeSinceRequest.inMinutes > 1 ? 's' : ''} ago';
    } else {
      timeText = 'Just now';
    }

    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          'Requested $timeText',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        if (type == 'pending' && timeSinceRequest.inHours > 24) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Long pending',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
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
        return Icons.schedule;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String type) {
    switch (type) {
      case 'pending':
        return 'Pending Review';
      case 'approved':
        return 'Approved & Checked Out';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}