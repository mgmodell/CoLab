# frozen_string_literal: true

class BingoBoardsController < ApplicationController
  before_action :set_bingo_board, except: [:index, :board_for_game]

  def show
    @title = t '.title'
    respond_to do |format|
      format.json { render json: @bingo_board }
      format.html { render :show }
    end
  end

  def board_for_game
    bingo_game = BingoGame
      .includes( bingo_boards: { bingo_cells: :concept } )
      .find( params[:bingo_game_id] )
    bingo_board = bingo_game.bingo_boards
      .where( user_id: @current_user.id ).take

    if bingo_board.nil?
      bingo_board = BingoBoard.new( )
      bingo_board.bingo_game = bingo_game
    end

    respond_to do |format|
      format.json {
        render json: bingo_board.to_json(
               include:
                { bingo_game: { only: [ :size, :topic ] },
                  bingo_cells: { only: [ :id, :row, :column, :selected,
                    concept: { only: [ :id, :name ] } ]  }
                
                }
        )
      }
    end
  end

  def edit
    @title = t '.title'
    # check if we've got cells yet
    if @bingo_board.bingo_cells.empty?
      # generate a new board

    end

    # ...and spit it out
    respond_to do |format|
      format.json { render json: @bingo_board }
      format.html { render :edit }
    end
  end

  # GET /admin/bingo_board
  def index
    @title = t '.title'
    # Narrow down to those available to the user
    @bingo_boards = BingoBoard.where user: @current_user
    respond_to do |format|
      format.json do
        render json: @bingo_boards.collect do |board|
          { id: board.id, name: board.bingo_game.topic }
        end
      end
    end
  end

  def update
    @title = t '.title'
    if @bingo_board.update(bingo_board_params)
      redirect_to bingo_board_path(@bingo_board), notice: t('bingo_boards.update_success')
    else
      logger.debug @bingo_board.errors.full_messages unless @bingo_board.errors.empty?
      respond_to do |format|
        format.json { render json: @bingo_board }
        format.html { render :edit }
      end
    end
  end

  def play_board
    @title = t '.title'
    # Build game play
    if @bingo_board.update(bingo_board_params)
      redirect_to bingo_board_path(@bingo_board), notice: t('bingo_boards.update_success')
    else
      respond_to do |format|
        format.json { render json: @bingo_board }
        format.html { render :edit }
      end
    end
  end

  def verify_win
    verified = params[:verified]
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bingo_board
    @bingo_board = BingoBoard.find(params[:id])
  end

  def bingo_board_params
    params.require(:bingo_board).permit(bingo_cells: %i[id concept_id
                                                        selected])
  end
end
