class RubricsController < ApplicationController
  include PermissionsCheck

  before_action :set_rubric, only: %i[ show edit update destroy ]
  before_action :check_admin


  # GET /rubrics or /rubrics.json
  def index
    if current_user.is_admin?
      @rubrics = Rubric.group( :name, :version )
    else
      @rubrics = Rubric.
        where( school: current_user.school ).
        group( :name, :version ).maximum( :version )
    end

    anon = current_user.anonymize?
    respond_to do |format|
      format.json do
        resp = @rubrics.collect do |rubric|
          {
            id: rubric.id,
            name: rubric.name,
            description: rubric.description,
            published: rubric.published,
            version: rubric.version,
            user: rubric.user.informal_name( anon ),
          }
        end
        render json: resp
      end
    end
  end

  # GET /rubrics/1 or /rubrics/1.json
  def show
    anon = current_user.anonymize?
    respond_to do |format|
      format.json do
        response = @rubric.as_json(
            only: [:id, :name, :description, 
                    :published, :school_id, :version,
                    :parent_id]
          )
        response[:user] = @rubric.user.informal_name( anon )
        render json: response
      end
    end
  end

  # GET /rubrics/new
  def new
    @rubric = Rubric.new
  end

  # GET /rubrics/1/edit
  def edit
  end

  # POST /rubrics or /rubrics.json
  def create
    @rubric = Rubric.new(rubric_params)

    respond_to do |format|
      if @rubric.save
        format.html { redirect_to rubric_url(@rubric), notice: "Rubric was successfully created." }
        format.json { render :show, status: :created, location: @rubric }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rubric.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rubrics/1 or /rubrics/1.json
  def update
    respond_to do |format|
      if @rubric.update(rubric_params)
        format.html { redirect_to rubric_url(@rubric), notice: "Rubric was successfully updated." }
        format.json { render :show, status: :ok, location: @rubric }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rubric.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rubrics/1 or /rubrics/1.json
  def destroy
    @rubric.destroy

    respond_to do |format|
      format.html { redirect_to rubrics_url, notice: "Rubric was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rubric
      @rubric = Rubric.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rubric_params
      params.require(:rubric).permit(:name, :description, :published )
    end
end
