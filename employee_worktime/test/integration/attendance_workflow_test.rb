require "test_helper"

class AttendanceWorkflowTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:john_doe)
    @attendance = attendances(:john_morning)
  end

  # ==================== Full Attendance Lifecycle ====================

  test "complete attendance lifecycle: create, view, edit, delete" do
    # 1. Create new attendance
    get new_employee_attendance_url(@employee)
    assert_response :success

    assert_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        attendance: {
          check_in: Time.now,
          check_out: Time.now + 9.hours
        }
      }
    end

    new_attendance = @employee.attendances.last
    assert_redirected_to employee_attendance_url(@employee, new_attendance)

    # 2. View attendance
    get employee_attendance_url(@employee, new_attendance)
    assert_response :success

    # 3. Edit attendance
    get edit_employee_attendance_url(@employee, new_attendance)
    assert_response :success

    new_check_in = Time.now + 1.day
    new_check_out = Time.now + 1.day + 10.hours

    patch employee_attendance_url(@employee, new_attendance), params: {
      attendance: {
        check_in: new_check_in,
        check_out: new_check_out
      }
    }

    assert_redirected_to employee_attendance_url(@employee, new_attendance)
    new_attendance.reload
    assert_equal new_check_in.day, new_attendance.check_in.day

    # 4. Delete attendance
    assert_difference("Attendance.count", -1) do
      delete employee_attendance_url(@employee, new_attendance)
    end

    assert_redirected_to employee_attendances_url(@employee)
  end

  # ==================== Attendance Index ====================

  test "attendance index displays all records" do
    get employee_attendances_url(@employee)
    assert_response :success

    # Should display the table
    assert_select "table.att-table"
  end

  test "attendance index displays stats correctly" do
    get employee_attendances_url(@employee)
    assert_response :success

    # Check for stats cards
    assert_select ".att-stat", minimum: 3
    assert_select ".att-stat-label", /Total Records/
    assert_select ".att-stat-label", /Avg Work Hours/
    assert_select ".att-stat-label", /Total OT Hours/
  end

  test "attendance index shows empty state when no records" do
    # Create new employee with no attendances
    new_employee = Employee.create!(
      name: "New Employee No Attendance",
      position: "Intern",
      base_salary: 15000
    )

    get employee_attendances_url(new_employee)
    assert_response :success

    # Should show empty state
    assert_select ".att-empty"
  end

  # ==================== Navigation Between Pages ====================

  test "can navigate back to employees from attendances" do
    get employee_attendances_url(@employee)
    assert_response :success

    # Check for back link
    assert_select "a.att-back"
  end

  test "can navigate from employee to attendances list" do
    get employees_url
    assert_response :success

    # Navigate to employee's attendances
    get employee_attendances_url(@employee)
    assert_response :success
    assert_select ".att-title"
  end

  # ==================== Attendance Validation ====================

  test "cannot create attendance with check_out before check_in" do
    assert_no_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        attendance: {
          check_in: Time.now + 8.hours,
          check_out: Time.now
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "cannot create duplicate attendance on same day" do
    # Create first attendance
    @employee.attendances.create!(
      check_in: Time.new(2026, 7, 1, 9, 0, 0),
      check_out: Time.new(2026, 7, 1, 18, 0, 0)
    )

    # Try to create second attendance on same day
    assert_no_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        attendance: {
          check_in: Time.new(2026, 7, 1, 10, 0, 0),
          check_out: Time.new(2026, 7, 1, 19, 0, 0)
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "can create attendance on different days" do
    # Create first attendance
    @employee.attendances.create!(
      check_in: Time.new(2026, 7, 1, 9, 0, 0),
      check_out: Time.new(2026, 7, 1, 18, 0, 0)
    )

    # Create second attendance on different day
    assert_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        attendance: {
          check_in: Time.new(2026, 7, 2, 9, 0, 0),
          check_out: Time.new(2026, 7, 2, 18, 0, 0)
        }
      }
    end

    assert_redirected_to employee_attendance_url(@employee, @employee.attendances.last)
  end

  # ==================== Attendance Display ====================

  test "attendance records display work hours and OT correctly" do
    get employee_attendances_url(@employee)
    assert_response :success

    # Should have attendance records
    assert @employee.attendances.any?

    # Check for work hours display
    assert_select ".hr-cell.work"
  end

  test "attendance with OT shows correct values" do
    # Create attendance with OT
    ot_attendance = @employee.attendances.create!(
      check_in: Time.new(2026, 7, 10, 9, 0, 0),
      check_out: Time.new(2026, 7, 10, 20, 0, 0)
    )

    # Verify OT calculation
    assert ot_attendance.ot_hours > 0

    get employee_attendances_url(@employee)
    assert_response :success

    # Should show OT
    assert_select ".hr-cell.ot"
  end

  # ==================== Employee Deletion with Attendances ====================

  test "deleting employee also deletes all associated attendances" do
    # Create some attendances
    @employee.attendances.create!(
      check_in: Time.now,
      check_out: Time.now + 8.hours
    )
    @employee.attendances.create!(
      check_in: Time.now + 1.day,
      check_out: Time.now + 1.day + 9.hours
    )

    attendance_count = @employee.attendances.count

    assert_difference("Attendance.count", -attendance_count) do
      assert_difference("Employee.count", -1) do
        delete employee_url(@employee)
      end
    end

    assert_redirected_to employees_url
  end
end

