package com.kenyafinance.tracker.service;

import com.kenyafinance.tracker.dto.CategoryDto;
import com.kenyafinance.tracker.entity.Category;
import com.kenyafinance.tracker.entity.User;
import com.kenyafinance.tracker.repository.CategoryRepository;
import com.kenyafinance.tracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class CategoryService {
    
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;
    
    @Autowired
    public CategoryService(CategoryRepository categoryRepository, UserRepository userRepository) {
        this.categoryRepository = categoryRepository;
        this.userRepository = userRepository;
    }
    
    /**
     * Create a new category for a user
     */
    public CategoryDto createCategory(UUID userId, CategoryDto categoryDto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        // Check if category name already exists for this user
        if (categoryRepository.existsByNameAndUser(categoryDto.getName(), user)) {
            throw new RuntimeException("Category with name '" + categoryDto.getName() + "' already exists for this user");
        }
        
        Category category = convertToEntity(categoryDto);
        category.setUser(user);
        category.setIsDefault(false); // User categories are not default
        
        Category savedCategory = categoryRepository.save(category);
        return convertToDto(savedCategory);
    }
    
    /**
     * Get all categories for a user (including default categories)
     */
    @Transactional(readOnly = true)
    public List<CategoryDto> getCategoriesForUser(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        return categoryRepository.findActiveByUserOrDefault(user)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Get category by ID
     */
    @Transactional(readOnly = true)
    public Optional<CategoryDto> getCategoryById(Long id) {
        return categoryRepository.findById(id)
                .map(this::convertToDto);
    }
    
    /**
     * Update category
     */
    public CategoryDto updateCategory(UUID userId, Long categoryId, CategoryDto categoryDto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        Category existingCategory = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + categoryId));
        
        // Check if user owns this category or if it's a default category
        if (existingCategory.getIsDefault() || 
            (existingCategory.getUser() != null && !existingCategory.getUser().getId().equals(userId))) {
            throw new RuntimeException("Cannot update this category");
        }
        
        // Check if new name conflicts with existing categories
        if (!existingCategory.getName().equals(categoryDto.getName()) &&
            categoryRepository.existsByNameAndUser(categoryDto.getName(), user)) {
            throw new RuntimeException("Category with name '" + categoryDto.getName() + "' already exists for this user");
        }
        
        // Update fields
        existingCategory.setName(categoryDto.getName());
        existingCategory.setDescription(categoryDto.getDescription());
        existingCategory.setIconName(categoryDto.getIconName());
        existingCategory.setColorCode(categoryDto.getColorCode());
        
        Category updatedCategory = categoryRepository.save(existingCategory);
        return convertToDto(updatedCategory);
    }
    
    /**
     * Delete category (soft delete)
     */
    public void deleteCategory(UUID userId, Long categoryId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + categoryId));
        
        // Check if user owns this category and it's not a default category
        if (category.getIsDefault() || 
            (category.getUser() != null && !category.getUser().getId().equals(userId))) {
            throw new RuntimeException("Cannot delete this category");
        }
        
        category.setIsActive(false);
        categoryRepository.save(category);
    }
    
    /**
     * Get all default categories
     */
    @Transactional(readOnly = true)
    public List<CategoryDto> getDefaultCategories() {
        return categoryRepository.findByIsDefaultTrueAndIsActiveTrue()
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Initialize default categories
     */
    public void initializeDefaultCategories() {
        List<Category> defaultCategories = List.of(
            new Category("Salary", "Monthly salary income", "work", "#4CAF50", true),
            new Category("Food", "Food and dining expenses", "restaurant", "#FF9800", true),
            new Category("Transport", "Transportation costs", "directions_car", "#2196F3", true),
            new Category("Utilities", "Utility bills", "flash_on", "#9C27B0", true),
            new Category("Rent", "Housing rent", "home", "#F44336", true),
            new Category("Entertainment", "Entertainment expenses", "movie", "#E91E63", true),
            new Category("Healthcare", "Medical expenses", "local_hospital", "#009688", true),
            new Category("Shopping", "Shopping expenses", "shopping_cart", "#FF5722", true)
        );
        
        for (Category category : defaultCategories) {
            if (!categoryRepository.findByNameAndUserOrDefault(category.getName(), null).isPresent()) {
                categoryRepository.save(category);
            }
        }
    }
    
    /**
     * Convert Entity to DTO
     */
    private CategoryDto convertToDto(Category category) {
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
    
    /**
     * Convert DTO to Entity
     */
    private Category convertToEntity(CategoryDto dto) {
        Category category = new Category();
        category.setId(dto.getId());
        category.setName(dto.getName());
        category.setDescription(dto.getDescription());
        category.setIconName(dto.getIconName());
        category.setColorCode(dto.getColorCode());
        category.setIsDefault(dto.getIsDefault() != null ? dto.getIsDefault() : false);
        category.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);
        return category;
    }
}
