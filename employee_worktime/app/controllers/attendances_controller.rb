class AttendancesController < ApplicationController
  before_action :set_employee
  before_action :set_attendance, only: [ :show, :edit, :update, :destroy ]

  def index
    @attendances = @employee.attendances.order(check_in: :desc)
  end

  def show
  end

  def new
    @attendance = @employee.attendances.new
  end

  def create
    @attendance = @employee.attendances.new(attendance_params)

    if @attendance.save
      redirect_to employee_attendance_path(@employee, @attendance), notice: "Attendance was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @attendance.update(attendance_params)
      redirect_to employee_attendance_path(@employee, @attendance), notice: "Attendance was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @attendance.destroy
    redirect_to employee_attendances_path(@employee), notice: "Attendance was successfully deleted."
  end

  private

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  def set_attendance
    @attendance = @employee.attendances.find(params[:id])
  end

  def attendance_params
    params.require(:attendance).permit(:check_in, :check_out)
  end
end
