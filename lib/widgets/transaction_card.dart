import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/category_provider.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final category = categoryProvider.categories
            .where((c) => c.id == transaction.categoryId)
            .firstOrNull;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Category Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category?.name).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(category?.name),
                        color: _getCategoryColor(category?.name),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Transaction Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category?.name ?? 'Unknown Category',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                transaction.formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.note,
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transaction.type == TransactionType.income
                              ? '+${transaction.formattedAmount}'
                              : '-${transaction.formattedAmount}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: transaction.type == TransactionType.income
                                ? const Color(0xFF4CAF50)
                                : Colors.red,
                          ),
                        ),
                        if (transaction.notes != null && transaction.notes!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              transaction.notes!.length > 15
                                  ? '${transaction.notes!.substring(0, 15)}...'
                                  : transaction.notes!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.category;
    
    switch (categoryName.toLowerCase()) {
      case 'salary':
      case 'income':
        return Icons.work;
      case 'rent':
      case 'housing':
        return Icons.home;
      case 'food':
      case 'groceries':
        return Icons.restaurant;
      case 'transport':
      case 'matatu':
        return Icons.directions_bus;
      case 'utilities':
        return Icons.lightbulb;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'health':
      case 'medical':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'fuel':
      case 'gas':
        return Icons.local_gas_station;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null) return Colors.grey;
    
    switch (categoryName.toLowerCase()) {
      case 'salary':
      case 'income':
        return const Color(0xFF4CAF50);
      case 'rent':
      case 'housing':
        return const Color(0xFF2196F3);
      case 'food':
      case 'groceries':
        return const Color(0xFFFF9800);
      case 'transport':
      case 'matatu':
        return const Color(0xFF9C27B0);
      case 'utilities':
        return const Color(0xFFFFEB3B);
      case 'entertainment':
        return const Color(0xFFE91E63);
      case 'shopping':
        return const Color(0xFF795548);
      case 'health':
      case 'medical':
        return const Color(0xFFF44336);
      case 'education':
        return const Color(0xFF607D8B);
      case 'fuel':
      case 'gas':
        return const Color(0xFF3F51B5);
      default:
        return Colors.grey;
    }
  }
}
