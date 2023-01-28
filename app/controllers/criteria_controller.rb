class CriteriaController < ApplicationController
  before_action :set_criterium, only: %i[ show edit update destroy ]

  # GET /criteria or /criteria.json
  def index
    @criteria = Criterium.all
  end

  # GET /criteria/1 or /criteria/1.json
  def show
  end

  # GET /criteria/new
  def new
    @criterium = Criterium.new
  end

  # GET /criteria/1/edit
  def edit
  end

  # POST /criteria or /criteria.json
  def create
    @criterium = Criterium.new(criterium_params)

    respond_to do |format|
      if @criterium.save
        format.html { redirect_to criterium_url(@criterium), notice: "Criterium was successfully created." }
        format.json { render :show, status: :created, location: @criterium }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @criterium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /criteria/1 or /criteria/1.json
  def update
    respond_to do |format|
      if @criterium.update(criterium_params)
        format.html { redirect_to criterium_url(@criterium), notice: "Criterium was successfully updated." }
        format.json { render :show, status: :ok, location: @criterium }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @criterium.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /criteria/1 or /criteria/1.json
  def destroy
    @criterium.destroy

    respond_to do |format|
      format.html { redirect_to criteria_url, notice: "Criterium was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_criterium
      @criterium = Criterium.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def criterium_params
      params.require(:criterium).permit(:rubric_id, :description, :weight, :sequence, :l1_description, :l2_description, :l3_description, :l4_description, :l5_description)
    end
end
