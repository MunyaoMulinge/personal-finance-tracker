package com.kenyafinance.tracker.controller;

import com.kenyafinance.tracker.dto.CategoryDto;
import com.kenyafinance.tracker.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/categories")
@Tag(name = "Category Management", description = "APIs for managing transaction categories")
@CrossOrigin(origins = "*")
public class CategoryController {
    
    private final CategoryService categoryService;
    
    @Autowired
    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }
    
    @Operation(summary = "Create a new category for a user")
    @PostMapping("/user/{userId}")
    public ResponseEntity<CategoryDto> createCategory(
            @Parameter(description = "User ID") @PathVariable UUID userId,
            @Valid @RequestBody CategoryDto categoryDto) {
        try {
            CategoryDto createdCategory = categoryService.createCategory(userId, categoryDto);
            return new ResponseEntity<>(createdCategory, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @Operation(summary = "Get all categories for a user (including default categories)")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<CategoryDto>> getCategoriesForUser(
            @Parameter(description = "User ID") @PathVariable UUID userId) {
        try {
            List<CategoryDto> categories = categoryService.getCategoriesForUser(userId);
            return ResponseEntity.ok(categories);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @Operation(summary = "Get category by ID")
    @GetMapping("/{id}")
    public ResponseEntity<CategoryDto> getCategoryById(
            @Parameter(description = "Category ID") @PathVariable Long id) {
        return categoryService.getCategoryById(id)
                .map(category -> ResponseEntity.ok(category))
                .orElse(ResponseEntity.notFound().build());
    }
    
    @Operation(summary = "Update category")
    @PutMapping("/{id}/user/{userId}")
    public ResponseEntity<CategoryDto> updateCategory(
            @Parameter(description = "User ID") @PathVariable UUID userId,
            @Parameter(description = "Category ID") @PathVariable Long id,
            @Valid @RequestBody CategoryDto categoryDto) {
        try {
            CategoryDto updatedCategory = categoryService.updateCategory(userId, id, categoryDto);
            return ResponseEntity.ok(updatedCategory);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @Operation(summary = "Delete category")
    @DeleteMapping("/{id}/user/{userId}")
    public ResponseEntity<Void> deleteCategory(
            @Parameter(description = "User ID") @PathVariable UUID userId,
            @Parameter(description = "Category ID") @PathVariable Long id) {
        try {
            categoryService.deleteCategory(userId, id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @Operation(summary = "Get all default categories")
    @GetMapping("/defaults")
    public ResponseEntity<List<CategoryDto>> getDefaultCategories() {
        List<CategoryDto> defaultCategories = categoryService.getDefaultCategories();
        return ResponseEntity.ok(defaultCategories);
    }
    
    @Operation(summary = "Initialize default categories")
    @PostMapping("/initialize-defaults")
    public ResponseEntity<Void> initializeDefaultCategories() {
        categoryService.initializeDefaultCategories();
        return ResponseEntity.ok().build();
    }
}
