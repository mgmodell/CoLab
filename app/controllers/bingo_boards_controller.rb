# frozen_string_literal: true

class BingoBoardsController < ApplicationController
  before_action :set_bingo_board,
                except: %i[index update board_for_game board_for_game_demo
                           update_demo]
  skip_before_action :authenticate_user!,
                     only: %i[board_for_game_demo update_demo]
  before_action :demo_user,
                only: %i[board_for_game_demo update_demo]

  include Demoable

  def show
    @title = t '.title'
    respond_to do |format|
      format.json { render json: @bingo_board }
    end
  end

  def board_for_game_demo
    bingo_game_id = params[:bingo_game_id]
    demo_project = Project.new(
      id: -1,
      name: (t :demo_project),
      course_id: -1
    )
    bingo_game = BingoGame.new(
      id: -42,
      topic: (t 'candidate_lists.demo_bingo_topic'),
      description: (t 'candidate_lists.demo_bingo_description'),
      end_date: 1.days.from_now.end_of_day,
      group_option: false,
      project: demo_project,
      size: 5
    )
    board_for_game_helper bingo_game: bingo_game
  end

  def board_for_game
    bingo_game_id = params[:bingo_game_id]
    bingo_game = BingoGame .find(params[:bingo_game_id])
    bingo_board = bingo_game.bingo_boards.playable
                            .includes(:bingo_game, bingo_cells: :concept)
                            .where(user_id: @current_user.id).take
    board_for_game_helper bingo_board: bingo_board,
                          bingo_game: bingo_game
  end

  def board_for_game_helper(bingo_board: nil, bingo_game:)
    # TODO: Maybe this can be simplified?
    if bingo_board.nil?
      bingo_board = BingoBoard.new
      bingo_board.bingo_game = bingo_game
      bingo_board.iteration = 0
    end

    cells = bingo_board.bingo_cells
                       .order(row: :asc, column: :asc).to_a
    # Let's init those cells
    size = bingo_board.bingo_game.size
    mid = (size / 2.0).round
    size.times do |row|
      size.times do |column|
        i = size * row + column
        cell = cells[i]
        next unless cells[i].nil?

        cell = bingo_board.bingo_cells.build
        cell.selected = (row == mid) && column == mid
        cell.row = row
        cell.column = column
      end
    end

    respond_to do |format|
      format.json do
        render json: bingo_board.to_json(
          only: %i[id size topic bingo_game_id], include:
               [:bingo_game, bingo_cells:
               { only: [:id, :bingo_board_id,
                        :row, :column, :selected, 'concept_id'],
                 include:
                 [concept: { only: %i[id name] }] }]
        )
      end
    end
  end

  def worksheet_for_game
    bingo_game_id = params[:bingo_game_id]
    bingo_game = BingoGame .find(params[:bingo_game_id])
    bingo_board = bingo_game.bingo_boards.worksheet
                            .includes(:bingo_game, bingo_cells: :concept)
                            .where(user_id: @current_user.id).take

    candidates = bingo_game.candidates.acceptable.to_a
    #Assuming 10 items
    items = {}

    while items.length < 10 && !candidates.empty? do
      candidate = candidates.sample
      items[ candidate.concept ] = candidate
      candidates.delete( candidate )
    end

    board = BingoBoard.new(
      iteration: 0,
      user_id: @current_user.id,
      user: @current_user,
      board_type: :worksheet
    )

    concepts = bingo_game.concepts.to_a
    if items.length == 10 && concepts.size > 25
      cells = items.values
      while cells.length <= 24 do
        c = concepts.delete( concepts.sample )
        if items[ c ].nil?
          cells << c
        end
      end
      0.upto(bingo_game.size-1) do |row|
        0.upto(bingo_game.size-1) do |column|
          c = cells[ sample ]
          board.build_bingo_cell(
            row: row,
            column: column,
            concept: c.class == Concept ? c : c.concept,
            candidate: c.class == Concept ? nil : c
          )
        end
      end
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

  def update_demo
    bingo_game_id = params[:bingo_game_id]
    @board = BingoBoard.new(
      id: -42,
      iteration: 0,
      user_id: @current_user.id,
      user: @current_user,
      board_type: :playable
    )
    @board.assign_attributes(bingo_board_params)

    update_responder
  end

  def update
    bingo_game_id = params[:bingo_game_id]
    @board = BingoBoard.where(
      user_id: @current_user.id,
      bingo_game_id: :bingo_game_id
    ).take
    @board = BingoBoard.new if @board.nil?

    iteration = @board.iteration
    @board.assign_attributes(bingo_board_params)
    @board.user_id = @current_user.id
    @board.iteration += iteration

    if @board.save
      @board = BingoBoard
               .includes(:bingo_game, bingo_cells: :concept)
               .find(@board.id)

      update_responder
    else
      logger.debug @board.errors.full_messages

      respond_to do |format|
        format.json do
          render json: { message: @board.errors.full_messages }
        end
      end

    end
  end

  private

  def update_responder
    respond_to do |format|
      format.json do
        render json: @board.to_json(
          only: %i[id size topic bingo_game_id], include:
               [:bingo_game, bingo_cells:
               { only: [:id, :bingo_board_id,
                        :row, :column, :selected, 'concept_id'],
                 include:
                 [concept: { only: %i[id name] }] }]
        )
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_bingo_board
    @bingo_board = BingoBoard.find(params[:id])
  end

  def bingo_board_params
    params.require(:bingo_board).permit(:id, :iteration, :bingo_game_id,
                                        bingo_cells_attributes:
                                                %i[id concept_id
                                                   selected row
                                                   column])
  end

  def play_bingo_board_params
    params.require(:bingo_board).permit(bingo_cells: %i[id selected])
  end
end
