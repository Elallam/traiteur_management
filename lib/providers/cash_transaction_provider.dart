import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cash_transaction_model.dart';
import '../services/firestore_service.dart';

class CashTransactionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CashTransactionModel> _transactions = [];
  CashRegisterSummary _summary = CashRegisterSummary.empty();
  bool _isLoading = false;
  String? _error;

  CashTransactionProvider();

  // Getters
  List<CashTransactionModel> get transactions => _transactions;
  CashRegisterSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all data
  Future<void> loadData() async {
    _setLoading(true);
    try {
      print("Loading data: $_isLoading");
      final transactions = await _firestoreService.getCashTransactions();
      final summary = await _firestoreService.getCashRegisterSummary();
      _updateState(transactions, summary, error: null);
      print("Finish Loading: $_isLoading");
    } catch (e) {
      _updateState([], CashRegisterSummary.empty(), error: e.toString());
    }
  }

  // Add transaction
  Future<void> addTransaction(CashTransactionModel transaction) async {
    _setLoading(true);
    try {
      // Add to Firestore and get the returned ID
      final transactionId = await _firestoreService.addCashTransaction(transaction);

      // Create the transaction with the proper ID from Firestore
      final savedTransaction = transaction.copyWith(id: transactionId);

      // Add to local state with the correct ID
      _transactions.insert(0, savedTransaction);
      _updateSummary();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Update transaction
  Future<void> updateTransaction(CashTransactionModel transaction) async {
    _setLoading(true);
    try {
      await _firestoreService.updateCashTransaction(transaction);
      // Update local state
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        _updateSummary();
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteCashTransaction(transactionId);
      // Remove from local state
      _transactions.removeWhere((t) => t.id == transactionId);
      _updateSummary();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Alternative approach: Reload data after operations (more reliable but slower)
  Future<void> addTransactionAndReload(CashTransactionModel transaction) async {
    _setLoading(true);
    try {
      await _firestoreService.addCashTransaction(transaction);
      // Reload all data to ensure consistency
      await loadData();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateTransactionAndReload(CashTransactionModel transaction) async {
    _setLoading(true);
    try {
      await _firestoreService.updateCashTransaction(transaction);
      // Reload all data to ensure consistency
      await loadData();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteTransactionAndReload(String transactionId) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteCashTransaction(transactionId);
      // Reload all data to ensure consistency
      await loadData();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _updateState(List<CashTransactionModel> transactions, CashRegisterSummary summary, {String? error}) {
    _transactions = transactions;
    _summary = summary;
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _updateSummary() {
    double totalDeposits = 0.0;
    double totalWithdrawals = 0.0;
    int depositsCount = 0;
    int withdrawalsCount = 0;
    DateTime? lastTransactionDate;

    for (var transaction in _transactions) {
      if (transaction.isDeposit) {
        totalDeposits += transaction.amount;
        depositsCount++;
      } else {
        totalWithdrawals += transaction.amount;
        withdrawalsCount++;
      }

      if (lastTransactionDate == null || transaction.date.isAfter(lastTransactionDate)) {
        lastTransactionDate = transaction.date;
      }
    }

    _summary = CashRegisterSummary(
      totalDeposits: totalDeposits,
      totalWithdrawals: totalWithdrawals,
      balance: totalDeposits - totalWithdrawals,
      totalTransactions: _transactions.length,
      depositsCount: depositsCount,
      withdrawalsCount: withdrawalsCount,
      lastTransactionDate: lastTransactionDate,
    );
  }
}