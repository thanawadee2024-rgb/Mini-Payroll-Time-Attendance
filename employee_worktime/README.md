# Mini Payroll & Time Attendance

ระบบบันทึกเวลาการทำงานและคำนวณเงินเดือนพนักงาน (Payroll & Time Attendance)

## 📋 ข้อกำหนดด้านการทำงาน (Requirements)

### 1. การจัดการพนักงาน (Employee CRUD)

สร้าง CRUD สำหรับพนักงาน

**ข้อมูลพนักงาน:**
- ชื่อ (name)
- เงินเดือน (base_salary)
- ตำแหน่ง (position)

**หน้าที่ต้องมี:**
- หน้า List พนักงาน
- หน้า Create/Edit พนักงาน
- หน้า Show ข้อมูลพนักงานพร้อม Payroll Summary

### 2. การลงเวลาการทำงาน (Attendance)

พนักงานแต่ละคนสามารถมี attendance ได้หลายรายการ

**กฎการลงเวลา:**
- พนักงาน 1 คนสามารถเข้างานได้ **1 ครั้งต่อวันเท่านั้น**
- วันเวลา Check-out ต้องเกิดขึ้น **หลัง** วันเวลา Check-in
- ถ้าทำงานเกิน **8 ชั่วโมง** → ถือว่าเป็น **OT (Overtime)**

### 3. การคำนวณเงินเดือน (Payroll Calculation)

ในหน้า Employee Show แสดง:

| รายการ | การคำนวณ |
|--------|----------|
| Base Salary | เงินเดือนพื้นฐาน |
| Work Days | จำนวนวันทำงาน |
| OT Hours | จำนวนชั่วโมง OT ทั้งหมด |
| OT Pay | OT Hours × Hourly Rate |
| Tax | คำนวณตามอัตราภาษี |
| **Net Pay** | **Base Salary + OT Pay - Tax** |

**อัตราภาษี:**
- เงินได้ ≤ 30,000 บาท: **0%**
- เงินได้ 30,001 - 50,000 บาท: **5%** (ส่วนที่เกิน 30,000)
- เงินได้ > 50,000 บาท: **10%** (ส่วนที่เกิน 50,000)

---

## 🚀 Features เพิ่มเติม (Extra Features)

นอกเหนือจาก Requirements พื้นฐาน ยังมีฟีเจอร์เพิ่มเติมดังนี้:

### ระบบค้นหา (Search)
- ค้นหาพนักงานจากชื่อ
- รองรับการค้นหาแบบ case-insensitive

### การแสดงผล (UI/UX)
- Dark Mode UI ด้วย Tailwind CSS
- Responsive Design
- ระบบ Animation สวยงาม
- แสดง Stats Cards สำหรับ Attendance

### การทดสอบ (Testing)
- Unit Tests สำหรับ Models (49 tests)
- Controller Tests (50 tests)
- Integration Tests (20 tests)
- **รวมทั้งหมด: 119 tests**

---

## 🛠️ เทคโนโลยีที่ใช้

| Technology | Version |
|------------|---------|
| Ruby | 3.3.1 |
| Rails | 7.2.x |
| Tailwind CSS | 4.x |
| Hotwire | - |
| SQLite | - |

---

## 🤖 AI Tools ที่ใช้ในการพัฒนา

### ใช้ **BlackBOX AI** ในการพัฒนา:

1. **การวิเคราะห์โครงสร้างโปรเจค**
   - ตรวจสอบไฟล์ที่มีอยู่แล้ว
   - วิเคราะห์ Models, Controllers, Views

2. **การสร้าง Unit Tests**
   - สร้าง Model Tests สำหรับ Employee และ Attendance
   - สร้าง Controller Tests
   - สร้าง Integration Tests สำหรับ User Flows

3. **การแก้ไข Bug**
   - แก้ไข Tests ที่ล้มเหลว
   - ปรับปรุงการตรวจสอบ decimal places

4. **การเขียนเอกสาร**
   - เขียน README.md

---

## 📁 โครงสร้างโปรเจค

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

## ▶️ การติดตั้งและรันโปรเจค

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

## 📊ผลการทดสอบ

```
119 runs, 302 assertions, 0 failures, 0 errors, 0 skips
```

---

## 📝 License

MIT License

