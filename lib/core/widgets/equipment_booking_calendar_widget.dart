// lib/core/widgets/equipment_booking_calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../models/equipment_model.dart';
import '../constants/app_colors.dart';
import '../../models/occasion_model.dart';
import '../../providers/equipment_booking_provider.dart';

class EquipmentBookingCalendarWidget extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? selectedDate;

  const EquipmentBookingCalendarWidget({
    Key? key,
    this.onDateSelected,
    this.selectedDate,
  }) : super(key: key);

  @override
  State<EquipmentBookingCalendarWidget> createState() => _EquipmentBookingCalendarWidgetState();
}

class _EquipmentBookingCalendarWidgetState extends State<EquipmentBookingCalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate ?? DateTime.now();
    _selectedDay = widget.selectedDate;
    _loadCalendarEvents();
  }

  Future<void> _loadCalendarEvents() async {
    final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);

    final startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    await bookingProvider.loadBookingCalendar(
      startDate: startDate,
      endDate: endDate,
    );

    setState(() {
      _events = _normalizeEvents(bookingProvider.bookingCalendar);
    });
  }

  Map<DateTime, List<Map<String, dynamic>>> _normalizeEvents(
      Map<String, List<Map<String, dynamic>>> calendarData,
      ) {
    Map<DateTime, List<Map<String, dynamic>>> normalized = {};

    calendarData.forEach((dateString, occasions) {
      final parts = dateString.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      normalized[date] = occasions;
    });

    return normalized;
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EquipmentBookingProvider>(
      builder: (context, bookingProvider, child) {
        return Column(
          children: [
            // Calendar Header
            _buildCalendarHeader(),

            // Calendar
            TableCalendar<Map<String, dynamic>>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
                holidayTextStyle: const TextStyle(color: AppColors.error),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDateSelected?.call(selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadCalendarEvents();
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;

                  return Positioned(
                    bottom: 1,
                    child: _buildEventMarker(events.length),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Events for selected day
            if (_selectedDay != null) _buildEventsList(),
          ],
        );
      },
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppColors.primary),
          const SizedBox(width: 12),
          const Text(
            'Equipment Booking Calendar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _loadCalendarEvents,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventMarker(int count) {
    Color markerColor = AppColors.info;
    if (count > 2) markerColor = AppColors.error;
    else if (count > 1) markerColor = AppColors.warning;

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No Events Scheduled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'All equipment is available on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Events on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...events.map((eventData) => _buildEventCard(eventData)),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> eventData) {
    OccasionModel occasion = eventData['occasion'];
    Map<String, int> equipmentSummary = eventData['equipmentSummary'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(occasion.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    occasion.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    occasion.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(occasion.date),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Client Info
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  occasion.clientName,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.group, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${occasion.expectedGuests} guests',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Equipment Summary
            const Text(
              'Equipment Booked:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: equipmentSummary.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return AppColors.info;
      case 'confirmed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      case 'completed':
        return AppColors.textSecondary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

// Equipment Utilization Chart Widget
class EquipmentUtilizationChart extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const EquipmentUtilizationChart({
    Key? key,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EquipmentBookingProvider>(
      builder: (context, bookingProvider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: bookingProvider.getEquipmentUtilizationStats(
            startDate: startDate,
            endDate: endDate,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final stats = snapshot.data!;
            final report = stats['report'] as List<Map<String, dynamic>>;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Equipment Utilization Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Summary Stats
                    Row(
                      children: [
                        _buildStatCard(
                          'Average Utilization',
                          '${stats['averageUtilization'].toStringAsFixed(1)}%',
                          AppColors.info,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Fully Booked',
                          '${stats['fullyBookedTypes']}/${stats['totalEquipmentTypes']}',
                          AppColors.error,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Underutilized',
                          '${stats['underutilizedTypes']}',
                          AppColors.warning,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Equipment List
                    const Text(
                      'Equipment Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...report.take(5).map((item) => _buildEquipmentUtilizationItem(item)),

                    if (report.length > 5)
                      TextButton(
                        onPressed: () => _showFullReport(context, report),
                        child: Text('View All ${report.length} Items'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentUtilizationItem(Map<String, dynamic> item) {
    final equipment = item['equipment'] as EquipmentModel;
    final utilizationRate = item['utilizationRate'] as double;
    final bookedQuantity = item['bookedQuantity'] as int;
    final totalQuantity = item['totalQuantity'] as int;

    Color utilizationColor = AppColors.success;
    if (utilizationRate >= 100) {
      utilizationColor = AppColors.error;
    } else if (utilizationRate >= 70) {
      utilizationColor = AppColors.warning;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              equipment.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$bookedQuantity/$totalQuantity',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: utilizationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${utilizationRate.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: utilizationColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullReport(BuildContext context, List<Map<String, dynamic>> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full Equipment Utilization Report'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: report.length,
            itemBuilder: (context, index) {
              return _buildEquipmentUtilizationItem(report[index]);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}