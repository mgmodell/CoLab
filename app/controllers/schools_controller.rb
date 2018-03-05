# frozen_string_literal: true

class SchoolsController < ApplicationController
  layout 'admin'
  before_action :set_school, only: %i[show edit update destroy]
  before_action :check_admin

  def show
    @title = t '.title'
  end

  def edit
    @title = t '.title'
  end

  # GET /admin/school
  def index
    @title = t '.title'
    @schools = School.all
  end

  def new
    @title = t '.title'
    @school = School.new
  end

  def create
    @title = t '.title'
    @school = School.new(school_params)
    if @school.save
      redirect_to schools_url, notice: t('schools.create_success')
    else
      logger.debug @school.errors.full_messages unless @school.errors.empty?
      render :new
    end
  end

  def update
    @title = t '.title'
    if @school.update(school_params)
      redirect_to school_path(@school), notice: t('schools.update_success')
    else
      logger.debug @school.errors.full_messages unless @school.errors.empty?
      render :edit
    end
  end

  def destroy
    @school.destroy
    redirect_to schools_url, notice: t('schools.destroy_success')
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
