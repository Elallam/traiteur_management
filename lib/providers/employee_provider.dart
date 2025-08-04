import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/equipment_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Employees
  List<UserModel> _employees = [];
  List<UserModel> get employees => _employees;

  // Equipment checkouts
  List<EquipmentCheckout> _equipmentCheckouts = [];
  List<EquipmentCheckout> get equipmentCheckouts => _equipmentCheckouts;

  // ==================== EMPLOYEE MANAGEMENT ====================

  /// Load all employees
  Future<void> loadEmployees() async {
    _setLoading(true);
    _clearError();

    try {
      _employees = await _authService.getEmployees();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Create new employee
  Future<bool> createEmployee({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      UserModel? newEmployee = await _authService.createUserAccount(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        address: address,
        role: 'employee',
      );

      if (newEmployee != null) {
        await loadEmployees(); // Refresh the list
        return true;
      } else {
        _setError('Failed to create employee account');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update employee
  Future<bool> updateEmployee(UserModel employee) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.updateUser(employee);
      await loadEmployees(); // Refresh the list
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete employee (soft delete)
  Future<bool> deleteEmployee(String employeeId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.deleteUser(employeeId);
      await loadEmployees(); // Refresh the list
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get employee by ID
  UserModel? getEmployeeById(String employeeId) {
    try {
      return _employees.firstWhere((employee) => employee.id == employeeId);
    } catch (e) {
      return null;
    }
  }

  /// Search employees
  List<UserModel> searchEmployees(String query) {
    return _employees.where((employee) {
      return employee.fullName.toLowerCase().contains(query.toLowerCase()) ||
          employee.email.toLowerCase().contains(query.toLowerCase()) ||
          employee.phone.contains(query);
    }).toList();
  }

  /// Get active employees
  List<UserModel> getActiveEmployees() {
    return _employees.where((employee) => employee.isActive).toList();
  }

  /// Get inactive employees
  List<UserModel> getInactiveEmployees() {
    return _employees.where((employee) => !employee.isActive).toList();
  }

  // ==================== EQUIPMENT CHECKOUT MANAGEMENT ====================

  /// Load equipment checkouts for specific employee
  Future<void> loadEmployeeCheckouts(String employeeId) async {
    _setLoading(true);
    _clearError();

    try {
      _equipmentCheckouts = await _firestoreService.getEquipmentCheckoutsByEmployee(employeeId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load all active equipment checkouts
  Future<void> loadAllActiveCheckouts() async {
    _setLoading(true);
    _clearError();

    try {
      _equipmentCheckouts = await _firestoreService.getActiveEquipmentCheckouts();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get employee's active checkouts
  List<EquipmentCheckout> getEmployeeActiveCheckouts(String employeeId) {
    return _equipmentCheckouts.where((checkout) {
      return checkout.employeeId == employeeId && checkout.status == 'checked_out';
    }).toList();
  }

  /// Get employee's checkout history
  List<EquipmentCheckout> getEmployeeCheckoutHistory(String employeeId) {
    return _equipmentCheckouts.where((checkout) {
      return checkout.employeeId == employeeId;
    }).toList()..sort((a, b) => b.checkoutDate!.compareTo(a.checkoutDate ?? DateTime.now()));
  }

  /// Get overdue checkouts for employee
  List<EquipmentCheckout> getEmployeeOverdueCheckouts(String employeeId) {
    return _equipmentCheckouts.where((checkout) {
      return checkout.employeeId == employeeId && checkout.isOverdue;
    }).toList();
  }

  /// Get all overdue checkouts
  Future<List<EquipmentCheckout>> getAllOverdueCheckouts() async {
    try {
      return await _firestoreService.getOverdueEquipmentCheckouts();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // ==================== EMPLOYEE ANALYTICS ====================

  /// Get employee statistics
  Map<String, dynamic> getEmployeeStatistics() {
    int totalEmployees = _employees.length;
    int activeEmployees = getActiveEmployees().length;
    int inactiveEmployees = getInactiveEmployees().length;

    // Calculate checkout statistics
    Map<String, int> employeeCheckoutCounts = {};
    Map<String, int> employeeOverdueCounts = {};

    for (var checkout in _equipmentCheckouts) {
      // Count total checkouts per employee
      employeeCheckoutCounts[checkout.employeeId] =
          (employeeCheckoutCounts[checkout.employeeId] ?? 0) + 1;

      // Count overdue checkouts per employee
      if (checkout.isOverdue) {
        employeeOverdueCounts[checkout.employeeId] =
            (employeeOverdueCounts[checkout.employeeId] ?? 0) + 1;
      }
    }

    // Find most active employee
    String? mostActiveEmployeeId;
    int maxCheckouts = 0;
    employeeCheckoutCounts.forEach((employeeId, count) {
      if (count > maxCheckouts) {
        maxCheckouts = count;
        mostActiveEmployeeId = employeeId;
      }
    });

    UserModel? mostActiveEmployee;
    if (mostActiveEmployeeId != null) {
      mostActiveEmployee = getEmployeeById(mostActiveEmployeeId!);
    }

    // Calculate active checkouts
    int totalActiveCheckouts = _equipmentCheckouts
        .where((checkout) => checkout.status == 'checked_out')
        .length;

    int totalOverdueCheckouts = _equipmentCheckouts
        .where((checkout) => checkout.isOverdue)
        .length;

    return {
      'totalEmployees': totalEmployees,
      'activeEmployees': activeEmployees,
      'inactiveEmployees': inactiveEmployees,
      'totalActiveCheckouts': totalActiveCheckouts,
      'totalOverdueCheckouts': totalOverdueCheckouts,
      'mostActiveEmployee': mostActiveEmployee,
      'mostActiveEmployeeCheckouts': maxCheckouts,
      'employeesWithOverdueItems': employeeOverdueCounts.length,
    };
  }

  /// Get employee performance data
  Map<String, dynamic> getEmployeePerformance(String employeeId) {
    List<EquipmentCheckout> employeeCheckouts = getEmployeeCheckoutHistory(employeeId);
    List<EquipmentCheckout> activeCheckouts = getEmployeeActiveCheckouts(employeeId);
    List<EquipmentCheckout> overdueCheckouts = getEmployeeOverdueCheckouts(employeeId);

    int totalCheckouts = employeeCheckouts.length;
    int completedCheckouts = employeeCheckouts
        .where((checkout) => checkout.status == 'returned')
        .length;

    // Calculate average checkout duration for returned items
    List<EquipmentCheckout> returnedCheckouts = employeeCheckouts
        .where((checkout) => checkout.status == 'returned' && checkout.returnDate != null)
        .toList();

    double averageCheckoutDuration = 0.0;
    if (returnedCheckouts.isNotEmpty) {
      int totalDuration = 0;
      for (var checkout in returnedCheckouts) {
        totalDuration += checkout.returnDate!.difference(checkout.checkoutDate ?? DateTime.now()).inHours;
      }
      averageCheckoutDuration = totalDuration / returnedCheckouts.length;
    }

    // Calculate reliability score (percentage of on-time returns)
    double reliabilityScore = 0.0;
    if (completedCheckouts > 0) {
      int onTimeReturns = returnedCheckouts
          .where((checkout) => checkout.returnDate != null &&
          checkout.returnDate!.isBefore(checkout.checkoutDate ?? DateTime.now()) ||
          checkout.returnDate!.isAtSameMomentAs(checkout.checkoutDate ?? DateTime.now()))
          .length;
      reliabilityScore = (onTimeReturns / completedCheckouts) * 100;
    }

    return {
      'totalCheckouts': totalCheckouts,
      'activeCheckouts': activeCheckouts.length,
      'completedCheckouts': completedCheckouts,
      'overdueCheckouts': overdueCheckouts.length,
      'averageCheckoutDuration': averageCheckoutDuration,
      'reliabilityScore': reliabilityScore,
    };
  }

  /// Get top performing employees
  List<Map<String, dynamic>> getTopPerformingEmployees({int limit = 5}) {
    List<Map<String, dynamic>> employeePerformances = [];

    for (var employee in _employees) {
      if (employee.isActive) {
        Map<String, dynamic> performance = getEmployeePerformance(employee.id);
        performance['employee'] = employee;
        employeePerformances.add(performance);
      }
    }

    // Sort by reliability score (descending)
    employeePerformances.sort((a, b) =>
        b['reliabilityScore'].compareTo(a['reliabilityScore']));

    return employeePerformances.take(limit).toList();
  }

  // ==================== EMPLOYEE NOTIFICATIONS ====================

  /// Get employees with overdue items
  List<Map<String, dynamic>> getEmployeesWithOverdueItems() {
    List<Map<String, dynamic>> employeesWithOverdue = [];
    final now = DateTime.now();

    Map<String, List<EquipmentCheckout>> overdueByEmployee = {};

    for (var checkout in _equipmentCheckouts) {
      // Calculate overdue status dynamically
      final isOverdue = checkout.status == 'checked_out' &&
          now.isAfter(checkout.checkoutDate ?? DateTime.now());

      if (isOverdue) {
        if (!overdueByEmployee.containsKey(checkout.employeeId)) {
          overdueByEmployee[checkout.employeeId] = [];
        }
        overdueByEmployee[checkout.employeeId]!.add(checkout);
      }
    }

    overdueByEmployee.forEach((employeeId, overdueCheckouts) {
      UserModel? employee = getEmployeeById(employeeId);
      if (employee != null) {
        employeesWithOverdue.add({
          'employee': employee,
          'overdueCheckouts': overdueCheckouts,
          'overdueCount': overdueCheckouts.length,
        });
      }
    });

    // Sort by overdue count (descending)
    employeesWithOverdue.sort((a, b) =>
        b['overdueCount'].compareTo(a['overdueCount']));

    return employeesWithOverdue;
  }

  /// Get employees requiring attention
  List<Map<String, dynamic>> getEmployeesRequiringAttention() {
    List<Map<String, dynamic>> alerts = [];

    // Employees with overdue items
    List<Map<String, dynamic>> employeesWithOverdue = getEmployeesWithOverdueItems();
    for (var employeeData in employeesWithOverdue) {
      alerts.add({
        'type': 'overdue_equipment',
        'title': 'Overdue Equipment',
        'message': '${employeeData['employee'].fullName} has ${employeeData['overdueCount']} overdue item(s)',
        'employee': employeeData['employee'],
        'priority': 'high',
        'data': employeeData,
      });
    }

    // Employees with many active checkouts (more than 5)
    for (var employee in _employees) {
      if (employee.isActive) {
        List<EquipmentCheckout> activeCheckouts = getEmployeeActiveCheckouts(employee.id);
        if (activeCheckouts.length > 5) {
          alerts.add({
            'type': 'many_active_checkouts',
            'title': 'Many Active Checkouts',
            'message': '${employee.fullName} has ${activeCheckouts.length} active checkouts',
            'employee': employee,
            'priority': 'medium',
            'data': {'activeCheckouts': activeCheckouts},
          });
        }
      }
    }

    // Sort by priority: high > medium > low
    alerts.sort((a, b) {
      Map<String, int> priorityOrder = {'high': 2, 'medium': 1, 'low': 0};
      return priorityOrder[b['priority']]!.compareTo(priorityOrder[a['priority']]!);
    });

    return alerts;
  }

  /// Get alert count for employees
  int getEmployeeAlertCount() {
    return getEmployeesRequiringAttention().length;
  }

  // ==================== VALIDATION ====================

  /// Validate employee email
  bool isEmailAvailable(String email, {String? excludeEmployeeId}) {
    return !_employees.any((employee) =>
    employee.email.toLowerCase() == email.toLowerCase() &&
        employee.id != excludeEmployeeId);
  }

  /// Validate employee data
  Map<String, String?> validateEmployeeData({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    String? employeeId,
  }) {
    Map<String, String?> errors = {};

    // Validate full name
    if (fullName.trim().isEmpty) {
      errors['fullName'] = 'Full name is required';
    } else if (fullName.trim().length < 2) {
      errors['fullName'] = 'Full name must be at least 2 characters';
    }

    // Validate email
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors['email'] = 'Please enter a valid email address';
    } else if (!isEmailAvailable(email, excludeEmployeeId: employeeId)) {
      errors['email'] = 'This email is already in use';
    }

    // Validate phone
    if (phone.trim().isEmpty) {
      errors['phone'] = 'Phone number is required';
    } else if (phone.replaceAll(RegExp(r'[\s\-\(\)]'), '').length < 10) {
      errors['phone'] = 'Please enter a valid phone number';
    }

    // Validate address
    if (address.trim().isEmpty) {
      errors['address'] = 'Address is required';
    } else if (address.trim().length < 10) {
      errors['address'] = 'Please enter a complete address';
    }

    return errors;
  }

  // ==================== SEARCH & FILTER ====================

  /// Filter employees by status
  List<UserModel> filterEmployeesByStatus(bool isActive) {
    return _employees.where((employee) => employee.isActive == isActive).toList();
  }

  /// Get employees with active checkouts
  List<UserModel> getEmployeesWithActiveCheckouts() {
    Set<String> employeeIds = _equipmentCheckouts
        .where((checkout) => checkout.status == 'checked_out')
        .map((checkout) => checkout.employeeId)
        .toSet();

    return _employees.where((employee) => employeeIds.contains(employee.id)).toList();
  }

  /// Get employees without active checkouts
  List<UserModel> getEmployeesWithoutActiveCheckouts() {
    Set<String> employeeIds = _equipmentCheckouts
        .where((checkout) => checkout.status == 'checked_out')
        .map((checkout) => checkout.employeeId)
        .toSet();

    return _employees.where((employee) =>
    !employeeIds.contains(employee.id) && employee.isActive).toList();
  }

  // ==================== LOAD ALL DATA ====================

  /// Load all employee-related data
  Future<void> loadAllEmployeeData() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        loadEmployees(),
        loadAllActiveCheckouts(),
      ]);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==================== HELPER METHODS ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  /// Dispose method
  @override
  void dispose() {
    super.dispose();
  }
}