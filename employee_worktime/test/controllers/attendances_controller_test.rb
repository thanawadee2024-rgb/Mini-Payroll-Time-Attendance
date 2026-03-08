require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:john_doe)
    @attendance = attendances(:john_morning)
  end

  # ==================== Index ====================

  test "should get index" do
    get employee_attendances_url(@employee)
    assert_response :success
  end

  test "index should display all employee attendances" do
    get employee_attendances_url(@employee)
    assert_response :success
    assert_select "table"
  end

  test "index should show attendances in descending order" do
    get employee_attendances_url(@employee)
    assert_response :success
  end

  # ==================== Show ====================

  test "should show attendance" do
    get employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  test "show should display attendance details" do
    get employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  # ==================== New ====================

  test "should get new" do
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

  test "should not create attendance with invalid params" do
    assert_no_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        attendance: {
          check_in: nil,
          check_out: nil
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

  # ==================== Edit ====================

  test "should get edit" do
    get edit_employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  test "edit should render form with existing values" do
    get edit_employee_attendance_url(@employee, @attendance)
    assert_response :success
  end

  # ==================== Update ====================

  test "should update attendance with valid params" do
    new_check_in = Time.now + 1.day
    new_check_out = Time.now + 1.day + 8.hours
    
    patch employee_attendance_url(@employee, @attendance), params: {
      attendance: {
        check_in: new_check_in,
        check_out: new_check_out
      }
    }

    assert_redirected_to employee_attendance_url(@employee, @attendance)
    @attendance.reload
    assert_equal new_check_in.to_date, @attendance.check_in.to_date
  end

  test "should not update attendance with invalid params" do
    patch employee_attendance_url(@employee, @attendance), params: {
      attendance: {
        check_in: nil,
        check_out: nil
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
end

