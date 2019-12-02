# frozen_string_literal: true

class ConceptsController < ApplicationController
  layout 'admin', except: %i[review_candidates update_review_candidates]
  before_action :set_concept, only: %i[show edit update destroy]
  before_action :check_admin,
                except: %i[concepts_for_game concepts_for_game_demo]
  skip_before_action :authenticate_user!,
                     only: %i[concepts_for_game_demo]
  before_action :demo_user,
                only: %i[concepts_for_game_demo]

  include Demoable

  def show
    @title = t '.title'
  end

  def edit
    @title = t '.title'
  end

  # GET /admin/concept
  def index
    @title = t '.title'
    respond_to do |format|
      format.html do
        render :index
      end
      format.json do
        @concepts = Concept.all.order(:name)
        render json: @concepts.collect { |c|
                       {
                         id: c.id,
                         name: c.name,
                         cap_name: c.name.upcase,
                         times: c.candidates_count,
                         bingos: c.bingo_games_count,
                         courses: c.courses_count
                       }
                     } .to_json
      end
    end
  end

  def concepts_for_game_demo
    concepts = []
    bingo_game_id = params[:id].to_i
    search_string = params[:search_string].present? ?
                      params[:search_string].strip.downcase :
                      ''

    if bingo_game_id != 0 || search_string.length > 2
      index = 0
      demo_concepts = get_demo_game_concepts
      demo_concepts.each do |concept|
        index -= 1
        concepts << Concept.new(id: index, name: concept[0])
      end
      if bingo_game_id == 0
        concepts.select! { |c| c.name.downcase.include? search_string }
      end
    end

    respond_to do |format|
      format.json do
        render json: concepts.collect { |c| { id: c.id, name: c.name } }.to_json
      end
    end
  end

  def concepts_for_game
    concepts = []
    bingo_game_id = params[:id].to_i
    if bingo_game_id > 0
      concepts = BingoGame.find(bingo_game_id).concepts.where('concepts.id > 0').uniq.to_a
    else
      if current_user.is_admin? || current_user.is_instructor?
        substring = params[:search_string].strip
        criteria = 'true ?'
        concepts = []
        if substring.length > 2
          criteria = 'concepts.name LIKE ?'
          substring = "%#{substring}%"
          if current_user.is_instructor?
            concepts = Concept.where('concepts.id > 0')
                              .where(criteria, substring)
                              .order(bingo_games_count: :desc)
                              .limit(9)
                              .to_a
          end
        end
      end
    end

    respond_to do |format|
      format.json do
        render json: concepts.collect { |c| { id: c.id, name: c.name } }.to_json
      end
    end
  end

  def new
    @title = t '.title'
    @concept = Concept.new
  end

  def create
    @title = t '.title'
    @concept = Concept.new(concept_params)
    if @concept.save
      redirect_to url: concept_url(@concept), notice: t('concepts.create_success')
    else
      logger.debug @concepts.errors.full_messages unless @concepts.errors.empty?
      render :new
    end
  end

  def update
    @title = t '.title'
    if @concept.update(concept_params)
      redirect_to concept_path(@concept), notice: t('concepts.update_success')
    else
      logger.debug @concept.errors.full_messages unless @concept.errors.empty?
      render :edit
    end
  end

  def destroy
    @concept.destroy
    redirect_to concepts_url, notice: t('concepts.destroy_success')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_concept
    @concept = Concept.find(params[:id])
  end

  def check_admin
    redirect_to root_path unless current_user.is_admin?
  end

  def concept_params
    params.require(:concept).permit(:name)
  end
end
