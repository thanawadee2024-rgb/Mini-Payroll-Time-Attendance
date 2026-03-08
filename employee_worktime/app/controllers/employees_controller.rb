class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[ show edit update destroy ]

  def index
    search_term = params[:search]&.strip
    
    if search_term.present?
      # Clean search term - remove currency symbol and spaces
      clean_term = search_term.gsub("฿", "").gsub(",", "").strip
      
      # Try to parse as number for base_salary search
      salary_search = clean_term.to_f if clean_term.match?(/^[\d.]+$/)
      
      conditions = ["name ILIKE ? OR position ILIKE ?", "%#{search_term}%", "%#{search_term}%"]
      
      if salary_search && salary_search > 0
        # Use range for partial match - e.g., "5" matches 5000, 50000 etc.
        min_salary = salary_search
        max_salary = salary_search * 10 - 1
        conditions[0] += " OR (base_salary >= ? AND base_salary <= ?)"
        conditions << min_salary << max_salary
      end
      
      @employees = Employee.where(conditions)
      @search_performed = true
      @search_term = search_term
    else
      @employees = Employee.all
      @search_performed = false
    end

    respond_to do |format|
      format.html
      format.json { render json: @employees }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @employee }
    end
  end

  def new
    @employee = Employee.new
  end

  def edit
  end

  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: "Employee was successfully created." }
        format.json { render json: @employee, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: "Employee was successfully updated." }
        format.json { render json: @employee, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @employee.destroy

    respond_to do |format|
      format.html { redirect_to employees_path, notice: "Employee was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:name, :position, :base_salary)
  end
end
