# Mini Payroll & Time Attendance

Employee worktime tracking and payroll calculation system (Payroll & Time Attendance)

## 📋 Requirements

### 1. Employee Management (Employee CRUD)

Create CRUD operations for employees

**Employee Data:**
- Name (name)
- Base Salary (base_salary)
- Position (position)

**Required Pages:**
- Employee List Page
- Create/Edit Employee Page
- Employee Show Page with Payroll Summary

### 2. Attendance Tracking

Each employee can have multiple attendance records

**Attendance Rules:**
- Each employee can check in **only once per day**
- Check-out time must be **after** Check-in time
- If working more than **8 hours** → considered **OT (Overtime)**

### 3. Payroll Calculation

The Employee Show page displays:

| Item | Calculation |
|------|-------------|
| Base Salary | Base Salary |
| Work Days | Number of work days |
| OT Hours | Total OT hours |
| OT Pay | OT Hours × Hourly Rate |
| Tax | Calculated by tax rate |
| **Net Pay** | **Base Salary + OT Pay - Tax** |

**Tax Rates:**
- Income ≤ 30,000 THB: **0%**
- Income 30,001 - 50,000 THB: **5%** (portion exceeding 30,000)
- Income > 50,000 THB: **10%** (portion exceeding 50,000)

---

## 🚀 Extra Features

Beyond the basic requirements, the following features are included:

### Search System
- Search employees by name
- Case-insensitive search support

### UI/UX
- Dark Mode UI with Tailwind CSS
- Responsive Design
- Beautiful Animation System
- Stats Cards display for Attendance

### Testing
- Unit Tests for Models
- Controller Tests
- Integration Tests for User Flows

---

## 🛠️ Technologies Used

| Technology | Version |
|------------|---------|
| Ruby | 3.3.1 |
| Rails | 7.2.x |
| Tailwind CSS | 4.x |
| Hotwire | - |
| SQLite | - |

---

## 🤖 AI Tools Used

The following AI tools were used in the development of this project:

| Tool | Purpose |
|------|---------|
| **BLACKBOXAI** | Code generation, debugging, code review, and documentation |
| **ChatGPT** | Initial project planning and architecture design |

### How AI Helped:
- **Code Generation**: Generated Rails models, controllers, and views
- **Test Coverage**: Analyzed and created comprehensive unit tests
- **Debugging**: Helped identify and fix test errors
- **Documentation**: Created and maintained README and inline comments
- **Code Review**: Suggested improvements for code quality and best practices

---

## 📁 Project Structure

```
employee_worktime/
├── app/
│   ├── controllers/
│   │   ├── employees_controller.rb
│   │   └── attendances_controller.rb
│   ├── models/
│   │   ├── employee.rb
│   │   └── attendance.rb
│   └── views/
│       ├── employees/
│       │   ├── index.html.erb
│       │   ├── show.html.erb
│       │   ├── new.html.erb
│       │   ├── edit.html.erb
│       │   └── _form.html.erb
│       └── attendances/
│           ├── index.html.erb
│           ├── show.html.erb
│           ├── new.html.erb
│           └── edit.html.erb
├── test/
│   ├── models/
│   │   ├── employee_test.rb
│   │   └── attendance_test.rb
│   ├── controllers/
│   │   ├── employees_controller_test.rb
│   │   └── attendances_controller_test.rb
│   └── integration/
│       ├── employee_workflow_test.rb
│       └── attendance_workflow_test.rb
└── db/
    ├── schema.rb
    └── migrate/
```

---

## ▶️ Installation & Running the Project

```bash
# 1. Clone repository
git clone https://github.com/thanawadee2024-rgb/Mini-Payroll-Time-Attendance.git
cd Mini-Payroll-Time-Attendance/employee_worktime

# 2. Install dependencies
bundle install

# 3. Setup database
rails db:create db:migrate db:seed

# 4. Run the application
rails dev

# 5. Run tests
rails test
```

---

## 📝 License

MIT License

