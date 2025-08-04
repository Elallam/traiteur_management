import 'package:cloud_firestore/cloud_firestore.dart';

class CashTransactionModel {
  final String id;
  final String operationName;
  final double amount;
  final String type; // 'deposit' or 'withdraw'
  final DateTime date;
  final String? description;
  final String? userId;
  final String? userName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  CashTransactionModel({
    required this.id,
    required this.operationName,
    required this.amount,
    required this.type,
    required this.date,
    this.description,
    this.userId,
    this.userName,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory CashTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return CashTransactionModel(
      id: id,
      operationName: map['operationName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'deposit',
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'],
      userId: map['userId'],
      userName: map['userName'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'operationName': operationName,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'description': description,
      'userId': userId,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  CashTransactionModel copyWith({
    String? id,
    String? operationName,
    double? amount,
    String? type,
    DateTime? date,
    String? description,
    String? userId,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CashTransactionModel(
      id: id ?? this.id,
      operationName: operationName ?? this.operationName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isDeposit => type == 'deposit';
  bool get isWithdraw => type == 'withdraw';
}

class CashRegisterSummary {
  final double totalDeposits;
  final double totalWithdrawals;
  final double balance;
  final int totalTransactions;
  final int depositsCount;
  final int withdrawalsCount;
  final DateTime? lastTransactionDate;

  CashRegisterSummary({
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.balance,
    required this.totalTransactions,
    required this.depositsCount,
    required this.withdrawalsCount,
    this.lastTransactionDate,
  });

  factory CashRegisterSummary.empty() {
    return CashRegisterSummary(
      totalDeposits: 0.0,
      totalWithdrawals: 0.0,
      balance: 0.0,
      totalTransactions: 0,
      depositsCount: 0,
      withdrawalsCount: 0,
    );
  }
}