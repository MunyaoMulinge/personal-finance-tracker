import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/models/models.dart';
import 'package:personal_finance_tracker/providers/auth_provider.dart';

void main() {
  group('Authentication Tests', () {
    test('Category model serialization works correctly', () {
      final category = Category(
        id: 1,
        userId: 'test-user-id',
        name: 'Food',
      );

      final json = category.toJson();
      expect(json['id'], 1);
      expect(json['user_id'], 'test-user-id');
      expect(json['name'], 'Food');

      final categoryFromJson = Category.fromJson(json);
      expect(categoryFromJson.id, category.id);
      expect(categoryFromJson.userId, category.userId);
      expect(categoryFromJson.name, category.name);
    });

    test('Transaction model serialization works correctly', () {
      final transaction = Transaction(
        id: 1,
        userId: 'test-user-id',
        type: TransactionType.expense,
        amount: 1500.50,
        categoryId: 1,
        date: DateTime(2025, 1, 15),
        notes: 'Lunch at restaurant',
      );

      final json = transaction.toJson();
      expect(json['id'], 1);
      expect(json['user_id'], 'test-user-id');
      expect(json['type'], 'Expense');
      expect(json['amount'], 1500.50);
      expect(json['category_id'], 1);
      expect(json['notes'], 'Lunch at restaurant');

      final transactionFromJson = Transaction.fromJson(json);
      expect(transactionFromJson.id, transaction.id);
      expect(transactionFromJson.userId, transaction.userId);
      expect(transactionFromJson.type, transaction.type);
      expect(transactionFromJson.amount, transaction.amount);
      expect(transactionFromJson.categoryId, transaction.categoryId);
      expect(transactionFromJson.notes, transaction.notes);
    });

    test('Transaction formatted amount shows KSh currency', () {
      final transaction = Transaction(
        type: TransactionType.expense,
        amount: 1500.50,
        categoryId: 1,
        date: DateTime.now(),
      );

      expect(transaction.formattedAmount, contains('KSh'));
      expect(transaction.formattedAmount, contains('1,500.50'));
    });

    test('Default categories are available', () {
      final defaultCategories = Category.defaultCategories;
      expect(defaultCategories.length, 5);
      expect(defaultCategories.any((cat) => cat.name == 'Salary'), true);
      expect(defaultCategories.any((cat) => cat.name == 'Food'), true);
      expect(defaultCategories.any((cat) => cat.name == 'Rent'), true);
    });

    // Note: AuthProvider test requires Supabase initialization
    // This would be tested in integration tests with proper setup
  });
}
