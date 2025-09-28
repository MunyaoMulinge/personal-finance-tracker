package com.kenyafinance.tracker.dto;

import java.math.BigDecimal;
import java.util.List;

public class DashboardSummaryDto {
    
    private BigDecimal totalIncome;
    private BigDecimal totalExpenses;
    private BigDecimal balance;
    private long totalTransactions;
    private List<CategorySpendingDto> categorySpending;
    private List<TransactionDto> recentTransactions;
    
    // Constructors
    public DashboardSummaryDto() {}
    
    public DashboardSummaryDto(BigDecimal totalIncome, BigDecimal totalExpenses, 
                              BigDecimal balance, long totalTransactions) {
        this.totalIncome = totalIncome;
        this.totalExpenses = totalExpenses;
        this.balance = balance;
        this.totalTransactions = totalTransactions;
    }
    
    // Getters and Setters
    public BigDecimal getTotalIncome() {
        return totalIncome;
    }
    
    public void setTotalIncome(BigDecimal totalIncome) {
        this.totalIncome = totalIncome;
    }
    
    public BigDecimal getTotalExpenses() {
        return totalExpenses;
    }
    
    public void setTotalExpenses(BigDecimal totalExpenses) {
        this.totalExpenses = totalExpenses;
    }
    
    public BigDecimal getBalance() {
        return balance;
    }
    
    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }
    
    public long getTotalTransactions() {
        return totalTransactions;
    }
    
    public void setTotalTransactions(long totalTransactions) {
        this.totalTransactions = totalTransactions;
    }
    
    public List<CategorySpendingDto> getCategorySpending() {
        return categorySpending;
    }
    
    public void setCategorySpending(List<CategorySpendingDto> categorySpending) {
        this.categorySpending = categorySpending;
    }
    
    public List<TransactionDto> getRecentTransactions() {
        return recentTransactions;
    }
    
    public void setRecentTransactions(List<TransactionDto> recentTransactions) {
        this.recentTransactions = recentTransactions;
    }
    
    // Nested class for category spending
    public static class CategorySpendingDto {
        private CategoryDto category;
        private BigDecimal amount;
        private Double percentage;
        
        public CategorySpendingDto() {}
        
        public CategorySpendingDto(CategoryDto category, BigDecimal amount, Double percentage) {
            this.category = category;
            this.amount = amount;
            this.percentage = percentage;
        }
        
        public CategoryDto getCategory() {
            return category;
        }
        
        public void setCategory(CategoryDto category) {
            this.category = category;
        }
        
        public BigDecimal getAmount() {
            return amount;
        }
        
        public void setAmount(BigDecimal amount) {
            this.amount = amount;
        }
        
        public Double getPercentage() {
            return percentage;
        }
        
        public void setPercentage(Double percentage) {
            this.percentage = percentage;
        }
    }
}
