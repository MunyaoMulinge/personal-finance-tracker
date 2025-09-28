package com.kenyafinance.tracker;

import com.kenyafinance.tracker.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class FinanceTrackerApiApplication implements CommandLineRunner {

	@Autowired
	private CategoryService categoryService;

	public static void main(String[] args) {
		SpringApplication.run(FinanceTrackerApiApplication.class, args);
	}

	@Override
	public void run(String... args) throws Exception {
		// Initialize default categories on startup
		categoryService.initializeDefaultCategories();
		System.out.println("✅ Personal Finance Tracker API started successfully!");
		System.out.println("📊 Default categories initialized");
		System.out.println("🌐 API Documentation: http://localhost:8080/swagger-ui.html");
		System.out.println("💚 Health Check: http://localhost:8080/actuator/health");
	}
}
