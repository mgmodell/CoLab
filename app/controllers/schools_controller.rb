# frozen_string_literal: true
class SchoolsController < ApplicationController
  before_action :set_school, only: [:show, :edit, :update, :destroy]
  before_action :check_admin

  def show
    @title = "School Details"
  end

  def edit
    @title = "Edit School"
  end

  # GET /admin/school
  def index
    @title = "List of Schools"
    @schools = School.all
  end

  def new
    @title = "New School"
    @school = School.new
  end

  def create
    @title = "New School"
    @school = School.new(school_params)
    if @school.save
      redirect_to url: school_url(@school), notice: 'School was successfully created.'
    else
      render :new
    end
  end

  def update
    @title = "Edit School"
    if @school.update(school_params)
      @school.school = School.find(@school.school_id)
      redirect_to school_path(@school), notice: 'School was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @school.destroy
    redirect_to schools_url, notice: 'School was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = School.find(params[:id])
  end

  def check_admin
    redirect_to root_path unless @current_user.is_admin?
  end

  def school_params
    params.require(:school).permit(:name, :description)
  end
end
