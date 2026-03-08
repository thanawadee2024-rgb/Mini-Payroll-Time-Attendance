require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:john_doe)
    @other_employee = employees(:jane_smith)
  end

  # ==================== Index ====================

  test "should get index" do
    get employees_url
    assert_response :success
  end

  test "index should display all employees" do
    get employees_url
    assert_response :success
    # Check for employee names in the page (they are in spans)
    assert_select "span", /John Doe/
    assert_select "span", /Jane Smith/
  end

  test "index should have search functionality" do
    get employees_url, params: { search: "John" }
    assert_response :success
  end

  test "index search should return no results for nonexistent name" do
    get employees_url, params: { search: "NonExistentPerson12345" }
    assert_response :success
  end

  # ==================== New ====================

  test "should get new" do
    get new_employee_url
    assert_response :success
  end

  test "new should render form with required fields" do
    get new_employee_url
    assert_select "form"
    assert_select "input[name*='employee[name]']"
    assert_select "input[name*='employee[position]']"
    assert_select "input[name*='employee[base_salary]']"
  end

  # ==================== Create ====================

  test "should create employee with valid params" do
    assert_difference("Employee.count") do
      post employees_url, params: {
        employee: {
          name: "New Employee",
          position: "Developer",
          base_salary: 25000
        }
      }
    end

    assert_redirected_to employee_url(Employee.last)
  end

  test "should not create employee with invalid params" do
    assert_no_difference("Employee.count") do
      post employees_url, params: {
        employee: {
          name: "",
          position: "",
          base_salary: nil
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create employee with zero salary" do
    assert_no_difference("Employee.count") do
      post employees_url, params: {
        employee: {
          name: "Test Employee",
          position: "Developer",
          base_salary: 0
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create employee with negative salary" do
    assert_no_difference("Employee.count") do
      post employees_url, params: {
        employee: {
          name: "Test Employee",
          position: "Developer",
          base_salary: -1000
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ==================== Show ====================

  test "should show employee" do
    get employee_url(@employee)
    assert_response :success
  end

  test "show should display employee details" do
    get employee_url(@employee)
    assert_response :success
    # Check for employee name in the page - it's in a heading or div
    assert_select ".ps-title", /#{@employee.name}/
  end

  test "show should display payroll breakdown" do
    get employee_url(@employee)
    assert_response :success
    # Check for salary-related elements
    assert_select ".ps-net-amt", count: 1
  end

  test "show should display work days" do
    get employee_url(@employee)
    assert_response :success
    # Should show work days count
    assert_select "td", /Work Days/
  end

  test "show should display OT hours" do
    get employee_url(@employee)
    assert_response :success
    # Should show OT hours
    assert_select "td", /OT Hours/
  end

  test "show should display OT pay" do
    get employee_url(@employee)
    assert_response :success
    # Should show OT pay
    assert_select "td", /OT Pay/
  end

  test "show should display tax" do
    get employee_url(@employee)
    assert_response :success
    # Should show tax
    assert_select "td", /Tax/
  end

  # ==================== Edit ====================

  test "should get edit" do
    get edit_employee_url(@employee)
    assert_response :success
  end

  test "edit should render form with existing values" do
    get edit_employee_url(@employee)
    assert_select "input[value='#{@employee.name}']"
    assert_select "input[value='#{@employee.position}']"
    assert_select "input[value='#{@employee.base_salary}']"
  end

  # ==================== Update ====================

  test "should update employee with valid params" do
    patch employee_url(@employee), params: {
      employee: {
        name: "Updated Name",
        position: "Senior Developer",
        base_salary: 35000
      }
    }

    assert_redirected_to employee_url(@employee)
    @employee.reload
    assert_equal "Updated Name", @employee.name
    assert_equal "Senior Developer", @employee.position
    assert_equal 35000, @employee.base_salary
  end

  test "should not update employee with invalid params" do
    patch employee_url(@employee), params: {
      employee: {
        name: "",
        position: "",
        base_salary: nil
      }
    }

    assert_response :unprocessable_entity
    @employee.reload
    assert_not_equal "", @employee.name
  end

  test "should not update employee with invalid salary" do
    original_salary = @employee.base_salary
    
    patch employee_url(@employee), params: {
      employee: {
        base_salary: -5000
      }
    }

    assert_response :unprocessable_entity
    @employee.reload
    assert_equal original_salary, @employee.base_salary
  end

  # ==================== Destroy ====================

  test "should destroy employee" do
    assert_difference("Employee.count", -1) do
      delete employee_url(@employee)
    end

    assert_redirected_to employees_url
  end

  test "should destroy employee and all associated attendances" do
    # Create some attendances first
    @employee.attendances.create!(
      check_in: Time.now,
      check_out: Time.now + 8.hours
    )

    attendance_count = @employee.attendances.count
    
    assert_difference("Attendance.count", -attendance_count) do
      assert_difference("Employee.count", -1) do
        delete employee_url(@employee)
      end
    end

    assert_redirected_to employees_url
  end

  test "should redirect to index after destroy" do
    delete employee_url(@employee)
    assert_redirected_to employees_url
  end
end

