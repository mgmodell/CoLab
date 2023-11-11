# frozen_string_literal: true

class RubricsController < ApplicationController
  include PermissionsCheck

  before_action :check_editor
  before_action :set_rubric, only: %i[show update destroy copy publish activate]

  # GET /rubrics or /rubrics.json
  def index
    @rubrics = if current_user.is_admin?
                 Rubric.for_admin
               else
                 Rubric.for_instructor(current_user)
                       .or(Rubric.where(user: current_user))
                       .group(:name, :version)
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
            active: rubric.active,
            user: rubric.user.informal_name(anon),
            mine: rubric.user == current_user
          }
        end
        render json: resp
      end
    end
  end

  # GET /rubrics/publish/1.json
  def publish
    if current_user.is_admin? || current_user == @rubric.user
      @rubric.published = true
      @rubric.save
    end

    logger.debug @rubric.errors.full_messages unless @rubric.errors.empty?

    respond_to do |format|
      format.json do
        if !@rubric.errors.empty?
          @rubric.published = false
          render json: standardized_response(@rubric, @rubric.errors)
        else
          render json: standardized_response(@rubric, { main: t('rubrics.publish_success') })
        end
      end
    end
  end

  # GET /rubrics/activate/1.json
  def activate
    if current_user.is_admin? || current_user == @rubric.user
      @rubric.active = !@rubric.active
      @rubric.save
    end

    respond_to do |format|
      format.json do
        if !@rubric.errors.empty?
          @rubric.active = !@rubric.active
          render json: standardized_response(@rubric, @rubric.errors)
        else
          render json: standardized_response(@rubric, { main: t(
            @rubric.active ? 'rubrics.activate_success' : 'rubrics.deactivate_success'
          ) })
        end
      end
    end
  end

  # GET /rubrics/1 or /rubrics/1.json
  def show
    respond_to do |format|
      format.json do
        render json: standardized_response(@rubric)
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
      active: false,
      school: @rubric.school,
      user: current_user
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
        l5_description: criterium.l5_description
      )
    end
    copied_rubric.save
    logger.debug copied_rubric.errors.full_messages unless copied_rubric.errors.empty?

    render json: standardized_response(copied_rubric, copied_rubric.errors)
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
        render json: standardized_response(@rubric)
      else
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
        if !@rubric.errors.empty? && @rubric.errors[:published].present?
          new_version = current_user.rubrics.new(
            name: @rubric.name,
            description: @rubric.description,
            published: false,
            version: (@rubric.version + 1),
            active: false,
            school: @rubric.school,
            parent: @rubric
          )
          @rubric.criteria.each do |criterium|
            new_version.criteria.new(
              description: criterium.description,
              weight: criterium.weight,
              sequence: criterium.sequence,
              l1_description: criterium.l1_description,
              l2_description: criterium.l2_description,
              l3_description: criterium.l3_description,
              l4_description: criterium.l4_description,
              l5_description: criterium.l5_description
            )
          end
          @rubric = new_version
          @rubric.save
        end
      end
      logger.debug @rubric.errors.full_messages unless @rubric.errors.empty?
      if @rubric.errors.empty?
        format.json do
          render json: standardized_response(@rubric, { main: 'Successfully saved rubric' })
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
      format.json { head :no_content }
    end
  end

  private

  def standardized_response(rubric, messages = {})
    anon = current_user.anonymize?

    response = {
      rubric: rubric.as_json(
        only: %I[id name description published active school_id version parent_id],
        include: { criteria: { only: %I[ id description sequence
                                         weight l1_description l2_description
                                         l3_description l4_description l5_description ] } }
      ),
      messages:
    }
    response[:rubric][:name] = anon ? rubric.anon_name : rubric.name
    response[:rubric][:description] = anon ? rubric.anon_description : rubric.description
    response[:rubric][:user] = rubric.user.informal_name(anon)
    response
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_rubric
    @rubric = if params[:id].blank? || 'new' == params[:id]
                Rubric.new(
                  name: '',
                  school_id: current_user.school_id,
                  published: false,
                  active: false,
                  user: current_user,
                  criteria: [
                    Criterium.new(
                      id: -1,
                      description: t('rubrics.new.criteria'),
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
                                                           l4_description l5_description ])
  end
end
