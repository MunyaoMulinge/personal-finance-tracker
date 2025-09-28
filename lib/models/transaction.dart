import 'package:intl/intl.dart';

enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final String? userId;
  final TransactionType type;
  final double amount;
  final int categoryId;
  final DateTime date;
  final String? notes;

  Transaction({
    this.id,
    this.userId,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.notes,
  });

  // Factory constructor for creating a Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      userId: json['user_id'] as String?,
      type: _parseTransactionType(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'] as int,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }

  // Method to convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': _transactionTypeToString(type),
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  // Method to convert Transaction to JSON for insertion (without id)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'type': _transactionTypeToString(type),
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  // Copy with method for creating modified copies
  Transaction copyWith({
    int? id,
    String? userId,
    TransactionType? type,
    double? amount,
    int? categoryId,
    DateTime? date,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  // Helper method to parse transaction type from string
  static TransactionType _parseTransactionType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        throw ArgumentError('Invalid transaction type: $typeString');
    }
  }

  // Helper method to convert transaction type to string
  static String _transactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  // Formatted amount with KSh currency
  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'KSh ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Formatted date
  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Formatted date and time
  String get formattedDateTime {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  @override
  String toString() {
    return 'Transaction{id: $id, userId: $userId, type: $type, amount: $amount, categoryId: $categoryId, date: $date, notes: $notes}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.amount == amount &&
        other.categoryId == categoryId &&
        other.date == date &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        type.hashCode ^
        amount.hashCode ^
        categoryId.hashCode ^
        date.hashCode ^
        notes.hashCode;
  }
}
