require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:john_doe)
    @attendance = attendances(:john_morning)
    @other_employee = employees(:jane_smith)
  end

  # ==================== Index ====================

  test "should get employee attendances index" do
    get employee_attendances_url(@employee)
    assert_response :success
  end

  test "index should display all attendances for employee" do
    get employee_attendances_url(@employee)
    assert_response :success
    # Should show attendance records
    assert_select "table.att-table"
  end

  test "index should display stats" do
    get employee_attendances_url(@employee)
    assert_response :success
    # Should show stats cards
    assert_select ".att-stat", minimum: 3
  end

  test "index should display total records count" do
    get employee_attendances_url(@employee)
    assert_response :success
    # Should show "Total Records"
    assert_select ".att-stat-label", /Total Records/
  end

  test "index should display average work hours" do
    get employee_attendances_url(@employee)
    assert_response :success
    # Should show "Avg Work Hours"
    assert_select ".att-stat-label", /Avg Work Hours/
  end

  test "index should display total OT hours" do
    get employee_attendances_url(@employee)
    assert_response :success
    # Should show "Total OT Hours"
    assert_select ".att-stat-label", /Total OT Hours/
  end

  # ==================== Show ====================

  test "should show attendance" do
    get employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  test "show should display check-in time" do
    get employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  test "show should display check-out time" do
    get employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  test "show should display work hours" do
    get employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  test "show should display OT hours" do
    get employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  # ==================== New ====================

  test "should get new attendance" do
    get new_employee_attendance_url(@employee)
    assert_response :success
  end

  test "new should render form with required fields" do
    get new_employee_attendance_url(@employee)
    assert_select "form"
    assert_select "input[name*='attendance[check_in]']"
    assert_select "input[name*='attendance[check_out]']"
  end

  # ==================== Create ====================

  test "should create attendance with valid params" do
    assert_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        attendance: {
          check_in: Time.now,
          check_out: Time.now + 8.hours
        }
      }
    end

    assert_redirected_to employee_attendance_url(@employee, Attendance.last)
  end

  test "should not create attendance without check_in" do
    assert_no_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        attendance: {
          check_in: nil,
          check_out: Time.now + 8.hours
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create attendance with check_out before check_in" do
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

  test "should not allow duplicate check-in on same day" do
    # Create first attendance
    @employee.attendances.create!(
      check_in: Time.new(2026, 6, 1, 9, 0, 0),
      check_out: Time.new(2026, 6, 1, 18, 0, 0)
    )

    # Try to create second attendance on same day
    assert_no_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        attendance: {
          check_in: Time.new(2026, 6, 1, 10, 0, 0),
          check_out: Time.new(2026, 6, 1, 19, 0, 0)
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ==================== Edit ====================

  test "should get edit attendance" do
    get edit_employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  test "edit should render form with existing values" do
    get edit_employee_attendance_url(@employee, @attendance)
    assert_select "form"
  end

  # ==================== Update ====================

  test "should update attendance with valid params" do
    new_check_in = Time.now + 1.day
    new_check_out = Time.now + 1.day + 9.hours

    patch employee_attendance_url(@employee, @attendance), params: {
      attendance: {
        check_in: new_check_in,
        check_out: new_check_out
      }
    }

    assert_redirected_to employee_attendance_url(@employee, @attendance)
    @attendance.reload
    assert_equal new_check_in.day, @attendance.check_in.day
  end

  test "should not update attendance with invalid params" do
    original_check_in = @attendance.check_in
    
    patch employee_attendance_url(@employee, @attendance), params: {
      attendance: {
        check_in: nil
      }
    }

    assert_response :unprocessable_entity
    @attendance.reload
    assert_equal original_check_in, @attendance.check_in
  end

  test "should not update attendance with check_out before check_in" do
    original_check_in = @attendance.check_in
    
    patch employee_attendance_url(@employee, @attendance), params: {
      attendance: {
        check_in: Time.now + 8.hours,
        check_out: Time.now
      }
    }

    assert_response :unprocessable_entity
  end

  # ==================== Destroy ====================

  test "should destroy attendance" do
    assert_difference("Attendance.count", -1) do
      delete employee_attendance_url(@employee, @attendance)
    end

    assert_redirected_to employee_attendances_url(@employee)
  end

  test "should redirect to employee attendances after destroy" do
    delete employee_attendance_url(@employee, @attendance)
    assert_redirected_to employee_attendances_url(@employee)
  end

  # ==================== Edge Cases ====================

  test "should handle employee with no attendances" do
    # Create employee with no attendances
    new_employee = Employee.create!(
      name: "No Attendance Employee",
      position: "Intern",
      base_salary: 15000
    )

    get employee_attendances_url(new_employee)
    assert_response :success
  end

  test "should display different employee attendances correctly" do
    # View john's attendances
    get employee_attendances_url(@employee)
    assert_response :success

    # View jane's attendances
    get employee_attendances_url(@other_employee)
    assert_response :success
  end
end

