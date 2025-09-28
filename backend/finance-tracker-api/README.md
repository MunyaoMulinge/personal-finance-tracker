# Personal Finance Tracker API

A comprehensive REST API for managing personal finances, built with Spring Boot 3.5.6 and Java 25.

## 🚀 Features

- **User Management**: Create, update, and manage user accounts
- **Transaction Management**: Track income and expenses with detailed categorization
- **Category Management**: Organize transactions with default and custom categories
- **Dashboard Analytics**: Get financial summaries and spending breakdowns
- **RESTful API**: Clean, well-documented REST endpoints
- **OpenAPI Documentation**: Interactive API documentation with Swagger UI
- **Security**: CORS configuration and JWT-ready authentication
- **Database**: PostgreSQL with JPA/Hibernate
- **Testing**: Comprehensive test suite with H2 in-memory database

## 🛠 Technology Stack

- **Java 25** - Latest Java LTS version
- **Spring Boot 3.5.6** - Latest Spring Boot version
- **Spring Data JPA** - Database abstraction layer
- **Spring Security** - Security framework
- **PostgreSQL** - Production database
- **H2** - Testing database
- **Maven** - Dependency management
- **OpenAPI 3** - API documentation
- **MapStruct** - Object mapping
- **JUnit 5** - Testing framework

## 📋 Prerequisites

- Java 25 or higher
- Maven 3.8+
- PostgreSQL 12+ (for production)
- Git

## 🏃‍♂️ Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd backend/finance-tracker-api
```

### 2. Configure Database
Update `src/main/resources/application.properties` with your PostgreSQL credentials:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/finance_tracker
spring.datasource.username=your_username
spring.datasource.password=your_password
```

### 3. Run the Application
```bash
# Using Maven wrapper
./mvnw spring-boot:run

# Or using Maven directly
mvn spring-boot:run
```

### 4. Access the API
- **API Base URL**: http://localhost:8080/api/v1
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Health Check**: http://localhost:8080/actuator/health

## 📚 API Endpoints

### Users
- `POST /api/v1/users` - Create user
- `GET /api/v1/users/{id}` - Get user by ID
- `GET /api/v1/users/email/{email}` - Get user by email
- `PUT /api/v1/users/{id}` - Update user
- `DELETE /api/v1/users/{id}` - Deactivate user

### Categories
- `POST /api/v1/categories/user/{userId}` - Create category
- `GET /api/v1/categories/user/{userId}` - Get user categories
- `GET /api/v1/categories/{id}` - Get category by ID
- `PUT /api/v1/categories/{id}/user/{userId}` - Update category
- `DELETE /api/v1/categories/{id}/user/{userId}` - Delete category
- `GET /api/v1/categories/defaults` - Get default categories

### Transactions
- `POST /api/v1/transactions/user/{userId}` - Create transaction
- `GET /api/v1/transactions/user/{userId}` - Get user transactions (paginated)
- `GET /api/v1/transactions/{id}` - Get transaction by ID
- `PUT /api/v1/transactions/{id}/user/{userId}` - Update transaction
- `DELETE /api/v1/transactions/{id}/user/{userId}` - Delete transaction
- `GET /api/v1/transactions/dashboard/user/{userId}` - Get dashboard summary

## 🧪 Testing

```bash
# Run all tests
./mvnw test

# Run tests with coverage
./mvnw test jacoco:report
```

## 🏗 Project Structure

```
src/
├── main/
│   ├── java/com/kenyafinance/tracker/
│   │   ├── config/          # Configuration classes
│   │   ├── controller/      # REST controllers
│   │   ├── dto/            # Data Transfer Objects
│   │   ├── entity/         # JPA entities
│   │   ├── repository/     # Data repositories
│   │   └── service/        # Business logic
│   └── resources/
│       └── application.properties
└── test/
    ├── java/               # Test classes
    └── resources/
        └── application-test.properties
```

## 🔧 Configuration

### Environment Variables
You can override configuration using environment variables:

```bash
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/finance_tracker
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=password
export SERVER_PORT=8080
```

### Profiles
- `default` - Development profile
- `test` - Testing profile with H2 database
- `prod` - Production profile (to be configured)

## 🚀 Deployment

### Docker (Coming Soon)
```bash
# Build Docker image
docker build -t finance-tracker-api .

# Run container
docker run -p 8080:8080 finance-tracker-api
```

### JAR Deployment
```bash
# Build JAR
./mvnw clean package

# Run JAR
java -jar target/finance-tracker-api-0.0.1-SNAPSHOT.jar
```

## 🤝 Integration with Flutter App

This API is designed to work seamlessly with the Flutter Personal Finance Tracker app. Key integration points:

1. **User Authentication**: Ready for Supabase JWT integration
2. **CORS**: Configured for Flutter web and mobile apps
3. **Data Models**: Aligned with Flutter app models
4. **API Design**: RESTful endpoints matching Flutter service expectations

## 📈 Performance & Monitoring

- **Actuator**: Health checks and metrics at `/actuator`
- **Logging**: Configurable logging levels
- **Database**: Optimized queries with JPA
- **Caching**: Ready for Redis integration

## 🔐 Security

- **CORS**: Configurable cross-origin resource sharing
- **JWT**: Ready for JWT token authentication
- **Validation**: Input validation with Bean Validation
- **SQL Injection**: Protected with JPA/Hibernate

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Email: support@kenyafinance.com
- Documentation: Check the Swagger UI for detailed API docs
