# Personal Finance Tracker 🏦

A Flutter app for tracking KSh income and expenses with beautiful charts, built during off-hours as a side project.

## 🎯 MVP Features

- ✅ **Authentication System** - Email signup/login with Supabase Auth
- 🔄 **Transaction Logging** - Add, edit, delete income/expense transactions
- 📊 **Dashboard with Charts** - Visual breakdown of expenses by category
- 🏷️ **Categories Management** - Default and custom categories
- 📱 **Offline Support** - Local storage with sync when online
- 🎨 **Beautiful UI** - Based on Figma designs with Material 3

## 🛠️ Tech Stack

- **Frontend**: Flutter + Provider (state management)
- **Charts**: fl_chart
- **Backend**: Supabase (PostgreSQL + Auth)
- **Local Storage**: SQLite
- **Design**: Figma (Google Stitch generated)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / VS Code
- Supabase account

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd personal-finance-tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Supabase Setup**
   - Create a new project at [supabase.com](https://supabase.com)
   - Copy your project URL and anon key
   - Update the `.env` file with your credentials:
     ```
     SUPABASE_URL=your_supabase_project_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **Database Setup**
   Run the following SQL in your Supabase SQL editor:
   ```sql
   -- Categories table
   CREATE TABLE categories (
     id SERIAL PRIMARY KEY,
     user_id UUID REFERENCES auth.users(id),
     name VARCHAR(50) NOT NULL
   );

   -- Transactions table
   CREATE TABLE transactions (
     id SERIAL PRIMARY KEY,
     user_id UUID REFERENCES auth.users(id),
     type VARCHAR(20) CHECK (type IN ('Income', 'Expense')),
     amount DECIMAL(10,2),
     category_id INT REFERENCES categories(id),
     date TIMESTAMP DEFAULT NOW(),
     notes TEXT
   );

   -- Insert default categories
   INSERT INTO categories (name) VALUES
   ('Salary'), ('Rent'), ('Food'), ('Transport'), ('Utilities');

   -- Enable RLS
   ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
   CREATE POLICY user_transactions ON transactions
   USING (user_id = auth.uid());

   ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
   CREATE POLICY user_categories ON categories
   USING (user_id = auth.uid() OR user_id IS NULL);
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Testing

Run tests with:
```bash
flutter test
```

Run analysis:
```bash
flutter analyze
```

## 📱 Features Implemented

### ✅ Authentication System
- Email/password signup and login
- Form validation with proper error handling
- Secure session management with Supabase Auth
- Beautiful gradient UI matching Figma designs

### ✅ Core Data Models
- **Transaction Model**: Handles income/expense with KSh formatting
- **Category Model**: Default and user-defined categories
- Proper JSON serialization for Supabase integration

### ✅ State Management
- Provider pattern for authentication state
- Loading states and error handling
- Reactive UI updates

## 🎨 Design

The app follows the Figma designs with:
- Green gradient backgrounds (#4CAF50)
- Material 3 design system
- Kenyan Shilling (KSh) currency formatting
- Swahili greeting ("Karibu!")

## 📅 Development Timeline

**Target Launch**: October 28, 2025

**Current Status**: Authentication system complete ✅

**Next Steps**:
- Transaction management (CRUD operations)
- Categories management
- Dashboard with pie charts
- Offline support with SQLite
- Testing and validation

## 🔧 Development Schedule

- **Weekday mornings**: 2-2.5 hours (4:00-6:30 AM)
- **Weekday evenings**: 1-1.5 hours (after 6:30 PM)
- **Weekends**: 4-6 hours focused work

## 📝 License

This project is for educational and portfolio purposes.

