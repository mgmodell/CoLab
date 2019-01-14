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

  def show
    @title = t '.title'
  end

  def edit
    @title = t '.title'
  end

  # GET /admin/concept
  def index
    @title = t '.title'
    @concepts = Concept.all.order(:name)
    respond_to do |format|
      format.html do
        render :index
      end
      format.json do
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

  @@demo_concepts =
    ['Fun', 'Play', 'Challenge', 'Game Mechanics', 'Game Elements',
     'Game-based', 'Points', 'Badges', 'Leaderboards', 'Motivation',
     'Feedback', 'Progress Tracking', 'Story', 'Rewards',
     'Avatars', 'Theme', 'Autonomy', 'Levels', 'Gartner\'s Hype Cycle',
     'Game Dynamics', 'Social Interaction', 'Learning Gains',
     'Learning Analytics', 'Game Design Principles', 'Learning Design',
     'Gamified Learning', 'Gameful', 'Behavior Change', 'Simulation',
     'Chance', 'Surprise', 'Reliability', 'Validity',
     'Gamified Platform', 'Learner Characteristics',
     'Educational Context', 'Learning Environment', 'Evidence-based',
     'Experience Design', 'Competition', 'Learner Engagement',
     'Active Learning']
  def concepts_for_game_demo
    concepts = []
    bingo_game_id = params[:id].to_i

    index = 0
    @@demo_concepts.each do |concept_name|
      index -= 1
      concepts << Concept.new(id: index, name: concept_name)
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
      if @current_user.is_admin? || @current_user.is_instructor?
        substring = params[:search_string].strip
        criteria = 'true ?'
        if substring.length > 2
          criteria = 'concepts.name LIKE ?'
          substring = "%#{substring}%"
        else
          substring = ''
        end
        concepts = Concept.where('concepts.id > 0').where(criteria, substring).to_a if @current_user.is_instructor?
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
    redirect_to root_path unless @current_user.is_admin?
  end

  def concept_params
    params.require(:concept).permit(:name)
  end

  # TODO: Perhaps refactor into demo-able?
  def demo_user
    if @current_user.nil?
      @current_user = User.new(first_name: t(:demo_surname_1),
                               last_name: t(:demo_fam_name_1),
                               timezone: t(:demo_user_tz))
    end
  end
end
