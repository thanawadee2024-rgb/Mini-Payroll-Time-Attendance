require "test_helper"

class AttendanceWorkflowTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:john_doe)
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

    new_attendance = Attendance.last
    assert_redirected_to employee_attendance_url(@employee, new_attendance)

    # 2. View attendance
    get employee_attendance_url(@employee, new_attendance)
    assert_response :success

    # 3. Edit attendance
    get edit_employee_attendance_url(@employee, new_attendance)
    assert_response :success

    patch employee_attendance_url(@employee, new_attendance), params: {
      attendance: {
        check_in: Time.now + 1.day,
        check_out: Time.now + 1.day + 8.hours
      }
    }

    assert_redirected_to employee_attendance_url(@employee, new_attendance)

    # 4. Delete attendance
    assert_difference("Attendance.count", -1) do
      delete employee_attendance_url(@employee, new_attendance)
    end

    assert_redirected_to employee_attendances_url(@employee)
  end

  # ==================== Attendance Navigation ====================

  test "can navigate from employee to attendances list" do
    get employee_attendances_url(@employee)
    assert_response :success
  end

  test "can navigate to attendance details" do
    attendance = @employee.attendances.first
    
    get employee_attendance_url(@employee, attendance)
    assert_response :success
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

  test "can create attendance on different days" do
    # Create first attendance
    @employee.attendances.create!(
      check_in: Time.new(2026, 6, 1, 9, 0, 0),
      check_out: Time.new(2026, 6, 1, 18, 0, 0)
    )

    # Create second attendance on different day
    assert_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        attendance: {
          check_in: Time.new(2026, 6, 2, 9, 0, 0),
          check_out: Time.new(2026, 6, 2, 18, 0, 0)
        }
      }
    end
  end
end

