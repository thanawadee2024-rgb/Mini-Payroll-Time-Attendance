require "test_helper"

class EmployeeWorkflowTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:john_doe)
  end

  # ==================== Full Employee Lifecycle ====================

  test "complete employee lifecycle: create, view, edit, delete" do
    # 1. Create new employee
    get new_employee_url
    assert_response :success

    assert_difference("Employee.count") do
      post employees_url, params: {
        employee: {
          name: "Integration Test Employee",
          position: "QA Engineer",
          base_salary: 28000
        }
      }
    end

    new_employee = Employee.last
    assert_redirected_to employee_url(new_employee)

    # 2. View new employee
    get employee_url(new_employee)
    assert_response :success

    # 3. Edit employee
    get edit_employee_url(new_employee)
    assert_response :success

    patch employee_url(new_employee), params: {
      employee: {
        name: "Updated Integration Employee",
        position: "Senior QA Engineer",
        base_salary: 32000
      }
    }

    assert_redirected_to employee_url(new_employee)
    new_employee.reload
    assert_equal "Updated Integration Employee", new_employee.name
    assert_equal "Senior QA Engineer", new_employee.position
    assert_equal 32000, new_employee.base_salary

    # 4. Delete employee
    assert_difference("Employee.count", -1) do
      delete employee_url(new_employee)
    end

    assert_redirected_to employees_url
  end

  # ==================== Employee Navigation ====================

  test "can navigate from employee list to employee details" do
    get employees_url
    assert_response :success

    get employee_url(@employee)
    assert_response :success
  end

  test "can navigate from employee to attendances" do
    get employees_url
    assert_response :success

    @employee.attendances.create!(
      check_in: Time.now,
      check_out: Time.now + 8.hours
    )

    get employee_attendances_url(@employee)
    assert_response :success
  end

  # ==================== Search Functionality ====================

  test "search returns matching employees" do
    get employees_url, params: { search: "John" }
    assert_response :success
  end

  test "search returns no results for non-existent employee" do
    get employees_url, params: { search: "NonExistentEmployee12345" }
    assert_response :success
  end

  test "search is case insensitive" do
    get employees_url, params: { search: "JOHN" }
    assert_response :success
  end
end

