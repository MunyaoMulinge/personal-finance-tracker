import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/transaction_service.dart';

enum TransactionStatus { initial, loading, loaded, error }

class TransactionProvider extends ChangeNotifier {
  TransactionStatus _status = TransactionStatus.initial;
  List<Transaction> _transactions = [];
  Map<String, double> _summary = {};
  Map<String, double> _categorySpending = {};
  String? _errorMessage;

  TransactionStatus get status => _status;
  List<Transaction> get transactions => _transactions;
  Map<String, double> get summary => _summary;
  Map<String, double> get categorySpending => _categorySpending;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TransactionStatus.loading;

  // Get total income
  double get totalIncome => _summary['income'] ?? 0.0;

  // Get total expenses
  double get totalExpenses => _summary['expenses'] ?? 0.0;

  // Get balance
  double get balance => _summary['balance'] ?? 0.0;

  // Get recent transactions (last 10)
  List<Transaction> get recentTransactions => 
      _transactions.take(10).toList();

  // Load all transactions
  Future<void> loadTransactions({
    int? limit,
    int? offset,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setLoading();
      
      final transactions = await TransactionService.getTransactions(
        limit: limit,
        offset: offset,
        categoryId: categoryId,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      _transactions = transactions;
      _status = TransactionStatus.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load transaction summary
  Future<void> loadSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final summary = await TransactionService.getTransactionSummary(
        startDate: startDate,
        endDate: endDate,
      );

      _summary = summary;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load category spending
  Future<void> loadCategorySpending({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final categorySpending = await TransactionService.getSpendingByCategory(
        startDate: startDate,
        endDate: endDate,
      );

      _categorySpending = categorySpending;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Create a new transaction
  Future<bool> createTransaction(Transaction transaction) async {
    try {
      _setLoading();
      
      final newTransaction = await TransactionService.createTransaction(transaction);
      
      // Add to the beginning of the list
      _transactions.insert(0, newTransaction);
      
      // Reload summary and category spending
      await Future.wait([
        loadSummary(),
        loadCategorySpending(),
      ]);

      _status = TransactionStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update an existing transaction
  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      _setLoading();
      
      final updatedTransaction = await TransactionService.updateTransaction(transaction);
      
      // Update in the list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
      }

      // Reload summary and category spending
      await Future.wait([
        loadSummary(),
        loadCategorySpending(),
      ]);

      _status = TransactionStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Delete a transaction
  Future<bool> deleteTransaction(int transactionId) async {
    try {
      _setLoading();
      
      await TransactionService.deleteTransaction(transactionId);
      
      // Remove from the list
      _transactions.removeWhere((t) => t.id == transactionId);

      // Reload summary and category spending
      await Future.wait([
        loadSummary(),
        loadCategorySpending(),
      ]);

      _status = TransactionStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get transaction by ID
  Future<Transaction?> getTransactionById(int transactionId) async {
    try {
      return await TransactionService.getTransactionById(transactionId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadTransactions(),
      loadSummary(),
      loadCategorySpending(),
    ]);
  }

  // Filter transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Filter transactions by category
  List<Transaction> getTransactionsByCategory(int categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = TransactionStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = TransactionStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
