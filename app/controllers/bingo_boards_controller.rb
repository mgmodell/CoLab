# frozen_string_literal: true
class BingoBoardsController < ApplicationController
  before_action :set_bingo_board, only: [:show, :edit, :update, :destroy]

  def show
    @title = t '.title'
  end

  def edit
    @title = t '.title'
    #generate a new board and spit it out
  end

  # GET /admin/bingo_board
  def index
    @title = t '.title'
    #Narrow down to those available to the user
    @bingo_boards = BingoBoard.where user: @current_user
  end

  def update
    @title = t '.title'
    if @bingo_board.update(bingo_board_params)
      redirect_to bingo_board_path(@bingo_board), notice: t('bingo_boards.update_success')
    else
      render :edit
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bingo_board
    @bingo_board = BingoBoard.find(params[:id])
  end

  def bingo_board_params
    params.require(:bingo_board).permit(bingo_cells: [ :id, :concept_id,
                                                       :selected ])
  end
end
