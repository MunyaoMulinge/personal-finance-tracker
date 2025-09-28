import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';
import 'auth_service.dart';

class TransactionService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Get all transactions for the current user
  static Future<List<Transaction>> getTransactions({
    int? limit,
    int? offset,
    String? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(limit ?? 50);
      
      return (response as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create a new transaction
  static Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final transactionData = transaction.copyWith(userId: userId).toInsertJson();
      
      final response = await _client
          .from('transactions')
          .insert(transactionData)
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing transaction
  static Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      if (transaction.id == null) {
        throw Exception('Transaction ID is required for update');
      }

      final transactionData = transaction.toJson();
      transactionData.remove('id'); // Don't update the ID
      transactionData.remove('user_id'); // Don't update user_id

      final response = await _client
          .from('transactions')
          .update(transactionData)
          .eq('id', transaction.id!)
          .eq('user_id', userId)
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a transaction
  static Future<void> deleteTransaction(int transactionId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('transactions')
          .delete()
          .eq('id', transactionId)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Get transaction by ID
  static Future<Transaction?> getTransactionById(int transactionId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Transaction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get transaction summary (total income, total expenses)
  static Future<Map<String, double>> getTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client
          .from('transactions')
          .select('type, amount')
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }

      final response = await query;
      
      double totalIncome = 0;
      double totalExpenses = 0;

      for (final transaction in response) {
        final amount = (transaction['amount'] as num).toDouble();
        if (transaction['type'] == 'Income') {
          totalIncome += amount;
        } else {
          totalExpenses += amount;
        }
      }

      return {
        'income': totalIncome,
        'expenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Get spending by category
  static Future<Map<String, double>> getSpendingByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client
          .from('transactions')
          .select('amount, category_id, categories(name)')
          .eq('user_id', userId)
          .eq('type', 'Expense');

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }

      final response = await query;
      
      final Map<String, double> categorySpending = {};

      for (final transaction in response) {
        final amount = (transaction['amount'] as num).toDouble();
        final categoryName = transaction['categories']['name'] as String;
        
        categorySpending[categoryName] = (categorySpending[categoryName] ?? 0) + amount;
      }

      return categorySpending;
    } catch (e) {
      rethrow;
    }
  }
}
