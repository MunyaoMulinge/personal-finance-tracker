package com.kenyafinance.tracker.controller;

import com.kenyafinance.tracker.dto.DashboardSummaryDto;
import com.kenyafinance.tracker.dto.TransactionDto;
import com.kenyafinance.tracker.service.TransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/transactions")
@Tag(name = "Transaction Management", description = "APIs for managing financial transactions")
@CrossOrigin(origins = "*")
public class TransactionController {
    
    private final TransactionService transactionService;
    
    @Autowired
    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }
    
    @Operation(summary = "Create a new transaction")
    @PostMapping("/user/{userId}")
    public ResponseEntity<TransactionDto> createTransaction(
            @Parameter(description = "User ID") @PathVariable UUID userId,
            @Valid @RequestBody TransactionDto transactionDto) {
        try {
            TransactionDto createdTransaction = transactionService.createTransaction(userId, transactionDto);
            return new ResponseEntity<>(createdTransaction, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @Operation(summary = "Get transactions for a user with pagination")
    @GetMapping("/user/{userId}")
    public ResponseEntity<Page<TransactionDto>> getTransactionsForUser(
            @Parameter(description = "User ID") @PathVariable UUID userId,
            @Parameter(description = "Page number (0-based)") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Page size") @RequestParam(defaultValue = "20") int size) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<TransactionDto> transactions = transactionService.getTransactionsForUser(userId, pageable);
            return ResponseEntity.ok(transactions);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @Operation(summary = "Get transaction by ID")
    @GetMapping("/{id}")
    public ResponseEntity<TransactionDto> getTransactionById(
            @Parameter(description = "Transaction ID") @PathVariable Long id) {
        return transactionService.getTransactionById(id)
                .map(transaction -> ResponseEntity.ok(transaction))
                .orElse(ResponseEntity.notFound().build());
    }
    
    @Operation(summary = "Update transaction")
    @PutMapping("/{id}/user/{userId}")
    public ResponseEntity<TransactionDto> updateTransaction(
            @Parameter(description = "User ID") @PathVariable UUID userId,
            @Parameter(description = "Transaction ID") @PathVariable Long id,
            @Valid @RequestBody TransactionDto transactionDto) {
        try {
            TransactionDto updatedTransaction = transactionService.updateTransaction(userId, id, transactionDto);
            return ResponseEntity.ok(updatedTransaction);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @Operation(summary = "Delete transaction")
    @DeleteMapping("/{id}/user/{userId}")
    public ResponseEntity<Void> deleteTransaction(
            @Parameter(description = "User ID") @PathVariable UUID userId,
            @Parameter(description = "Transaction ID") @PathVariable Long id) {
        try {
            transactionService.deleteTransaction(userId, id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @Operation(summary = "Get dashboard summary for a user")
    @GetMapping("/dashboard/user/{userId}")
    public ResponseEntity<DashboardSummaryDto> getDashboardSummary(
            @Parameter(description = "User ID") @PathVariable UUID userId) {
        try {
            DashboardSummaryDto summary = transactionService.getDashboardSummary(userId);
            return ResponseEntity.ok(summary);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
