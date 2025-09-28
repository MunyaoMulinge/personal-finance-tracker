package com.kenyafinance.tracker.service;

import com.kenyafinance.tracker.dto.CategoryDto;
import com.kenyafinance.tracker.dto.DashboardSummaryDto;
import com.kenyafinance.tracker.dto.TransactionDto;
import com.kenyafinance.tracker.entity.Category;
import com.kenyafinance.tracker.entity.Transaction;
import com.kenyafinance.tracker.entity.TransactionType;
import com.kenyafinance.tracker.entity.User;
import com.kenyafinance.tracker.repository.CategoryRepository;
import com.kenyafinance.tracker.repository.TransactionRepository;
import com.kenyafinance.tracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class TransactionService {
    
    private final TransactionRepository transactionRepository;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    
    @Autowired
    public TransactionService(TransactionRepository transactionRepository, 
                            UserRepository userRepository,
                            CategoryRepository categoryRepository) {
        this.transactionRepository = transactionRepository;
        this.userRepository = userRepository;
        this.categoryRepository = categoryRepository;
    }
    
    /**
     * Create a new transaction
     */
    public TransactionDto createTransaction(UUID userId, TransactionDto transactionDto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        Category category = categoryRepository.findById(transactionDto.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + transactionDto.getCategoryId()));
        
        Transaction transaction = convertToEntity(transactionDto);
        transaction.setUser(user);
        transaction.setCategory(category);
        
        Transaction savedTransaction = transactionRepository.save(transaction);
        return convertToDto(savedTransaction);
    }
    
    /**
     * Get transactions for user with pagination
     */
    @Transactional(readOnly = true)
    public Page<TransactionDto> getTransactionsForUser(UUID userId, Pageable pageable) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        return transactionRepository.findByUserOrderByTransactionDateDesc(user, pageable)
                .map(this::convertToDto);
    }
    
    /**
     * Get transaction by ID
     */
    @Transactional(readOnly = true)
    public Optional<TransactionDto> getTransactionById(Long id) {
        return transactionRepository.findById(id)
                .map(this::convertToDto);
    }
    
    /**
     * Update transaction
     */
    public TransactionDto updateTransaction(UUID userId, Long transactionId, TransactionDto transactionDto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        Transaction existingTransaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + transactionId));
        
        // Check if user owns this transaction
        if (!existingTransaction.getUser().getId().equals(userId)) {
            throw new RuntimeException("Cannot update this transaction");
        }
        
        Category category = categoryRepository.findById(transactionDto.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + transactionDto.getCategoryId()));
        
        // Update fields
        existingTransaction.setType(transactionDto.getType());
        existingTransaction.setAmount(transactionDto.getAmount());
        existingTransaction.setNotes(transactionDto.getNotes());
        existingTransaction.setTransactionDate(transactionDto.getTransactionDate());
        existingTransaction.setCategory(category);
        
        Transaction updatedTransaction = transactionRepository.save(existingTransaction);
        return convertToDto(updatedTransaction);
    }
    
    /**
     * Delete transaction
     */
    public void deleteTransaction(UUID userId, Long transactionId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + transactionId));
        
        // Check if user owns this transaction
        if (!transaction.getUser().getId().equals(userId)) {
            throw new RuntimeException("Cannot delete this transaction");
        }
        
        transactionRepository.delete(transaction);
    }
    
    /**
     * Get dashboard summary for user
     */
    @Transactional(readOnly = true)
    public DashboardSummaryDto getDashboardSummary(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        BigDecimal totalIncome = transactionRepository.calculateTotalIncomeByUser(user);
        BigDecimal totalExpenses = transactionRepository.calculateTotalExpensesByUser(user);
        BigDecimal balance = totalIncome.subtract(totalExpenses);
        long totalTransactions = transactionRepository.countByUser(user);
        
        // Get recent transactions (last 5)
        List<TransactionDto> recentTransactions = transactionRepository
                .findRecentTransactionsByUser(user, PageRequest.of(0, 5))
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
        
        // Get category spending
        List<DashboardSummaryDto.CategorySpendingDto> categorySpending = getCategorySpending(user, totalExpenses);
        
        DashboardSummaryDto summary = new DashboardSummaryDto(totalIncome, totalExpenses, balance, totalTransactions);
        summary.setRecentTransactions(recentTransactions);
        summary.setCategorySpending(categorySpending);
        
        return summary;
    }
    
    /**
     * Get category spending breakdown
     */
    private List<DashboardSummaryDto.CategorySpendingDto> getCategorySpending(User user, BigDecimal totalExpenses) {
        List<Object[]> spendingData = transactionRepository.getSpendingByCategory(user);
        
        return spendingData.stream()
                .map(data -> {
                    Category category = (Category) data[0];
                    BigDecimal amount = (BigDecimal) data[1];
                    Double percentage = totalExpenses.compareTo(BigDecimal.ZERO) > 0 ? 
                            amount.divide(totalExpenses, 4, RoundingMode.HALF_UP)
                                  .multiply(BigDecimal.valueOf(100))
                                  .doubleValue() : 0.0;
                    
                    CategoryDto categoryDto = convertCategoryToDto(category);
                    return new DashboardSummaryDto.CategorySpendingDto(categoryDto, amount, percentage);
                })
                .collect(Collectors.toList());
    }
    
    /**
     * Convert Transaction Entity to DTO
     */
    private TransactionDto convertToDto(Transaction transaction) {
        TransactionDto dto = new TransactionDto();
        dto.setId(transaction.getId());
        dto.setType(transaction.getType());
        dto.setAmount(transaction.getAmount());
        dto.setNotes(transaction.getNotes());
        dto.setTransactionDate(transaction.getTransactionDate());
        dto.setCategoryId(transaction.getCategory().getId());
        dto.setCategory(convertCategoryToDto(transaction.getCategory()));
        dto.setCreatedAt(transaction.getCreatedAt());
        dto.setUpdatedAt(transaction.getUpdatedAt());
        return dto;
    }
    
    /**
     * Convert DTO to Transaction Entity
     */
    private Transaction convertToEntity(TransactionDto dto) {
        Transaction transaction = new Transaction();
        transaction.setId(dto.getId());
        transaction.setType(dto.getType());
        transaction.setAmount(dto.getAmount());
        transaction.setNotes(dto.getNotes());
        transaction.setTransactionDate(dto.getTransactionDate());
        return transaction;
    }
    
    /**
     * Convert Category Entity to DTO
     */
    private CategoryDto convertCategoryToDto(Category category) {
        CategoryDto dto = new CategoryDto();
        dto.setId(category.getId());
        dto.setName(category.getName());
        dto.setDescription(category.getDescription());
        dto.setIconName(category.getIconName());
        dto.setColorCode(category.getColorCode());
        dto.setIsDefault(category.getIsDefault());
        dto.setIsActive(category.getIsActive());
        dto.setCreatedAt(category.getCreatedAt());
        dto.setUpdatedAt(category.getUpdatedAt());
        return dto;
    }
}
