package com.kenyafinance.tracker.repository;

import com.kenyafinance.tracker.entity.Category;
import com.kenyafinance.tracker.entity.Transaction;
import com.kenyafinance.tracker.entity.TransactionType;
import com.kenyafinance.tracker.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    
    /**
     * Find all transactions for a user with pagination
     */
    Page<Transaction> findByUserOrderByTransactionDateDesc(User user, Pageable pageable);
    
    /**
     * Find transactions by user and type
     */
    List<Transaction> findByUserAndTypeOrderByTransactionDateDesc(User user, TransactionType type);
    
    /**
     * Find transactions by user and category
     */
    List<Transaction> findByUserAndCategoryOrderByTransactionDateDesc(User user, Category category);
    
    /**
     * Find transactions within date range
     */
    @Query("SELECT t FROM Transaction t WHERE t.user = :user AND t.transactionDate BETWEEN :startDate AND :endDate ORDER BY t.transactionDate DESC")
    List<Transaction> findByUserAndDateRange(@Param("user") User user, 
                                           @Param("startDate") LocalDateTime startDate, 
                                           @Param("endDate") LocalDateTime endDate);
    
    /**
     * Calculate total income for user
     */
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.user = :user AND t.type = 'INCOME'")
    BigDecimal calculateTotalIncomeByUser(@Param("user") User user);
    
    /**
     * Calculate total expenses for user
     */
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.user = :user AND t.type = 'EXPENSE'")
    BigDecimal calculateTotalExpensesByUser(@Param("user") User user);
    
    /**
     * Calculate total income for user within date range
     */
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.user = :user AND t.type = 'INCOME' AND t.transactionDate BETWEEN :startDate AND :endDate")
    BigDecimal calculateIncomeByUserAndDateRange(@Param("user") User user, 
                                               @Param("startDate") LocalDateTime startDate, 
                                               @Param("endDate") LocalDateTime endDate);
    
    /**
     * Calculate total expenses for user within date range
     */
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.user = :user AND t.type = 'EXPENSE' AND t.transactionDate BETWEEN :startDate AND :endDate")
    BigDecimal calculateExpensesByUserAndDateRange(@Param("user") User user, 
                                                 @Param("startDate") LocalDateTime startDate, 
                                                 @Param("endDate") LocalDateTime endDate);
    
    /**
     * Get spending by category for user
     */
    @Query("SELECT t.category, SUM(t.amount) FROM Transaction t WHERE t.user = :user AND t.type = 'EXPENSE' GROUP BY t.category ORDER BY SUM(t.amount) DESC")
    List<Object[]> getSpendingByCategory(@Param("user") User user);
    
    /**
     * Get recent transactions for user
     */
    @Query("SELECT t FROM Transaction t WHERE t.user = :user ORDER BY t.transactionDate DESC")
    List<Transaction> findRecentTransactionsByUser(@Param("user") User user, Pageable pageable);
    
    /**
     * Count transactions for user
     */
    long countByUser(User user);
    
    /**
     * Find transactions by multiple criteria
     */
    @Query("SELECT t FROM Transaction t WHERE t.user = :user " +
           "AND (:type IS NULL OR t.type = :type) " +
           "AND (:category IS NULL OR t.category = :category) " +
           "AND (:startDate IS NULL OR t.transactionDate >= :startDate) " +
           "AND (:endDate IS NULL OR t.transactionDate <= :endDate) " +
           "ORDER BY t.transactionDate DESC")
    Page<Transaction> findTransactionsByCriteria(@Param("user") User user,
                                               @Param("type") TransactionType type,
                                               @Param("category") Category category,
                                               @Param("startDate") LocalDateTime startDate,
                                               @Param("endDate") LocalDateTime endDate,
                                               Pageable pageable);
}
