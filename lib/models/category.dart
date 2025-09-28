class Category {
  final int? id;
  final String? userId;
  final String name;

  Category({this.id, this.userId, required this.name});

  // Factory constructor for creating a Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
    );
  }

  // Method to convert Category to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'user_id': userId, 'name': name};
  }

  // Method to convert Category to JSON for insertion (without id)
  Map<String, dynamic> toInsertJson() {
    return {'user_id': userId, 'name': name};
  }

  // Copy with method for creating modified copies
  Category copyWith({int? id, String? userId, String? name}) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, userId: $userId, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.userId == userId &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ name.hashCode;
  }

  // Default categories that should be available to all users
  static List<Category> get defaultCategories => [
    Category(name: 'Salary'),
    Category(name: 'Rent'),
    Category(name: 'Food'),
    Category(name: 'Transport'),
    Category(name: 'Utilities'),
  ];
}
