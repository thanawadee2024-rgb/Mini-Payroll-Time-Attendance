class Attendance < ApplicationRecord
  belongs_to :employee

  validates :check_in, presence: true
  validate :checkout_after_checkin
  validate :one_checkin_per_day

  def checkout_after_checkin
    return if check_in.blank? || check_out.blank?
    return if check_out > check_in

    errors.add(:check_out, "must be after check in")
  end

  def one_checkin_per_day
    return if employee_id.blank? || check_in.blank?

    scope = Attendance.where(employee_id: employee_id)
                      .where("DATE(check_in) = ?", check_in.to_date)

    scope = scope.where.not(id: id) if persisted?

    if scope.exists?
      errors.add(:check_in, "already checked in today")
    end
  end

  def work_hours
    return 0 if check_in.blank? || check_out.blank?

    ((check_out - check_in) / 3600.0).round(2)
  end

  def ot_hours
    ot = [work_hours - 8, 0].max
    ot.is_a?(Float) ? ot.round(2) : ot
  end
end
