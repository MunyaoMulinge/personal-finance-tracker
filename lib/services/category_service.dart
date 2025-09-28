import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';
import 'auth_service.dart';

class CategoryService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Get all categories (default + user-created)
  static Future<List<Category>> getCategories() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('categories')
          .select()
          .or('user_id.is.null,user_id.eq.$userId')
          .order('name');

      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get user-created categories only
  static Future<List<Category>> getUserCategories() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('name');

      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get default categories only
  static Future<List<Category>> getDefaultCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('name');

      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create a new user category
  static Future<Category> createCategory(Category category) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final categoryData = category.copyWith(userId: userId).toInsertJson();
      
      final response = await _client
          .from('categories')
          .insert(categoryData)
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing user category
  static Future<Category> updateCategory(Category category) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      if (category.id == null) {
        throw Exception('Category ID is required for update');
      }

      // Only allow updating user-created categories
      if (category.userId == null) {
        throw Exception('Cannot update default categories');
      }

      final categoryData = {'name': category.name};

      final response = await _client
          .from('categories')
          .update(categoryData)
          .eq('id', category.id!)
          .eq('user_id', userId)
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a user category
  static Future<void> deleteCategory(int categoryId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Check if category is being used in transactions
      final transactionCount = await _client
          .from('transactions')
          .select('id')
          .eq('category_id', categoryId)
          .eq('user_id', userId);

      if (transactionCount.isNotEmpty) {
        throw Exception('Cannot delete category that is being used in transactions');
      }

      // Only allow deleting user-created categories
      await _client
          .from('categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Get category by ID
  static Future<Category?> getCategoryById(int categoryId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('categories')
          .select()
          .eq('id', categoryId)
          .or('user_id.is.null,user_id.eq.$userId')
          .maybeSingle();

      if (response == null) return null;
      return Category.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Check if category name already exists for user
  static Future<bool> categoryNameExists(String name, {int? excludeId}) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client
          .from('categories')
          .select('id')
          .ilike('name', name)
          .or('user_id.is.null,user_id.eq.$userId');

      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }

      final response = await query;
      return response.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  // Get category usage count (number of transactions using this category)
  static Future<int> getCategoryUsageCount(int categoryId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('transactions')
          .select('id')
          .eq('category_id', categoryId)
          .eq('user_id', userId);

      return response.length;
    } catch (e) {
      rethrow;
    }
  }
}
