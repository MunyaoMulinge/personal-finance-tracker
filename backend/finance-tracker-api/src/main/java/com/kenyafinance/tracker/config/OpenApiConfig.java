package com.kenyafinance.tracker.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {
    
    @Value("${server.port:8080}")
    private String serverPort;
    
    @Bean
    public OpenAPI customOpenAPI() {
        Server localServer = new Server()
                .url("http://localhost:" + serverPort)
                .description("Local Development Server");
        
        return new OpenAPI()
                .servers(List.of(localServer))
                .info(new Info()
                        .title("Personal Finance Tracker API")
                        .description("A comprehensive REST API for managing personal finances, " +
                                   "including transactions, categories, and user management. " +
                                   "Built with Spring Boot 3.5.6 and Java 25.")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Kenya Finance Tracker Team")
                                .email("support@kenyafinance.com")
                                .url("https://github.com/kenyafinance/tracker"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")));
    }
}
