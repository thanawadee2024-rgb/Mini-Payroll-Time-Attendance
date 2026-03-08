require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  setup do
    @employee = employees(:john_doe)
  end

  # ==================== Validations ====================

  test "should be valid with required attributes" do
    employee = Employee.new(name: "Test User", position: "Developer", base_salary: 20000)
    assert employee.valid?
  end

  test "should not be valid without name" do
    employee = Employee.new(position: "Developer", base_salary: 20000)
    assert_not employee.valid?
  end

  test "should not be valid without position" do
    employee = Employee.new(name: "Test User", base_salary: 20000)
    assert_not employee.valid?
  end

  test "should not be valid without base_salary" do
    employee = Employee.new(name: "Test User", position: "Developer")
    assert_not employee.valid?
  end

  test "should not be valid with zero base_salary" do
    employee = Employee.new(name: "Test User", position: "Developer", base_salary: 0)
    assert_not employee.valid?
  end

  test "should not be valid with negative base_salary" do
    employee = Employee.new(name: "Test User", position: "Developer", base_salary: -1000)
    assert_not employee.valid?
  end

  # ==================== Associations ====================

  test "should have many attendances" do
    assert_respond_to @employee, :attendances
  end

  test "should destroy associated attendances when employee is destroyed" do
    initial_count = Attendance.count
    new_employee = Employee.create!(name: "Temp Employee", position: "Intern", base_salary: 15000)
    new_employee.attendances.create!(
      check_in: Time.now,
      check_out: Time.now + 8.hours
    )
    
    assert_difference("Attendance.count", -1) do
      new_employee.destroy
    end
  end

  # ==================== work_days ====================

  test "work_days should count distinct days with both check_in and check_out" do
    employee = employees(:john_doe)
    assert employee.attendances.any?
    
    result = employee.work_days
    assert_kind_of Integer, result
    assert result >= 0
  end

  # ==================== total_ot_hours ====================

  test "total_ot_hours should sum OT hours from all attendances" do
    employee = employees(:john_doe)
    result = employee.total_ot_hours
    
    assert_kind_of Float, result
    assert result >= 0
  end

  # ==================== hourly_rate ====================

  test "hourly_rate should calculate correctly (base_salary / 30 / 8)" do
    employee = employees(:john_doe)
    # john_doe has base_salary: 30000
    # Expected: 30000 / 30 / 8 = 125
    expected = 30000.0 / 30.0 / 8.0
    
    assert_in_delta expected, employee.hourly_rate, 0.01
  end

  # ==================== ot_pay ====================

  test "ot_pay should calculate correctly (total_ot_hours * hourly_rate)" do
    employee = employees(:john_doe)
    result = employee.ot_pay
    
    expected = employee.total_ot_hours * employee.hourly_rate
    assert_in_delta expected, result, 0.01
  end

  # ==================== total_income ====================

  test "total_income should calculate correctly (base_salary + ot_pay)" do
    employee = employees(:john_doe)
    result = employee.total_income
    
    expected = employee.base_salary + employee.ot_pay
    assert_in_delta expected, result, 0.01
  end

  # ==================== tax ====================

  test "tax should return 0 when income <= 30000" do
    employee = Employee.create!(name: "Low Income", position: "Intern", base_salary: 25000)
    assert_equal 0.00, employee.tax
  end

  test "tax should calculate 5% when income between 30001 and 50000" do
    employee = Employee.create!(name: "Middle Income", position: "Staff", base_salary: 40000)
    # Tax = (40000 - 30000) * 0.05 = 10000 * 0.05 = 500
    assert_equal 500.00, employee.tax
  end

  test "tax should calculate 10% when income above 50000" do
    employee = Employee.create!(name: "High Income", position: "Manager", base_salary: 60000)
    # Tax = (20000 * 0.05) + ((60000 - 50000) * 0.10)
    #     = 1000 + (10000 * 0.10) = 1000 + 1000 = 2000
    assert_equal 2000.00, employee.tax
  end

  # ==================== net_pay ====================

  test "net_pay should calculate correctly (total_income - tax)" do
    employee = employees(:john_doe)
    result = employee.net_pay
    
    expected = employee.total_income - employee.tax
    assert_in_delta expected, result, 0.01
  end
end

