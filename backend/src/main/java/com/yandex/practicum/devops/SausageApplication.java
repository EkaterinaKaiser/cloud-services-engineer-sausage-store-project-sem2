package com.yandex.practicum.devops;

import com.yandex.practicum.devops.model.Product;
import com.yandex.practicum.devops.service.ProductService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SausageApplication {

    public static void main(String[] args) {
        SpringApplication.run(SausageApplication.class, args);
    }

    @Bean
    CommandLineRunner runner(ProductService productService) {
        return args -> {
            try {
                // Check if products already exist to avoid duplicates
                if (productService.findAll().isEmpty()) {
                    productService.save(new Product(1L, "Сливочная", 320.00, "https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/6.jpg"));
                    productService.save(new Product(2L, "Особая", 179.00, "https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/5.jpg"));
                    productService.save(new Product(3L, "Молочная", 225.00, "https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/4.jpg"));
                    productService.save(new Product(4L, "Нюренбергская", 315.00, "https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/3.jpg"));
                    productService.save(new Product(5L, "Мюнхенская", 330.00, "https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/2.jpg"));
                    productService.save(new Product(6L, "Русская", 189.00, "https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/1.jpg"));
                    System.out.println("Initial products loaded successfully");
                } else {
                    System.out.println("Products already exist, skipping initialization");
                }
            } catch (Exception e) {
                System.err.println("Error loading initial products: " + e.getMessage());
                // Don't fail the application startup if product loading fails
            }
        };
    }
}
