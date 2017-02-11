class ExperiencesController < ApplicationController
  before_action :set_experience, only: [:show, :edit, :update, :destroy ]

  def show
  end

  def edit
  end

  def index
    @experiences = []
    if @current_user.is_admin?
      @experiences = Experience.all
    else
      rosters = @current_user.rosters.instructorships
      rosters.each do |roster|
        @experiences.concat roster.course.experiences.to_a
      end
    end
  end

  def new
    @experience = Experience.new
  end

  def create
    @experience = Experience.new( experience_params )
    @experience.course_id = params[ :course_id ]
    respond_to do |format|
      if @experience.save
        format.html { redirect_to @experience, notice: 'Experience was successfully created.' }
        format.json { render :show, status: :created, location: @experience }
      else
        format.html { render :new }
        format.json { render json: @experience.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @experience.update( experience_params )
        format.html { redirect_to @experience, notice: 'Experience was successfully updated.' }
        format.json { render :show, status: :ok, location: @experience }
      else
        format.html { render :edit }
        format.json { render json: @experience.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @experience.destroy
    respond_to do |format|
      format.html { redirect_to experiences_url, notice: "Experience was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  private
    #Use callbacks to share common setup or constraints between actions.
    def set_experience
      e_test = Experience.find( params[ :id ] )
      if @current_user.is_admin?
        @experience = p_test
      else
        if e_test.course.rosters.instructorships.where( user: @current_user ).nil?
          redirect_to :show if @experience.nil?
        else
          @experience = e_test
        end
      end
    end

    def experience_params
      params.require( :name, :active, :start_date, :end_date )
    end
end
