# frozen_string_literal: true
class ConceptsController < ApplicationController
  before_action :set_concept, only: [:show, :edit, :update, :destroy]
  before_action :check_admin, except: [:concepts_for_game]

  def show
    @title = t '.title'
  end

  def edit
    @title = t '.title'
  end

  # GET /admin/concept
  def index
    @title = t '.title'
    @concepts = Concept.order(:name).page params[:page]
  end

  def concepts_for_game
    concepts = []
    bingo_game_id = params[:id].to_i
    substring = params[:search_string].strip
    criteria = 'true ?'
    if substring.length > 2
      criteria = 'concepts.name LIKE ?'
      substring = "%#{substring}%"
    else
      substring = ''
    end

    if bingo_game_id == 0
      concepts = Concept.where(criteria, substring).to_a if @current_user.is_instructor?
    else
      concepts = BingoGame.find(bingo_game_id).concepts
                          .where(criteria, substring).to_a
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
      render :new
    end
  end

  def update
    @title = t '.title'
    if @concept.update(concept_params)
      redirect_to concept_path(@concept), notice: t('concepts.update_success')
    else
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
    redirect_to root_path unless @current_user.is_admin?
  end

  def concept_params
    params.require(:concept).permit(:name)
  end
end
