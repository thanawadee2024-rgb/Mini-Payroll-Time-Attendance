require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  setup do
    @employee = employees(:john_doe)
    @attendance = attendances(:john_morning)
  end

  # ==================== Validations ====================

  test "should be valid with required attributes" do
    attendance = Attendance.new(
      employee: @employee,
      check_in: Time.now,
      check_out: Time.now + 8.hours
    )
    assert attendance.valid?
  end

  test "should not be valid without check_in" do
    attendance = Attendance.new(
      employee: @employee,
      check_out: Time.now + 8.hours
    )
    assert_not attendance.valid?
  end

  # ==================== Associations ====================

  test "should belong to employee" do
    assert_respond_to @attendance, :employee
    assert_instance_of Employee, @attendance.employee
  end

  # ==================== work_hours ====================

  test "work_hours should calculate hours between check_in and check_out" do
    # john_morning: 09:00 - 18:00 = 9 hours
    result = @attendance.work_hours
    
    assert_kind_of Float, result
    assert result > 0
  end

  test "work_hours should return 0 when check_in is blank" do
    # Use build to create an in-memory object without saving (avoids validation)
    attendance = @employee.attendances.build(
      check_in: nil,
      check_out: Time.now + 8.hours
    )
    
    assert_equal 0.00, attendance.work_hours
  end

  test "work_hours should return 0 when check_out is blank" do
    # Use build to create an in-memory object without saving (avoids validation)
    attendance = @employee.attendances.build(
      check_in: Time.now,
      check_out: nil
    )
    
    assert_equal 0.00, attendance.work_hours
  end

  test "work_hours should calculate partial hours correctly" do
    # Create attendance with 8.5 hours
    attendance = @employee.attendances.create!(
      check_in: Time.new(2026, 3, 10, 9, 0, 0),
      check_out: Time.new(2026, 3, 10, 17, 30, 0)
    )
    
    assert_in_delta 8.5, attendance.work_hours, 0.01
  end

  # ==================== ot_hours ====================

  test "ot_hours should return 0 when work hours <= 8" do
    attendance = attendances(:john_short)
    
    assert_equal 0.00, attendance.ot_hours
  end

  test "ot_hours should calculate OT when work hours > 8" do
    # john_ot: 09:00 - 20:00 = 11 hours, OT = 11 - 8 = 3 hours
    attendance = attendances(:john_ot)
    
    assert attendance.ot_hours > 0
    assert_in_delta 3.0, attendance.ot_hours, 0.01
  end

  # ==================== checkout_after_checkin Validation ====================

  test "should not be valid when check_out before check_in" do
    attendance = Attendance.new(
      employee: @employee,
      check_in: Time.now + 8.hours,
      check_out: Time.now
    )
    
    assert_not attendance.valid?
    assert_includes attendance.errors[:check_out], "must be after check in"
  end

  test "should be valid when check_out after check_in" do
    attendance = Attendance.new(
      employee: @employee,
      check_in: Time.now,
      check_out: Time.now + 8.hours
    )
    
    assert attendance.valid?
  end

  # ==================== one_checkin_per_day Validation ====================

  test "should not allow duplicate check-in on same day for same employee" do
    # Create first attendance
    @employee.attendances.create!(
      check_in: Time.new(2026, 3, 15, 9, 0, 0),
      check_out: Time.new(2026, 3, 15, 18, 0, 0)
    )
    
    # Try to create second attendance on same day
    duplicate_attendance = @employee.attendances.build(
      check_in: Time.new(2026, 3, 15, 10, 0, 0),
      check_out: Time.new(2026, 3, 15, 19, 0, 0)
    )
    
    assert_not duplicate_attendance.valid?
    assert_includes duplicate_attendance.errors[:check_in], "already checked in today"
  end

  test "should allow check-in on different days" do
    # Create first attendance
    @employee.attendances.create!(
      check_in: Time.new(2026, 3, 15, 9, 0, 0),
      check_out: Time.new(2026, 3, 15, 18, 0, 0)
    )
    
    # Create second attendance on different day
    different_day_attendance = @employee.attendances.build(
      check_in: Time.new(2026, 3, 16, 9, 0, 0),
      check_out: Time.new(2026, 3, 16, 18, 0, 0)
    )
    
    assert different_day_attendance.valid?
  end
end

