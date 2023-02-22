class RubricsController < ApplicationController
  include PermissionsCheck

  before_action :set_rubric, only: %i[ show edit update destroy ]
  before_action :check_editor


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
    respond_to do |format|
      format.json do
        render json: standardized_response( @rubric )
      end
    end
  end

  # GET /rubrics/new
  def new
    @rubric = Rubric.new
  end

  # POST /rubrics or /rubrics.json
  def create
    @rubric = Rubric.new(rubric_params)

    respond_to do |format|
      if @rubric.save
        render json: standardized_response( @rubric )
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
        format.json do
          render json: standardized_response( @rubric, { main: 'Successfully saved rubric'} )
        end
      else
        format.json { render json: @rubric.errors, status: :unprocessable_entity }
        format.json do
          render json: {
              messages: @rubric.errors.full_messages
          }
        end
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

  def standardized_response rubric, messages = { }
    anon = current_user.anonymize?
    puts current_user.inspect
    puts current_user.anonymize?

        response = {
          rubric: rubric.as_json(
            only: [:id, :name, :description, 
                    :published, :school_id, :version,
                    :parent_id],
                    include: {
                      criteria: { only:
                        [
                          :id,
                          :description, :sequence,
                          :weight,
                          :l1_description,
                          :l2_description,
                          :l3_description,
                          :l4_description,
                          :l5_description
                        ]}
                    }
          ),
          messages: messages
        }
        response[:rubric][:name] = anon ? rubric.anon_name : rubric.name
        response[:rubric][:description] = anon ? rubric.anon_description : rubric.description 
        response[:rubric][:user] = rubric.user.informal_name( anon )
        response
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_rubric
      @rubric = Rubric.includes(:criteria).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rubric_params
      params.require(:rubric).permit(:name, :description, :published,
        criteria_attributes: [:id, :description, :weight, :sequence,
                    :l1_description,
                    :l2_description,
                    :l3_description,
                    :l4_description,
                    :l5_description
                  ]
       )
    end
end
