# frozen_string_literal: true

class ConceptsController < ApplicationController
  include PermissionsCheck

  layout 'admin', except: %i[review_candidates update_review_candidates]
  before_action :set_concept, only: %i[show update destroy]
  before_action :check_admin,
                except: %i[concepts_for_game concepts_for_game_demo]
  skip_before_action :authenticate_user!,
                     only: %i[concepts_for_game_demo]
  before_action :demo_user,
                only: %i[concepts_for_game_demo]

  include Demoable

  def show
    respond_to do | format |
      format.json do
        render json: @concept.to_json( only: %i[name candidates_count courses_count bingo_count] )
      end
    end
  end

  # GET /admin/concept
  def index
    respond_to do | format |
      format.json do
        @concepts = Concept.all.order( :name )
        render json: @concepts.collect { | c |
                       {
                         id: c.id,
                         name: c.name,
                         cap_name: c.name.upcase,
                         times: c.candidates_count,
                         bingos: c.bingo_games_count,
                         courses: c.courses_count
                       }
                     }.to_json
      end
    end
  end

  def concepts_for_game_demo
    concepts = []
    bingo_game_id = params[:id].to_i
    search_string = if params[:search_string].present?
                      params[:search_string].strip.downcase
                    else
                      ''
                    end

    if 0 != bingo_game_id || search_string.length > 2
      index = 0
      demo_concepts = get_demo_game_concepts
      demo_concepts.each do | concept |
        index -= 1
        concepts << Concept.new( id: index, name: concept[0] )
      end
      concepts.select! { | c | c.name.downcase.include? search_string } if bingo_game_id.zero?
    end

    respond_to do | format |
      format.json do
        render json: concepts.collect { | c | { id: c.id, name: c.name } }.to_json
      end
    end
  end

  def concepts_for_game
    concepts = []
    bingo_game_id = params[:id].to_i
    if bingo_game_id.positive?
      concepts = BingoGame.find( bingo_game_id ).concepts.where( 'concepts.id > 0' ).uniq.to_a
    elsif current_user.is_admin? || current_user.is_instructor?
      substring = params[:search_string].strip
      criteria = 'true ?'
      concepts = []
      if substring.length > 2
        criteria = 'concepts.name LIKE ?'
        substring = "%#{substring}%"
        if current_user.is_instructor?
          concepts = Concept.where( 'concepts.id > 0' )
                            .where( criteria, substring )
                            .order( bingo_games_count: :desc )
                            .limit( 9 )
                            .to_a
        end
      end
    end

    respond_to do | format |
      format.json do
        render json: concepts.collect { | c | { id: c.id, name: c.name } }.to_json
      end
    end
  end

  def update
    if @concept.update( concept_params )
      respond_to do | format |
        format.json do
          render json: @concept.to_json( only: %i[name candidates_count courses_count bingo_count] )
        end
      end
    else
      respond_to do | format |
        format.json do
          render json: { errors: @concept.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @concept.destroy
    redirect_to concepts_url, notice: t( 'concepts.destroy_success' )
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_concept
    @concept = Concept.find( params[:id] )
  end

  def concept_params
    params.require( :concept ).permit( :name )
  end
end
