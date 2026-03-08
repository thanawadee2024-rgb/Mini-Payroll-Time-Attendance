class Employee < ApplicationRecord
  has_many :attendances, dependent: :destroy

  validates :name, presence: true
  validates :position, presence: true
  validates :base_salary, presence: true, numericality: { greater_than: 0 }

  def work_days
    attendances
      .where.not(check_in: nil, check_out: nil)
      .distinct
      .count
  end

  def total_ot_hours
    attendances.sum { |a| a.ot_hours.to_f }.round(2)
  end

  def hourly_rate
    (base_salary.to_f / 30.0 / 8.0).round(2)
  end

  def ot_pay
    (total_ot_hours.to_f * hourly_rate).round(2)
  end

  def total_income
    (base_salary.to_f + ot_pay).round(2)
  end

  def tax
    income = total_income

    if income <= 30_000
      0.00
    elsif income <= 50_000
      ((income - 30_000) * 0.05).round(2)
    else
      ((20_000 * 0.05) + ((income - 50_000) * 0.10)).round(2)
    end
  end

  def net_pay
    (total_income.to_f - tax).round(2)
  end
end
