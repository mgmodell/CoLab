class RubricsController < ApplicationController
  before_action :set_rubric, only: %i[ show edit update destroy ]

  # GET /rubrics or /rubrics.json
  def index
    @rubrics = Rubric.all
  end

  # GET /rubrics/1 or /rubrics/1.json
  def show
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
      params.require(:rubric).permit(:name, :description, :passing, :version, :published, :parent)
    end
end
