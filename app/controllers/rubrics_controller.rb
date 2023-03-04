class RubricsController < ApplicationController
  include PermissionsCheck

  before_action :check_editor
  before_action :set_rubric, only: %i[ show update destroy copy ]


  # GET /rubrics or /rubrics.json
  def index
    if current_user.is_admin?
      @rubrics = Rubric.includes( :user ).group( :name, :version )
    else
      @rubrics = Rubric.includes( :user )
        where( school: current_user.school, published: true ).
        or( Rubric.where( user: current_user ) ).
        group( :name, :version )
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

  # GET /rubrics/copy/1.json
  def copy
    copied_rubric = Rubric.new(
      name: "#{@rubric.name} (copy)",
      description: @rubric.description,
      published: false,
      version: 1,
      school: @rubric.school,
      user: @rubric.user,
    )
    @rubric.criteria.each do |criterium|
      copied_rubric.criteria.new(
        description: criterium.description,
        weight: criterium.weight,
        sequence: criterium.sequence,
        l1_description: criterium.l1_description,
        l2_description: criterium.l2_description,
        l3_description: criterium.l3_description,
        l4_description: criterium.l4_description,
        l5_description: criterium.l5_description,
      )
    end
    copied_rubric.save
    logger.debug copied_rubric.errors.full_messages unless copied_rubric.errors.empty?

    render json: standardized_response( copied_rubric, copied_rubric.errors )
  end

  # GET /rubrics/new
  def new
    @rubric = current_user.rubrics.new(
      school: current_user.school
    )
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
      if 'new' == params[:id]
        @rubric = Rubric.new(rubric_params)
        @rubric.user = current_user
        @rubric.school = current_user.school
        @rubric.save
      else
        @rubric.update(rubric_params)
      end
      if @rubric.errors.empty?
        format.json do
          render json: standardized_response( @rubric, { main: 'Successfully saved rubric'} )
        end
      else
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

        response = {
          rubric: rubric.as_json(
            only: %I[id name description published school_id version parent_id],
                      include: { criteria: { only: %I[ id description sequence
                                                weight l1_description l2_description
                                                l3_description l4_description l5_description ]}
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
      @rubric = if params[:id].blank? || params[:id] == 'new'
                  Rubric.new(
                    name: '',
                    school_id: current_user.school_id,
                    published: false,
                    user: current_user,
                    criteria: [
                      Criterium.new(
                        id: -1,
                        description: t( 'rubrics.new.criteria' ),
                        sequence: 1,
                        l1_description: t('rubrics.new.criteria_l1')
                      )
                    ]
                  )
                else
                  Rubric.includes(:criteria, :user).find(params[:id])
                end
      @rubric.school ||= current_user.school
      @rubric.user ||= current_user
    end

    # Only allow a list of trusted parameters through.
    def rubric_params
      params.require(:rubric).permit(:name, :description, :published,
                                      criteria_attributes: %I[id description weight
                                                              sequence l1_description
                                                              l2_description l3_description
                                                              l4_description l5_description ]
       )
    end
end
