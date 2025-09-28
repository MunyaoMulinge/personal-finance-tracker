package com.kenyafinance.tracker.repository;

import com.kenyafinance.tracker.entity.Category;
import com.kenyafinance.tracker.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    
    /**
     * Find all categories for a specific user (including default categories)
     */
    @Query("SELECT c FROM Category c WHERE c.user = :user OR c.isDefault = true ORDER BY c.name")
    List<Category> findByUserOrDefault(@Param("user") User user);
    
    /**
     * Find only user-specific categories
     */
    List<Category> findByUserAndIsActiveTrue(User user);
    
    /**
     * Find all default categories
     */
    List<Category> findByIsDefaultTrueAndIsActiveTrue();
    
    /**
     * Find category by name for a specific user
     */
    @Query("SELECT c FROM Category c WHERE c.name = :name AND (c.user = :user OR c.isDefault = true)")
    Optional<Category> findByNameAndUserOrDefault(@Param("name") String name, @Param("user") User user);
    
    /**
     * Check if category name exists for user
     */
    @Query("SELECT COUNT(c) > 0 FROM Category c WHERE c.name = :name AND c.user = :user AND c.isActive = true")
    boolean existsByNameAndUser(@Param("name") String name, @Param("user") User user);
    
    /**
     * Find active categories for user
     */
    @Query("SELECT c FROM Category c WHERE (c.user = :user OR c.isDefault = true) AND c.isActive = true ORDER BY c.name")
    List<Category> findActiveByUserOrDefault(@Param("user") User user);
    
    /**
     * Count user categories
     */
    @Query("SELECT COUNT(c) FROM Category c WHERE c.user = :user AND c.isActive = true")
    long countByUser(@Param("user") User user);
}
