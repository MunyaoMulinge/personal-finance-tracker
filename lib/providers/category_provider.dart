import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/category.dart' as model;
import '../services/category_service.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryProvider extends ChangeNotifier {
  CategoryStatus _status = CategoryStatus.initial;
  List<model.Category> _categories = <model.Category>[];
  List<model.Category> _userCategories = <model.Category>[];
  List<model.Category> _defaultCategories = <model.Category>[];
  String? _errorMessage;

  CategoryStatus get status => _status;
  List<model.Category> get categories => _categories;
  List<model.Category> get userCategories => _userCategories;
  List<model.Category> get defaultCategories => _defaultCategories;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CategoryStatus.loading;

  // Load all categories
  Future<void> loadCategories() async {
    try {
      _setLoading();
      
      final categories = await CategoryService.getCategories();
      _categories = categories;
      
      // Separate user and default categories
      _userCategories = categories.where((c) => c.userId != null).toList();
      _defaultCategories = categories.where((c) => c.userId == null).toList();

      _status = CategoryStatus.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load user categories only
  Future<void> loadUserCategories() async {
    try {
      final userCategories = await CategoryService.getUserCategories();
      _userCategories = userCategories;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load default categories only
  Future<void> loadDefaultCategories() async {
    try {
      final defaultCategories = await CategoryService.getDefaultCategories();
      _defaultCategories = defaultCategories;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Create a new category
  Future<bool> createCategory(model.Category category) async {
    try {
      _setLoading();
      
      // Check if name already exists
      final nameExists = await CategoryService.categoryNameExists(category.name);
      if (nameExists) {
        _setError('A category with this name already exists');
        return false;
      }

      final newCategory = await CategoryService.createCategory(category);
      
      // Add to the lists
      _categories.add(newCategory);
      _userCategories.add(newCategory);

      _status = CategoryStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update an existing category
  Future<bool> updateCategory(model.Category category) async {
    try {
      _setLoading();
      
      // Check if name already exists (excluding current category)
      final nameExists = await CategoryService.categoryNameExists(
        category.name,
        excludeId: category.id,
      );
      if (nameExists) {
        _setError('A category with this name already exists');
        return false;
      }

      final updatedCategory = await CategoryService.updateCategory(category);
      
      // Update in the lists
      final allIndex = _categories.indexWhere((c) => c.id == category.id);
      if (allIndex != -1) {
        _categories[allIndex] = updatedCategory;
      }

      final userIndex = _userCategories.indexWhere((c) => c.id == category.id);
      if (userIndex != -1) {
        _userCategories[userIndex] = updatedCategory;
      }

      _status = CategoryStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(int categoryId) async {
    try {
      _setLoading();
      
      await CategoryService.deleteCategory(categoryId);
      
      // Remove from the lists
      _categories.removeWhere((c) => c.id == categoryId);
      _userCategories.removeWhere((c) => c.id == categoryId);

      _status = CategoryStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get category by ID
  Future<model.Category?> getCategoryById(int categoryId) async {
    try {
      return await CategoryService.getCategoryById(categoryId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Check if category name exists
  Future<bool> categoryNameExists(String name, {int? excludeId}) async {
    try {
      return await CategoryService.categoryNameExists(name, excludeId: excludeId);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get category usage count
  Future<int> getCategoryUsageCount(int categoryId) async {
    try {
      return await CategoryService.getCategoryUsageCount(categoryId);
    } catch (e) {
      _setError(e.toString());
      return 0;
    }
  }

  // Get category by name
  model.Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Search categories
  List<model.Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    return _categories.where((c) =>
      c.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Refresh categories
  Future<void> refresh() async {
    await loadCategories();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = CategoryStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = CategoryStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
